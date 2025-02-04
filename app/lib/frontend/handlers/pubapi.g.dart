// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubapi.dart';

// **************************************************************************
// ApiRouterGenerator
// **************************************************************************

Router _$PubApiRouter(PubApi service) {
  final router = Router();
  router.add('GET', r'/api/packages/<package>',
      (Request request, String package) async {
    try {
      final _$result = await service.listPackageVersions(request, package);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/packages/<package>/versions/<version>',
      (Request request, String package, String version) async {
    try {
      final _$result =
          await service.packageVersionInfo(request, package, version);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/packages/<package>/versions/<version>.tar.gz',
      (Request request, String package, String version) async {
    try {
      final _$result = await service.fetchPackage(request, package, version);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/packages/<package>/versions/<version>.tar.gz',
      (Request request, String package, String version) async {
    try {
      final _$result = await service.fetchPackage(request, package, version);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/packages/versions/new', (Request request) async {
    try {
      final _$result = await service.getPackageUploadUrl(request);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/packages/versions/newUploadFinish',
      (Request request) async {
    try {
      final _$result = await service.packageUploadCallback(request);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('POST', r'/api/packages/<package>/uploaders',
      (Request request, String package) async {
    try {
      final _$result = await service.addUploader(request, package);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('DELETE', r'/api/packages/<package>/uploaders/<email>',
      (Request request, String package, String email) async {
    try {
      final _$result = await service.removeUploader(request, package, email);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('POST', r'/api/publishers/<publisherId>',
      (Request request, String publisherId) async {
    try {
      final _$result = await service.createPublisher(
          request,
          publisherId,
          await $utilities.decodeJson<CreatePublisherRequest>(request, (o) {
            return CreatePublisherRequest.fromJson(o);
          }));
      return $utilities.jsonResponse(_$result.toJson());
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/publishers/<publisherId>',
      (Request request, String publisherId) async {
    try {
      final _$result = await service.publisherInfo(request, publisherId);
      return $utilities.jsonResponse(_$result.toJson());
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('PUT', r'/api/publishers/<publisherId>',
      (Request request, String publisherId) async {
    try {
      final _$result = await service.updatePublisher(
          request,
          publisherId,
          await $utilities.decodeJson<UpdatePublisherRequest>(request, (o) {
            return UpdatePublisherRequest.fromJson(o);
          }));
      return $utilities.jsonResponse(_$result.toJson());
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('POST', r'/api/publishers/<publisherId>/invite-member',
      (Request request, String publisherId) async {
    try {
      final _$result = await service.invitePublisherMember(
          request,
          publisherId,
          await $utilities.decodeJson<InviteMemberRequest>(request, (o) {
            return InviteMemberRequest.fromJson(o);
          }));
      return $utilities.jsonResponse(_$result.toJson());
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/publishers/<publisherId>/members',
      (Request request, String publisherId) async {
    try {
      final _$result = await service.listPublisherMembers(request, publisherId);
      return $utilities.jsonResponse(_$result.toJson());
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/publishers/<publisherId>/members/<userId>',
      (Request request, String publisherId, String userId) async {
    try {
      final _$result =
          await service.publisherMemberInfo(request, publisherId, userId);
      return $utilities.jsonResponse(_$result.toJson());
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('PUT', r'/api/publishers/<publisherId>/members/<userId>',
      (Request request, String publisherId, String userId) async {
    try {
      final _$result = await service.updatePublisherMember(
          request,
          publisherId,
          userId,
          await $utilities.decodeJson<UpdatePublisherMemberRequest>(request,
              (o) {
            return UpdatePublisherMemberRequest.fromJson(o);
          }));
      return $utilities.jsonResponse(_$result.toJson());
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('DELETE', r'/api/publishers/<publisherId>/members/<userId>',
      (Request request, String publisherId, String userId) async {
    try {
      final _$result =
          await service.removePublisherMember(request, publisherId, userId);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/account/consent/<consentId>',
      (Request request, String consentId) async {
    try {
      final _$result = await service.consentInfo(request, consentId);
      return $utilities.jsonResponse(_$result.toJson());
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('PUT', r'/api/account/consent/<consentId>',
      (Request request, String consentId) async {
    try {
      final _$result = await service.resolveConsent(
          request,
          consentId,
          await $utilities.decodeJson<ConsentResult>(request, (o) {
            return ConsentResult.fromJson(o);
          }));
      return $utilities.jsonResponse(_$result.toJson());
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/account/options/packages/<package>',
      (Request request, String package) async {
    try {
      final _$result = await service.accountPackageOptions(request, package);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/documentation/<package>',
      (Request request, String package) async {
    try {
      final _$result = await service.documentation(request, package);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/history', (Request request) async {
    try {
      final _$result = await service.history(request);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/packages', (Request request) async {
    try {
      final _$result = await service.listPackages(request);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/packages/<package>/metrics',
      (Request request, String package) async {
    try {
      final _$result = await service.packageMetrics(request, package);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/packages/<package>/options',
      (Request request, String package) async {
    try {
      final _$result = await service.packageOptions(request, package);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('PUT', r'/api/packages/<package>/options',
      (Request request, String package) async {
    try {
      final _$result = await service.setPackageOptions(request, package);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/packages/<package>/publisher',
      (Request request, String package) async {
    try {
      final _$result = await service.getPackagePublisher(request, package);
      return $utilities.jsonResponse(_$result.toJson());
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('PUT', r'/api/packages/<package>/publisher',
      (Request request, String package) async {
    try {
      final _$result = await service.setPackagePublisher(
          request,
          package,
          await $utilities.decodeJson<PackagePublisherInfo>(request, (o) {
            return PackagePublisherInfo.fromJson(o);
          }));
      return $utilities.jsonResponse(_$result.toJson());
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('DELETE', r'/api/packages/<package>/publisher',
      (Request request, String package) async {
    try {
      final _$result = await service.removePackagePublisher(request, package);
      return $utilities.jsonResponse(_$result.toJson());
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/search', (Request request) async {
    try {
      final _$result = await service.search(request);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/debug', (Request request) async {
    try {
      final _$result = await service.debug(request);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/packages.json', (Request request) async {
    try {
      final _$result = await service.packages(request);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/packages/<package>.json',
      (Request request, String package) async {
    try {
      final _$result = await service.packageJson(request, package);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('GET', r'/api/admin/users', (Request request) async {
    try {
      final _$result = await service.adminListUsers(request);
      return $utilities.jsonResponse(_$result.toJson());
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  router.add('DELETE', r'/api/admin/users/<userId>',
      (Request request, String userId) async {
    try {
      final _$result = await service.adminRemoveUser(request, userId);
      return _$result;
    } on ApiResponseException catch (e) {
      return e.asApiResponse();
    } catch (e, st) {
      return $utilities.unhandledError(e, st);
    }
  });
  return router;
}
