import 'dart:io';

import 'package:cff/cff.dart';
import 'package:cff/src/generation/feature_formatter.dart';
import 'package:cff/src/prompt/state_picker.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late StringBuffer out;
  late StringBuffer err;
  late CffRunner runner;

  setUp(() {
    out = StringBuffer();
    err = StringBuffer();
    runner = CffRunner(out: out, err: err);
  });

  test('generates core files and the feature tree from a subfolder', () async {
    final project = writePubspec(createTempDir(), flutterPubspec, 'app');
    final nested = Directory(p.join(project.path, 'lib'))..createSync();

    final code = await runner.run([
      'owl',
      '--state',
      'cubit',
    ], workingDir: nested);

    expect(code, 0, reason: err.toString());
    expect(out.toString(), contains('Created feature "owl" (cubit)'));
    expect(out.toString(), contains('Created core file'));
    expect(err.toString(), isEmpty);

    final feature = p.join(project.path, 'lib', 'feature', 'owl');
    expect(
      File(
        p.join(feature, 'presentation', 'bloc', 'owl_cubit.dart'),
      ).existsSync(),
      isTrue,
    );
    expect(
      Directory(p.join(feature, 'presentation', 'pages')).existsSync(),
      isTrue,
    );
    expect(
      File(
        p.join(project.path, 'lib', 'core', 'usecases', 'usecase.dart'),
      ).existsSync(),
      isTrue,
    );
  });

  test(
    'warns about missing packages before generating, then proceeds',
    () async {
      final project = writePubspec(createTempDir(), flutterPubspec, 'app');

      expect(await runner.run(['owl', '-s', 'cubit'], workingDir: project), 0);

      final output = out.toString();
      expect(
        output,
        contains('flutter pub add equatable flutter_bloc get_it retrofit dio'),
      );
      expect(
        output,
        contains('flutter pub add dev:retrofit_generator dev:build_runner'),
      );
      expect(
        output.indexOf('Warning:'),
        lessThan(output.indexOf('Created feature')),
      );
      expect(err.toString(), isEmpty);
    },
  );

  test('prints no warning when every package is declared', () async {
    final project = writePubspec(
      createTempDir(),
      completeFlutterPubspec,
      'app',
    );

    expect(await runner.run(['owl', '-s', 'cubit'], workingDir: project), 0);
    expect(out.toString(), isNot(contains('Warning:')));
  });

  test('ends with the build_runner and registration steps', () async {
    final project = writePubspec(
      createTempDir(),
      completeFlutterPubspec,
      'app',
    );

    expect(
      await runner.run(['user_profile', '-s', 'bloc'], workingDir: project),
      0,
    );
    expect(
      out.toString(),
      contains('dart run build_runner build --delete-conflicting-outputs'),
    );
    expect(out.toString(), contains('registerUserProfileDependencies(sl)'));
  });

  for (final state in ['cubit', 'bloc']) {
    test('generates Dart code that parses ($state)', () async {
      final project = writePubspec(createTempDir(), flutterPubspec, 'app');

      expect(
        await runner.run(['user_profile', '-s', state], workingDir: project),
        0,
        reason: err.toString(),
      );

      // `dart format` exits with 65 when a file can't be parsed.
      final format = await Process.run(Platform.resolvedExecutable, [
        'format',
        '--output=none',
        p.join(project.path, 'lib'),
      ]);
      expect(format.exitCode, 0, reason: '${format.stdout}${format.stderr}');
    });
  }

  test(
    'feature names matching template identifiers produce no name conflicts',
    () async {
      final project = writePubspec(createTempDir(), flutterPubspec, 'app');
      const names = ['id', 'state', 'error', 'key', 'operation', 'props'];
      for (final (index, name) in names.indexed) {
        final state = index.isEven ? 'cubit' : 'bloc';
        expect(
          await runner.run([name, '-s', state], workingDir: project),
          0,
          reason: err.toString(),
        );
      }

      // Packages aren't installed, so only name-conflict codes are checked.
      final analyze = await Process.run(Platform.resolvedExecutable, [
        'analyze',
        '--format=machine',
        p.join(project.path, 'lib', 'feature'),
      ]);
      final conflicts = '${analyze.stdout}${analyze.stderr}'
          .split('\n')
          .where(
            (line) => RegExp(
              'DUPLICATE_DEFINITION|REFERENCED_BEFORE_DECLARATION|'
              'DUPLICATE_FIELD_FORMAL_PARAMETER',
            ).hasMatch(line),
          )
          .toList();
      expect(conflicts, isEmpty);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test('formats the generated feature', () async {
    final project = writePubspec(createTempDir(), flutterPubspec, 'app');

    expect(
      await runner.run(['user_profile', '-s', 'bloc'], workingDir: project),
      0,
    );

    final check = await Process.run(Platform.resolvedExecutable, [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      p.join(project.path, 'lib', 'feature', 'user_profile'),
    ]);
    expect(check.exitCode, 0, reason: '${check.stdout}');
    expect(out.toString(), isNot(contains('could not format')));
  });

  test('a formatting failure warns and still succeeds', () async {
    final project = writePubspec(createTempDir(), flutterPubspec, 'app');
    final runner = CffRunner(
      out: out,
      err: err,
      featureFormatter: FeatureFormatter(
        runProcess: (executable, arguments, {workingDirectory}) =>
            throw const ProcessException('dart', [], 'not found'),
      ),
    );

    expect(await runner.run(['owl', '-s', 'cubit'], workingDir: project), 0);
    expect(out.toString(), contains('could not format the generated files'));
    expect(out.toString(), contains('Created feature "owl"'));
    expect(err.toString(), isEmpty);
  });

  test('reports a file system failure during generation', () async {
    final project = writePubspec(createTempDir(), flutterPubspec, 'app');
    // A file where the lib/feature folder should be makes generation fail.
    File(p.join(project.path, 'lib', 'feature')).createSync(recursive: true);

    expect(await runner.run(['owl', '-s', 'cubit'], workingDir: project), 1);
    expect(err.toString(), contains('Generation failed at'));
  });

  test('falls back to Cubit without --state and without a terminal', () async {
    final project = writePubspec(createTempDir(), flutterPubspec, 'app');
    final runner = CffRunner(
      out: out,
      err: err,
      statePicker: StatePicker(hasTerminal: () => false, out: out),
    );

    expect(await runner.run(['owl'], workingDir: project), 0);
    expect(out.toString(), contains('No interactive terminal'));
    expect(out.toString(), contains('"owl" (cubit)'));
  });

  test('prints usage and returns 0 for --help', () async {
    expect(await runner.run(['--help']), 0);
    expect(out.toString(), contains('Usage: dart run cff'));
  });

  test('returns 64 with usage for a missing feature name', () async {
    expect(await runner.run([]), CffRunner.usageExitCode);
    expect(err.toString(), contains('Missing feature name'));
    expect(err.toString(), contains('Usage: dart run cff'));
  });

  test('returns 1 for an invalid feature name', () async {
    final project = writePubspec(createTempDir(), flutterPubspec, 'app');
    expect(await runner.run(['UserProfile'], workingDir: project), 1);
    expect(err.toString(), contains('Invalid feature name'));
  });

  test('returns 1 outside a Flutter project', () async {
    final package = writePubspec(createTempDir(), dartPubspec, 'pkg');
    expect(await runner.run(['owl'], workingDir: package), 1);
    expect(err.toString(), contains('Not a Flutter project'));
  });

  test('returns 1 when the feature already exists', () async {
    final project = writePubspec(createTempDir(), flutterPubspec, 'app');
    Directory(
      p.join(project.path, 'lib', 'feature', 'owl'),
    ).createSync(recursive: true);
    expect(await runner.run(['owl'], workingDir: project), 1);
    expect(err.toString(), contains('already exists'));
  });
}
