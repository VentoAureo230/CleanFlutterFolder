import 'dart:io';

import '../cff_exception.dart';
import '../layout/feature_layout.dart';
import '../naming/feature_name.dart';

class DuplicateFeatureChecker {
  void check(Directory projectRoot, FeatureName name) {
    final featurePath = FeatureLayout.featurePath(projectRoot.path, name);
    if (FileSystemEntity.typeSync(featurePath) !=
        FileSystemEntityType.notFound) {
      throw CffException('Feature "$name" already exists at $featurePath.');
    }
  }
}
