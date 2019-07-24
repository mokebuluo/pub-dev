// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:client_data/package_api.dart';
import 'package:logging/logging.dart';
import 'package:pub_server/repository.dart' show UnauthorizedAccessException;
import 'package:shelf/shelf.dart' as shelf;

import '../../dartdoc/backend.dart';
import '../../history/backend.dart';
import '../../scorecard/backend.dart';
import '../../shared/handlers.dart';
import '../../shared/packages_overrides.dart';
import '../../shared/redis_cache.dart' show cache;
import '../../shared/search_client.dart';
import '../../shared/search_service.dart';
import '../../shared/utils.dart';

import '../backend.dart';
import '../models.dart';
import '../name_tracker.dart';

final _logger = Logger('frontend.custom_api');

/// Handles requests for /api/documentation/<package>
Future<shelf.Response> apiDocumentationHandler(
    shelf.Request request, String package) async {
  if (isSoftRemoved(package)) {
    return jsonResponse({}, status: 404);
  }

  final cachedData = await cache.dartdocApiSummary(package).get();
  if (cachedData != null) {
    return jsonResponse(cachedData);
  }

  final versions = await backend.versionsOfPackage(package);
  if (versions.isEmpty) {
    return jsonResponse({}, status: 404);
  }

  versions.sort((a, b) => a.semanticVersion.compareTo(b.semanticVersion));
  String latestStableVersion = versions.last.version;
  for (int i = versions.length - 1; i >= 0; i--) {
    if (!versions[i].semanticVersion.isPreRelease) {
      latestStableVersion = versions[i].version;
      break;
    }
  }

  final dartdocEntries = await Future.wait(versions
      .map((pv) => dartdocBackend.getServingEntry(package, pv.version)));
  final versionsData = [];

  for (int i = 0; i < versions.length; i++) {
    final entry = dartdocEntries[i];
    final hasDocumentation = entry != null && entry.hasContent;
    final status =
        entry == null ? 'awaiting' : (entry.hasContent ? 'success' : 'failed');
    versionsData.add({
      'version': versions[i].version,
      'status': status,
      'hasDocumentation': hasDocumentation,
    });
  }
  final data = {
    'name': package,
    'latestStableVersion': latestStableVersion,
    'versions': versionsData,
  };
  await cache.dartdocApiSummary(package).set(data);
  return jsonResponse(data);
}

/// Handles requests for
/// - /api/packages?compact=1
Future<shelf.Response> apiPackagesCompactListHandler(
    shelf.Request request) async {
  final packageNames = await nameTracker.getPackageNames();
  packageNames.removeWhere(isSoftRemoved);
  return jsonResponse({'packages': packageNames});
}

/// Handles request for /api/packages?page=<num>
Future<shelf.Response> apiPackagesHandler(shelf.Request request) async {
  final int pageSize = 100;
  final int page = extractPageFromUrlParameters(request.url);

  // Check that we're not at last page (abuse -1 as special index in cache)
  final lastPageCacheEntry = cache.apiPackagesListPage(-1);
  final lastPage = await lastPageCacheEntry.get();
  if (lastPage != null) {
    if (page > (lastPage['page'] as num)) {
      return jsonResponse({'message': 'no content'}, status: 400);
    }
  }

  final data = await cache.apiPackagesListPage(page).get(() async {
    final packages = await backend.latestPackages(
        offset: pageSize * (page - 1), limit: pageSize + 1);

    // NOTE: We queried for `PageSize+1` packages, if we get less than that, we
    // know it was the last page.
    // But we only use `PageSize` packages to display in the result.
    final List<Package> pagePackages = packages.take(pageSize).toList();
    pagePackages.removeWhere((p) => isSoftRemoved(p.name));
    final List<PackageVersion> pageVersions =
        await backend.lookupLatestVersions(pagePackages);

    final lastPage = packages.length == pagePackages.length;

    final packagesJson = [];

    final uri = request.requestedUri;
    for (var version in pageVersions) {
      final versionString = Uri.encodeComponent(version.version);
      final packageString = Uri.encodeComponent(version.package);

      final apiArchiveUrl = uri
          .resolve('/packages/$packageString/versions/$versionString.tar.gz')
          .toString();
      final apiPackageUrl =
          uri.resolve('/api/packages/$packageString').toString();
      final apiPackageVersionUrl = uri
          .resolve('/api/packages/$packageString/versions/$versionString')
          .toString();

      packagesJson.add({
        'name': version.package,
        'latest': {
          'version': version.version,
          'pubspec': version.pubspec.asJson,

          // TODO: We should get rid of these:
          'archive_url': apiArchiveUrl,
          'package_url': apiPackageUrl,
          'url': apiPackageVersionUrl,

          // NOTE: We do not add the following
          //    - 'new_dartdoc_url'
        },
      });
    }

    final json = <String, dynamic>{
      'next_url': null,
      'packages': packagesJson,

      // NOTE: We do not add the following:
      //     - 'pages'
      //     - 'prev_url'
    };

    if (!lastPage) {
      json['next_url'] =
          '${request.requestedUri.resolve('/api/packages?page=${page + 1}')}';
    }
    return json;
  });
  // Return 400, if there is no packages on this page.
  if (data['packages'].length == 0) {
    // Set last page in cache, abuse -1 as special page in cache
    await lastPageCacheEntry.set({'page': page});
    return jsonResponse({'message': 'no content'}, status: 400);
  }
  return jsonResponse(data);
}

