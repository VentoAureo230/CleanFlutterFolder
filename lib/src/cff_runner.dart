import 'dart:io';

import 'args/argument_parser.dart';
import 'cff_exception.dart';
import 'checks/duplicate_feature_checker.dart';
import 'generation/core_file_creator.dart';
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
  final StatePicker _statePicker;
  final _coreFileCreator = CoreFileCreator();
  final _folderGenerator = FolderGenerator();
  final _fileCreator = FileCreator();

  CffRunner({StringSink? out, StringSink? err, StatePicker? statePicker})
    : _out = out ?? stdout,
      _err = err ?? stderr,
      _statePicker = statePicker ?? StatePicker(out: out);

  Future<int> run(List<String> arguments, {Directory? workingDir}) async {
    try {
      final parsed = _argumentParser.parse(arguments);
      if (parsed == null) {
        _out.writeln(_argumentParser.usage);
        return 0;
      }

      _featureNameValidator.validate(parsed.featureName);
      final projectRoot = _rootFinder.find(workingDir ?? Directory.current);
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
        // TODO(step 4): inject boilerplate into the empty files.
      } on FileSystemException catch (e) {
        throw CffException(_generationFailure(e, featureDir, name));
      }

      // TODO(step 5): check packages; print final messages.
      _out.writeln(
        'Created feature "$name" (${state.name}) at ${featureDir.path} '
        '(files are empty until templates are added).',
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
