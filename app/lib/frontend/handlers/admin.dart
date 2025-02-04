// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library pub_dartlang_org.handlers;

import 'dart:async';

import 'package:shelf/shelf.dart' as shelf;

import '../../account/backend.dart';
import '../../package/backend.dart';
import '../../package/models.dart';
import '../../shared/handlers.dart';
import '../../shared/urls.dart' as urls;

import '../templates/admin.dart';
import '../templates/misc.dart';

/// Handles requests for /oauth/callback
shelf.Response oauthCallbackHandler(shelf.Request request) {
  final code = request.requestedUri.queryParameters['code'];
  final state = request.requestedUri.queryParameters['state'];
  if (code == null || state == null) {
    return notFoundHandler(request);
  }
  final isWhitelisted = state.startsWith('/admin/confirm/');
  if (isWhitelisted) {
    return redirectResponse(request.requestedUri
        .replace(
          path: state,
          queryParameters: request.requestedUri.queryParameters,
        )
        .toString());
  } else {
    return notFoundHandler(request);
  }
}

/// Handles requests for /authorized
shelf.Response authorizedHandler(_) => htmlResponse(renderAuthorizedPage());

/// Handles requests for /admin/confirm/new-uploader/...
Future<shelf.Response> confirmNewUploaderHandler(shelf.Request request,
    String packageName, String recipientEmail, String urlNonce) async {
  final type = PackageInviteType.newUploader;
  if (packageName.isEmpty || urlNonce.isEmpty) {
    return _formattedInviteExpiredHandler(request);
  }

  // Check if invite exists and is still valid.
  final invite = await packageBackend.getPackageInvite(
    packageName: packageName,
    type: type,
    recipientEmail: recipientEmail,
    urlNonce: urlNonce,
  );
  if (invite == null) {
    return _formattedInviteExpiredHandler(request);
  }

  // If there is no auth code, display only the page that will have a link to
  // authenticate the user.
  final code = request.requestedUri.queryParameters['code'];
  if (code == null) {
    final inviteEmail = invite.fromUserId == null
        ? invite.fromEmail
        : await accountBackend.getEmailOfUserId(invite.fromUserId);
    final redirectUrl = accountBackend.siteAuthorizationUrl(
        _oauthRedirectUrl(request), request.requestedUri.path);
    return htmlResponse(renderUploaderApprovalPage(
        invite.packageName, inviteEmail, invite.recipientEmail, redirectUrl));
  }

  // Check and validate the auth code.
  String authErrorMessage;
  final accessToken = await accountBackend.siteAuthCodeToAccessToken(
      _oauthRedirectUrl(request), code);
  if (accessToken == null) {
    authErrorMessage ??= 'Unable to verify auth code.';
  }

  final user = await accountBackend.authenticateWithAccessToken(accessToken);
  if (user == null) {
    authErrorMessage ??= 'Unable to verify access token.';
  }

  final matchesEmail = user?.email == recipientEmail;
  if (!matchesEmail) {
    authErrorMessage ??= 'E-mail address does not match invite.';
  }

  if (!matchesEmail) {
    return _formattedInviteExpiredHandler(request,
        title: 'Authorization error', description: authErrorMessage);
  }

  await packageBackend.repository
      .confirmUploader(invite.fromUserId, invite.fromEmail, packageName, user);
  await packageBackend.confirmPackageInvite(invite);
  return redirectResponse(urls.pkgPageUrl(invite.packageName));
}

Future<shelf.Response> _formattedInviteExpiredHandler(
  shelf.Request request, {
  String title = 'Invite expired',
  String description = 'The URL you have clicked expired or became invalid.',
}) async {
  return htmlResponse(renderErrorPage(title, description, null), status: 404);
}

String _oauthRedirectUrl(shelf.Request request) {
  final uri = request.requestedUri;
  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    path: '/oauth/callback',
  ).toString();
}
