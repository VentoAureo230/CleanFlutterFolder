import 'dart:io';

import 'args/argument_parser.dart';
import 'cff_exception.dart';
import 'checks/duplicate_feature_checker.dart';
import 'checks/package_checker.dart';
import 'generation/boilerplate_injector.dart';
import 'generation/core_file_creator.dart';
import 'generation/feature_formatter.dart';
import 'generation/file_creator.dart';
import 'generation/folder_generator.dart';
import 'layout/feature_layout.dart';
import 'naming/feature_name.dart';
import 'prompt/state_picker.dart';
import 'root/root_finder.dart';
import 'validation/feature_name_validator.dart';

/// Runs every step of `cff` in order and returns the process exit code.
class CffRunner {
  /// Exit code for a command called with wrong arguments.
  static const usageExitCode = 64;

  final StringSink _out;
  final StringSink _err;

  final _argumentParser = CffArgumentParser();
  final _featureNameValidator = FeatureNameValidator();
  final _rootFinder = RootFinder();
  final _duplicateFeatureChecker = DuplicateFeatureChecker();
  final _packageChecker = PackageChecker();
  final StatePicker _statePicker;
  final _coreFileCreator = CoreFileCreator();
  final _folderGenerator = FolderGenerator();
  final _fileCreator = FileCreator();
  final _boilerplateInjector = BoilerplateInjector();
  final FeatureFormatter _featureFormatter;

  CffRunner({
    StringSink? out,
    StringSink? err,
    StatePicker? statePicker,
    FeatureFormatter? featureFormatter,
  }) : _out = out ?? stdout,
       _err = err ?? stderr,
       _statePicker = statePicker ?? StatePicker(out: out),
       _featureFormatter = featureFormatter ?? FeatureFormatter();

  Future<int> run(List<String> arguments, {Directory? workingDir}) async {
    try {
      final parsed = _argumentParser.parse(arguments);
      if (parsed == null) {
        _out.writeln(_argumentParser.usage);
        return 0;
      }

      _featureNameValidator.validate(parsed.featureName);
      final project = _rootFinder.find(workingDir ?? Directory.current);
      final projectRoot = project.root;
      _warnMissingPackages(_packageChecker.check(project));
      final name = FeatureName(parsed.featureName);
      _duplicateFeatureChecker.check(projectRoot, name);

      final state = _statePicker.resolve(parsed.state);
      final featureDir = Directory(
        FeatureLayout.featurePath(projectRoot.path, name),
      );

      try {
        // Core first: if the feature fails later, a retry skips them.
        for (final path in _coreFileCreator.create(projectRoot, name)) {
          _out.writeln('Created core file $path');
        }
        _folderGenerator.generate(featureDir);
        _fileCreator.create(featureDir, name, state);
        _boilerplateInjector.inject(
          featureDir,
          name,
          state,
          project.packageName,
        );
      } on FileSystemException catch (e) {
        throw CffException(_generationFailure(e, featureDir, name));
      }

      final formatWarning = await _featureFormatter.format(
        featureDir,
        projectRoot,
      );
      if (formatWarning != null) _out.writeln(formatWarning);

      _out
        ..writeln(
          'Created feature "$name" (${state.name}) at ${featureDir.path}.',
        )
        ..writeln()
        ..writeln('Next steps:')
        ..writeln(
          '  1. Generate the retrofit code: '
          'dart run build_runner build --delete-conflicting-outputs',
        )
        ..writeln(
          '  2. Call register${name.pascal}Dependencies(sl) in your GetIt '
          'setup, after Dio is registered.',
        );
      return 0;
    } on CffUsageException catch (e) {
      _err
        ..writeln('Error: ${e.message}')
        ..writeln()
        ..writeln(_argumentParser.usage);
      return usageExitCode;
    } on CffException catch (e) {
      _err.writeln('Error: ${e.message}');
      return 1;
    }
  }

  void _warnMissingPackages(MissingPackages missing) {
    if (missing.isEmpty) return;
    _out.writeln(
      'Warning: the generated code needs packages this project does not '
      'declare yet. Add them with:',
    );
    if (missing.runtime.isNotEmpty) {
      _out.writeln('  flutter pub add ${missing.runtime.join(' ')}');
    }
    if (missing.dev.isNotEmpty) {
      _out.writeln(
        '  flutter pub add ${missing.dev.map((p) => 'dev:$p').join(' ')}',
      );
    }
    _out.writeln();
  }

  String _generationFailure(
    FileSystemException e,
    Directory featureDir,
    FeatureName name,
  ) {
    final reason = e.osError?.message ?? e.message;
    final message = StringBuffer(
      'Generation failed at ${e.path ?? 'an unknown path'}: $reason.',
    );
    if (featureDir.existsSync()) {
      message.write(
        ' A partial ${featureDir.path} was left in place. '
        'Delete it before running `cff $name` again.',
      );
    }
    return message.toString();
  }
}
