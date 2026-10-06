import 'dart:io';

import 'package:path/path.dart' as p;

import '../layout/feature_layout.dart';
import '../naming/feature_name.dart';
import '../templates/templates.dart';

/// Creates the shared core files that don't exist yet, with their content.
/// Never overwrites.
class CoreFileCreator {
  /// Returns the paths (relative to [projectRoot]) of the files it created.
  List<String> create(Directory projectRoot, FeatureName name) {
    final created = <String>[];
    for (final layoutFile in FeatureLayout.coreFiles) {
      final relativePath = layoutFile.resolvePath(name);
      final file = File(p.join(projectRoot.path, relativePath));
      if (file.existsSync()) continue;

      file
        ..createSync(recursive: true, exclusive: true)
        ..writeAsStringSync(templateFor(layoutFile.template));
      created.add(relativePath);
    }
    return created;
  }
}
