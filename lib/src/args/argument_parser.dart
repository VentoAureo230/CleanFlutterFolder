import 'package:args/args.dart';

import '../cff_exception.dart';

enum StateManagement { cubit, bloc }

/// The parsed command line.
class CffArguments {
  final String featureName;

  /// `null` when `--state` was not given; resolved later (picker or default).
  final StateManagement? state;

  const CffArguments({required this.featureName, this.state});
}

class CffArgumentParser {
  final ArgParser _parser = ArgParser()
    ..addOption(
      'state',
      abbr: 's',
      allowed: StateManagement.values.map((value) => value.name),
      help: 'State management to generate. Asked interactively if omitted.',
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help.');

  String get usage =>
      'Usage: dart run cff <feature-name> [--state <cubit|bloc>]\n\n'
      '${_parser.usage}';

  /// Returns `null` when help was requested.
  CffArguments? parse(List<String> arguments) {
    final ArgResults results;
    try {
      results = _parser.parse(arguments);
    } on FormatException catch (e) {
      throw CffUsageException(e.message);
    }

    if (results.flag('help')) return null;

    if (results.rest.isEmpty) {
      throw const CffUsageException('Missing feature name.');
    }
    if (results.rest.length > 1) {
      throw CffUsageException(
        'Expected one feature name, got: ${results.rest.join(' ')}',
      );
    }

    final state = results.option('state');
    return CffArguments(
      featureName: results.rest.single,
      state: state == null ? null : StateManagement.values.byName(state),
    );
  }
}
