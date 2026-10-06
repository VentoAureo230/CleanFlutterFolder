import 'dart:io';

import 'package:path/path.dart' as p;

import '../layout/feature_layout.dart';

/// Creates every folder of a feature, including the ones left empty.
class FolderGenerator {
  void generate(Directory featureDir) {
    for (final folder in FeatureLayout.folders) {
      Directory(
        p.joinAll([featureDir.path, ...folder.split('/')]),
      ).createSync(recursive: true);
    }
  }
}
