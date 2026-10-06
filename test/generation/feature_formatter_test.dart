import 'dart:io';

import 'package:cff/src/generation/feature_formatter.dart';
import 'package:test/test.dart';

void main() {
  final featureDir = Directory('app/lib/feature/owl');
  final projectRoot = Directory('app');

  FeatureFormatter formatterReturning(int exitCode) => FeatureFormatter(
    runProcess: (executable, arguments, {workingDirectory}) async =>
        ProcessResult(0, exitCode, '', ''),
  );

  test('formats only the feature folder, from the project root', () async {
    late List<String> calledWith;
    String? calledIn;
    final formatter = FeatureFormatter(
      runProcess: (executable, arguments, {workingDirectory}) async {
        calledWith = arguments;
        calledIn = workingDirectory;
        return ProcessResult(0, 0, '', '');
      },
    );

    expect(await formatter.format(featureDir, projectRoot), isNull);
    expect(calledWith, ['format', featureDir.path]);
    expect(calledIn, projectRoot.path);
  });

  test('warns with the manual command when dart cannot start', () async {
    final formatter = FeatureFormatter(
      runProcess: (executable, arguments, {workingDirectory}) =>
          throw const ProcessException('dart', [], 'not found'),
    );

    final warning = await formatter.format(featureDir, projectRoot);
    expect(warning, contains('not found'));
    expect(warning, contains('Run: dart format ${featureDir.path}'));
  });

  test('flags unparseable code as a likely cff bug', () async {
    expect(
      await formatterReturning(65).format(featureDir, projectRoot),
      contains('likely a cff bug'),
    );
  });

  test('warns on any other exit code', () async {
    expect(
      await formatterReturning(1).format(featureDir, projectRoot),
      contains('dart format exited with 1'),
    );
  });
}