/// Whether [requestedUri] matches /api/packages/<package>/metrics
bool isHandlerForApiPackageMetrics(Uri requestedUri) {
  final requestedPath = requestedUri.path;
  final parts = requestedPath.split('/');
  return parts.length == 5 &&
      parts[0] == '' &&
      parts[1] == 'api' &&
      parts[2] == 'packages' &&
      parts[3].isNotEmpty &&
      parts[4] == 'metrics';
}

/// Handles requests for
/// - /api/packages/<package>/metrics
Future<shelf.Response> apiPackageMetricsHandler(
    shelf.Request request, String packageName) async {
  final packageVersion = request.requestedUri.queryParameters['version'];
  final current = request.requestedUri.queryParameters.containsKey('current');
  final data = await scoreCardBackend
      .getScoreCardData(packageName, packageVersion, onlyCurrent: current);
  if (data == null) {
    return jsonResponse({}, status: 404);
  }
  final result = {
    'scorecard': data.toJson(),
  };
  if (request.requestedUri.queryParameters.containsKey('reports')) {
    final reports = await scoreCardBackend.loadReports(
      packageName,
      data.packageVersion,
      runtimeVersion: data.runtimeVersion,
    );
    result['reports'] =
        reports.map((k, report) => MapEntry(k, report.toJson()));
  }
  return jsonResponse(result);
}

/// Handles requests for /api/history
/// NOTE: Experimental, do not rely on it.
Future<shelf.Response> apiHistoryHandler(shelf.Request request) async {
  final list = await historyBackend
      .getAll(
        packageName: request.requestedUri.queryParameters['package'],
        packageVersion: request.requestedUri.queryParameters['version'],
        limit: 25,
      )
      .toList();
  return jsonResponse({
    'results': list
        .map((h) => {
              'id': h.id,
              'package': h.packageName,
              'version': h.packageVersion,
              'timestamp': h.timestamp.toIso8601String(),
              'source': h.source,
              'eventType': h.eventType,
              'eventData': h.eventData,
              'markdown': h.formatMarkdown(),
            })
        .toList(),
  });
}

/// Handles requests for /api/search
Future<shelf.Response> apiSearchHandler(shelf.Request request) async {
  final searchQuery = parseFrontendSearchQuery(request.requestedUri, null);
  final sr = await searchClient.search(searchQuery);
  final packages = sr.packages.map((ps) => {'package': ps.package}).toList();
  final hasNextPage = sr.totalCount > searchQuery.limit + searchQuery.offset;
  final result = <String, dynamic>{
    'packages': packages,
  };
  if (hasNextPage) {
    final newParams =
        Map<String, dynamic>.from(request.requestedUri.queryParameters);
    final nextPageIndex = (searchQuery.offset ~/ searchQuery.limit) + 2;
    newParams['page'] = nextPageIndex.toString();
    final nextPageUrl =
        request.requestedUri.replace(queryParameters: newParams).toString();
    result['next'] = nextPageUrl;
  }
  return jsonResponse(result);
}

/// Handles GET /api/packages/<package>/options
Future<shelf.Response> getPackageOptionsHandler(
    shelf.Request request, String package) async {
  final p = await backend.lookupPackage(package);
  if (p == null) {
    return notFoundHandler(request);
  }
  final options = PkgOptions(isDiscontinued: p.isDiscontinued);
  return jsonResponse(options.toJson());
}

/// Handles PUT /api/packages/<package>/options
Future<shelf.Response> putPackageOptionsHandler(
    shelf.Request request, String package) async {
  try {
    final body = await request.readAsString();
    final options =
        PkgOptions.fromJson(json.decode(body) as Map<String, dynamic>);
    await backend.updateOptions(package, options);
    return jsonResponse({'success': true});
  } on UnauthorizedAccessException catch (_) {
    return jsonResponse({'error': 'Not Authorized.'}, status: 403);
  } on ClientInputException catch (e) {
    return jsonResponse({'error': e.message}, status: e.status);
  } catch (e, st) {
    _logger.warning('Error processing flag update.', e, st);
    return jsonResponse({'error': 'Error while processing request.'},
        status: 500);
  }
}
