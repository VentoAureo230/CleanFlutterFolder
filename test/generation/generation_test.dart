import 'dart:io';

import 'package:cff/src/args/argument_parser.dart';
import 'package:cff/src/generation/core_file_creator.dart';
import 'package:cff/src/generation/file_creator.dart';
import 'package:cff/src/generation/folder_generator.dart';
import 'package:cff/src/layout/feature_layout.dart';
import 'package:cff/src/naming/feature_name.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  const owl = FeatureName('owl');

  group('CoreFileCreator', () {
    test('creates missing core files and reports them', () {
      final root = createTempDir();
      final created = CoreFileCreator().create(root, owl);

      expect(created, hasLength(2));
      expect(
        File(
          p.join(root.path, 'lib', 'core', 'resources', 'data_state.dart'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(root.path, 'lib', 'core', 'usecases', 'usecase.dart'),
        ).existsSync(),
        isTrue,
      );
    });

    test('skips existing core files without changing them', () {
      final root = createTempDir();
      final existing = File(
        p.join(root.path, 'lib', 'core', 'resources', 'data_state.dart'),
      )..createSync(recursive: true);
      existing.writeAsStringSync('// mine');

      final created = CoreFileCreator().create(root, owl);

      expect(created.map((path) => p.basename(path)), ['usecase.dart']);
      expect(existing.readAsStringSync(), '// mine');
    });
  });

  test('FolderGenerator creates every folder, including empty ones', () {
    final featureDir = Directory(p.join(createTempDir().path, 'owl'));
    FolderGenerator().generate(featureDir);

    for (final folder in FeatureLayout.folders) {
      expect(
        Directory(
          p.joinAll([featureDir.path, ...folder.split('/')]),
        ).existsSync(),
        isTrue,
        reason: folder,
      );
    }
  });

  group('FileCreator', () {
    test('creates every file of the variant, empty', () {
      final featureDir = Directory(p.join(createTempDir().path, 'owl'));
      FileCreator().create(featureDir, owl, StateManagement.bloc);

      for (final file in FeatureLayout.filesFor(StateManagement.bloc)) {
        final created = File(p.join(featureDir.path, file.resolvePath(owl)));
        expect(created.existsSync(), isTrue, reason: file.path);
        expect(created.lengthSync(), 0, reason: file.path);
      }
    });

    test('refuses to overwrite an existing file', () {
      final featureDir = Directory(p.join(createTempDir().path, 'owl'));
      File(p.join(featureDir.path, 'owl_dependencies.dart'))
        ..createSync(recursive: true)
        ..writeAsStringSync('// mine');

      expect(
        () => FileCreator().create(featureDir, owl, StateManagement.cubit),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}
