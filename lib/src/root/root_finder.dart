import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../cff_exception.dart';

/// Walks up from a starting folder to the root of the enclosing Flutter project.
class RootFinder {
  Directory find(Directory start) {
    var dir = start.absolute;

    while (true) {
      final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        if (_dependsOnFlutter(pubspec)) return dir;
        throw CffException(
          'Not a Flutter project: ${pubspec.path} does not depend on the '
          'Flutter SDK.',
        );
      }

      final parent = dir.parent;
      // The parent of the file system root is the root itself.
      if (parent.path == dir.path) {
        throw CffException(
          'No pubspec.yaml found in ${start.absolute.path} or any parent '
          'folder. Run cff inside a Flutter project.',
        );
      }
      dir = parent;
    }
  }

  /// True when the pubspec declares `dependencies: flutter: sdk: flutter`.
  bool _dependsOnFlutter(File pubspec) {
    final Object? document;
    try {
      document = loadYaml(pubspec.readAsStringSync());
    } on YamlException catch (e) {
      throw CffException('Could not read ${pubspec.path}: ${e.message}');
    }

    if (document is! YamlMap) return false;
    final dependencies = document['dependencies'];
    if (dependencies is! YamlMap) return false;
    final flutter = dependencies['flutter'];
    return flutter is YamlMap && flutter['sdk'] == 'flutter';
  }
}
