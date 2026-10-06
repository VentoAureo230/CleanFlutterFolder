import 'dart:io';

import 'package:mason_logger/mason_logger.dart';

import '../args/argument_parser.dart';

typedef ChooseState =
    StateManagement Function(
      List<StateManagement> choices,
      StateManagement defaultValue,
    );

/// Decides between Cubit and BLoC: the `--state` flag, else an arrow-key
/// prompt, else Cubit when no interactive terminal is attached.
class StatePicker {
  static const defaultState = StateManagement.cubit;

  final bool Function() _hasTerminal;
  final ChooseState _choose;
  final StringSink _out;

  StatePicker({
    bool Function()? hasTerminal,
    ChooseState? choose,
    StringSink? out,
  }) : _hasTerminal =
           hasTerminal ?? (() => stdin.hasTerminal && stdout.hasTerminal),
       _choose = choose ?? _chooseWithMasonLogger,
       _out = out ?? stdout;

  StateManagement resolve(StateManagement? fromFlag) {
    if (fromFlag != null) return fromFlag;

    if (!_hasTerminal()) return _fallBack();

    try {
      // Cubit first, so the default sits at the top of the list.
      return _choose(const [
        StateManagement.cubit,
        StateManagement.bloc,
      ], defaultState);
    } on StdinException {
      // Some shells (e.g. Git Bash on Windows) report a terminal that can't
      // be switched to raw mode, which the arrow-key prompt needs.
      return _fallBack();
    }
  }

  StateManagement _fallBack() {
    _out.writeln(
      'No interactive terminal: using ${_label(defaultState)} '
      '(pass --state to choose).',
    );
    return defaultState;
  }

  static StateManagement _chooseWithMasonLogger(
    List<StateManagement> choices,
    StateManagement defaultValue,
  ) {
    return Logger().chooseOne(
      'Which state management?',
      choices: choices,
      defaultValue: defaultValue,
      display: _label,
    );
  }

  static String _label(StateManagement state) => switch (state) {
    StateManagement.cubit => 'Cubit',
    StateManagement.bloc => 'BLoC',
  };
}
