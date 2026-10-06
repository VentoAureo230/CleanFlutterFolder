import 'dart:io';

typedef RunProcess =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    });

/// Runs `dart format` on a generated feature folder. Formatting is a nicety:
/// failures are reported as a warning, never as an error.
class FeatureFormatter {
  /// `dart format` exit code for source that can't be parsed.
  static const _parseErrorExitCode = 65;

  final RunProcess _runProcess;

  FeatureFormatter({RunProcess? runProcess})
    : _runProcess = runProcess ?? Process.run;

  /// Returns a warning, or `null` when the folder was formatted.
  Future<String?> format(Directory featureDir, Directory projectRoot) async {
    final ProcessResult result;
    try {
      // The `dart` running cff; inside the project, so `dart format` uses its
      // language version and formatter settings.
      result = await _runProcess(Platform.resolvedExecutable, [
        'format',
        featureDir.path,
      ], workingDirectory: projectRoot.path);
    } on ProcessException catch (e) {
      return _warning(featureDir, e.message);
    }

    return switch (result.exitCode) {
      0 => null,
      _parseErrorExitCode => _warning(
        featureDir,
        'the generated code could not be parsed, which is likely a cff bug',
      ),
      final code => _warning(featureDir, 'dart format exited with $code'),
    };
  }

  String _warning(Directory featureDir, String reason) =>
      'Warning: could not format the generated files ($reason). '
      'Run: dart format ${featureDir.path}';
}
