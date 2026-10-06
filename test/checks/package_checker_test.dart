import 'dart:io';

import 'package:cff/src/checks/package_checker.dart';
import 'package:cff/src/root/root_finder.dart';
import 'package:test/test.dart';

void main() {
  final checker = PackageChecker();

  FlutterProject projectWith(Set<String> dependencies) =>
      FlutterProject(Directory('app'), 'demo_app', dependencies);

  final all = {
    ...PackageChecker.runtimePackages,
    ...PackageChecker.devPackages,
  };

  test('reports nothing when every package is declared', () {
    expect(checker.check(projectWith(all)).isEmpty, isTrue);
  });

  test('reports missing runtime and dev packages separately', () {
    final missing = checker.check(
      projectWith(all.difference({'dio', 'build_runner'})),
    );
    expect(missing.runtime, ['dio']);
    expect(missing.dev, ['build_runner']);
  });

  test('reports the generator even when retrofit is declared', () {
    final missing = checker.check(
      projectWith(all.difference({'retrofit_generator'})),
    );
    expect(missing.runtime, isEmpty);
    expect(missing.dev, ['retrofit_generator']);
  });
}
