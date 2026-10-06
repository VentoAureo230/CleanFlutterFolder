import 'dart:io';

import 'package:path/path.dart' as p;

import '../args/argument_parser.dart';
import '../layout/feature_layout.dart';
import '../naming/feature_name.dart';

/// Creates every file of a feature as an empty file. The boilerplate injector
/// fills them afterwards.
class FileCreator {
  void create(Directory featureDir, FeatureName name, StateManagement state) {
    for (final layoutFile in FeatureLayout.filesFor(state)) {
      // exclusive: fail rather than touch a file that already exists.
      File(
        p.join(featureDir.path, layoutFile.resolvePath(name)),
      ).createSync(recursive: true, exclusive: true);
    }
  }
}
