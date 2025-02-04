// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_dartlang_org/shared/configuration.dart';

import 'package:pub_dartlang_org/service/entrypoint/analyzer.dart' as analyzer;
import 'package:pub_dartlang_org/service/entrypoint/dartdoc.dart' as dartdoc;
import 'package:pub_dartlang_org/service/entrypoint/frontend.dart' as frontend;
import 'package:pub_dartlang_org/service/entrypoint/search.dart' as search;

void main() {
  switch (envConfig.gaeService) {
    case 'analyzer':
      analyzer.main();
      break;
    case 'dartdoc':
      dartdoc.main();
      break;
    case 'default':
      frontend.main();
      break;
    case 'search':
      search.main();
      break;
    default:
      throw StateError(
          'Uknown GAE_SERVICE environment: ${envConfig.gaeService}');
  }
}
