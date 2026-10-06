import 'dart:io';

import 'package:cff/src/args/argument_parser.dart';
import 'package:cff/src/generation/boilerplate_injector.dart';
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
    test('creates missing core files with content and reports them', () {
      final root = createTempDir();
      final created = CoreFileCreator().create(root, owl);

      expect(created, hasLength(2));
      expect(
        File(
          p.join(root.path, 'lib', 'core', 'resources', 'data_state.dart'),
        ).readAsStringSync(),
        contains('class DataSuccess<T> extends DataState<T>'),
      );
      expect(
        File(
          p.join(root.path, 'lib', 'core', 'usecases', 'usecase.dart'),
        ).readAsStringSync(),
        contains('abstract class Usecase<Type, Params>'),
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

  group('BoilerplateInjector', () {
    Directory generate(FeatureName name, StateManagement state) {
      final featureDir = Directory(p.join(createTempDir().path, name.snake));
      FileCreator().create(featureDir, name, state);
      BoilerplateInjector().inject(featureDir, name, state, 'demo_app');
      return featureDir;
    }

    String read(Directory featureDir, String relativePath) => File(
      p.joinAll([featureDir.path, ...relativePath.split('/')]),
    ).readAsStringSync();

    test('fills every file of the variant', () {
      for (final state in StateManagement.values) {
        final featureDir = generate(owl, state);
        for (final file in FeatureLayout.filesFor(state)) {
          expect(
            read(featureDir, p.split(file.resolvePath(owl)).join('/')),
            isNotEmpty,
            reason: '${state.name}: ${file.path}',
          );
        }
      }
    });

    test('uses the name variants and the package name', () {
      const name = FeatureName('user_profile');
      final featureDir = generate(name, StateManagement.cubit);
      final cubit = read(
        featureDir,
        'presentation/bloc/user_profile_cubit.dart',
      );

      expect(
        cubit,
        contains('class UserProfileCubit extends Cubit<UserProfileState>'),
      );
      expect(cubit, contains('final previous = state.userProfileEntity;'));
      expect(
        cubit,
        contains(
          "import 'package:demo_app/feature/user_profile/domain/entities/user_profile.dart';",
        ),
      );
    });

    test('writes the page and dependencies of the chosen variant', () {
      final cubitDir = generate(owl, StateManagement.cubit);
      expect(read(cubitDir, 'owl_dependencies.dart'), contains('OwlCubit('));
      expect(
        read(cubitDir, 'presentation/pages/owl_page.dart'),
        contains('GetIt.instance<OwlCubit>()..fetch()'),
      );

      final blocDir = generate(owl, StateManagement.bloc);
      expect(read(blocDir, 'owl_dependencies.dart'), contains('OwlBloc('));
      expect(
        read(blocDir, 'presentation/pages/owl_page.dart'),
        contains('..add(const OwlFetchRequested())'),
      );
    });
  });
}
