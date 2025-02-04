// GENERATED CODE - DO NOT MODIFY BY HAND

part of pub_dartlang_org.handlers_redirects;

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$PubDartlangOrgServiceRouter(PubDartlangOrgService service) {
  final router = Router();
  router.add('GET', '/doc', service.doc);
  router.add('GET', '/doc/<path|[^]*>', service.doc);
  router.add('GET', '/server', service.server);
  router.add('GET', '/flutter/plugins', service.flutterPlugins);
  router.add('GET', '/server/packages', service.serverPackages);
  router.add('GET', '/search', service.search);
  return router;
}

Router _$LegacyDartdocServiceRouter(LegacyDartdocService service) {
  final router = Router();
  router.add('GET', '/', service.index);
  router.add('GET', '/documentation', service.documentation);
  router.add('GET', '/documentation/<path|[^]*>', service.documentation);
  router.all('/<_|.*>', service.catchAll);
  return router;
}
