import 'dart:io';

import 'package:cff/src/cff_exception.dart';
import 'package:cff/src/root/root_finder.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  final finder = RootFinder();

  test('finds the root from the root folder itself', () {
    final project = writePubspec(createTempDir(), flutterPubspec, 'app');
    expect(finder.find(project).path, project.absolute.path);
  });

  test('finds the root from a nested subfolder', () {
    final project = writePubspec(createTempDir(), flutterPubspec, 'app');
    final nested = Directory(p.join(project.path, 'lib', 'core', 'utils'))
      ..createSync(recursive: true);
    expect(finder.find(nested).path, project.absolute.path);
  });

  test('fails when the nearest pubspec is not a Flutter project', () {
    final package = writePubspec(createTempDir(), dartPubspec, 'pkg');
    expect(
      () => finder.find(package),
      throwsA(
        isA<CffException>().having(
          (e) => e.message,
          'message',
          contains('Not a Flutter project'),
        ),
      ),
    );
  });

  test('stops at the first pubspec even if a Flutter one is higher up', () {
    final app = writePubspec(createTempDir(), flutterPubspec, 'app');
    final inner = writePubspec(app, dartPubspec, 'packages/inner');
    expect(() => finder.find(inner), throwsA(isA<CffException>()));
  });

  test(
    'fails with "no pubspec found" when none exists up to the file system root',
    () {
      // Only meaningful when the temp folder has no pubspec above it.
      final empty = createTempDir();
      expect(
        () => finder.find(empty),
        throwsA(
          isA<CffException>().having(
            (e) => e.message,
            'message',
            contains('No pubspec.yaml found'),
          ),
        ),
      );
    },
  );
}
