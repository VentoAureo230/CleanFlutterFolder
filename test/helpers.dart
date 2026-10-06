import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const flutterPubspec = '''
name: demo_app
dependencies:
  flutter:
    sdk: flutter
''';

const dartPubspec = '''
name: demo_package
dependencies:
  path: ^1.9.0
''';

/// Creates a temporary folder that is deleted after the current test.
Directory createTempDir() {
  final dir = Directory.systemTemp.createTempSync('cff_test_');
  addTearDown(() => dir.deleteSync(recursive: true));
  return dir;
}

/// Creates `<parent>/<relativePath>/pubspec.yaml` with [content].
Directory writePubspec(
  Directory parent,
  String content, [
  String relativePath = '',
]) {
  final dir = Directory(p.join(parent.path, relativePath))
    ..createSync(recursive: true);
  File(p.join(dir.path, 'pubspec.yaml')).writeAsStringSync(content);
  return dir;
}
