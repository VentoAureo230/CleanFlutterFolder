import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../cff_exception.dart';

/// The Flutter project `cff` generates into.
class FlutterProject {
  final Directory root;

  /// The pubspec `name`, used in `package:` imports.
  final String packageName;

  /// Package names under `dependencies` and `dev_dependencies`.
  final Set<String> dependencies;

  const FlutterProject(this.root, this.packageName, this.dependencies);
}

/// Walks up from a starting folder to the root of the enclosing Flutter project.
class RootFinder {
  FlutterProject find(Directory start) {
    var dir = start.absolute;

    while (true) {
      final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) return _readProject(dir, pubspec);

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

  FlutterProject _readProject(Directory dir, File pubspec) {
    final Object? document;
    try {
      document = loadYaml(pubspec.readAsStringSync());
    } on YamlException catch (e) {
      throw CffException('Could not read ${pubspec.path}: ${e.message}');
    }

    if (!_dependsOnFlutter(document)) {
      throw CffException(
        'Not a Flutter project: ${pubspec.path} does not depend on the '
        'Flutter SDK.',
      );
    }

    final name = (document as YamlMap)['name'];
    if (name is! String || name.isEmpty) {
      throw CffException('${pubspec.path} has no package name (`name:`).');
    }
    return FlutterProject(dir, name, {
      ..._packageNames(document['dependencies']),
      ..._packageNames(document['dev_dependencies']),
    });
  }

  Iterable<String> _packageNames(Object? section) =>
      section is YamlMap ? section.keys.whereType<String>() : const [];

  /// True when the pubspec declares `dependencies: flutter: sdk: flutter`.
  bool _dependsOnFlutter(Object? document) {
    if (document is! YamlMap) return false;
    final dependencies = document['dependencies'];
    if (dependencies is! YamlMap) return false;
    final flutter = dependencies['flutter'];
    return flutter is YamlMap && flutter['sdk'] == 'flutter';
  }
}
