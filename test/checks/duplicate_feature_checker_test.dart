import 'dart:io';

import 'package:cff/src/cff_exception.dart';
import 'package:cff/src/checks/duplicate_feature_checker.dart';
import 'package:cff/src/naming/feature_name.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  final checker = DuplicateFeatureChecker();
  const owl = FeatureName('owl');

  test('passes when the feature folder does not exist', () {
    checker.check(createTempDir(), owl);
  });

  test('fails when the feature folder already exists', () {
    final root = createTempDir();
    Directory(
      p.join(root.path, 'lib', 'feature', 'owl'),
    ).createSync(recursive: true);
    expect(() => checker.check(root, owl), throwsA(isA<CffException>()));
  });

  test('fails when a file has the feature name', () {
    final root = createTempDir();
    Directory(p.join(root.path, 'lib', 'feature')).createSync(recursive: true);
    File(p.join(root.path, 'lib', 'feature', 'owl')).writeAsStringSync('');
    expect(() => checker.check(root, owl), throwsA(isA<CffException>()));
  });
}
