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

/// A Flutter pubspec declaring every package the generated code needs.
const completeFlutterPubspec = '''
name: demo_app
dependencies:
  flutter:
    sdk: flutter
  equatable: ^2.0.0
  flutter_bloc: ^9.0.0
  get_it: ^8.0.0
  retrofit: ^4.0.0
  dio: ^5.0.0
dev_dependencies:
  retrofit_generator: ^9.0.0
  build_runner: ^2.4.0
''';
