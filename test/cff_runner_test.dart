import 'dart:io';

import 'package:cff/cff.dart';
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
