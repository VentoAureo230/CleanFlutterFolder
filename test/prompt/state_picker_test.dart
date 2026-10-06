import 'dart:io';

import 'package:cff/src/args/argument_parser.dart';
import 'package:cff/src/prompt/state_picker.dart';
import 'package:test/test.dart';

void main() {
  late StringBuffer out;

  setUp(() => out = StringBuffer());

  StateManagement fail(List<StateManagement> _, StateManagement _) =>
      throw StateError('prompt should not be shown');

  test('uses the --state flag without prompting', () {
    final picker = StatePicker(hasTerminal: () => true, choose: fail, out: out);
    expect(picker.resolve(StateManagement.bloc), StateManagement.bloc);
  });

  test('defaults to Cubit with a notice when there is no terminal', () {
    final picker = StatePicker(
      hasTerminal: () => false,
      choose: fail,
      out: out,
    );
    expect(picker.resolve(null), StateManagement.cubit);
    expect(out.toString(), contains('No interactive terminal'));
  });

  test('prompts with Cubit first and preselected, and uses the answer', () {
    List<StateManagement>? shownChoices;
    StateManagement? shownDefault;
    final picker = StatePicker(
      hasTerminal: () => true,
      choose: (choices, defaultValue) {
        shownChoices = choices;
        shownDefault = defaultValue;
        return StateManagement.bloc;
      },
      out: out,
    );

    expect(picker.resolve(null), StateManagement.bloc);
    expect(shownChoices, [StateManagement.cubit, StateManagement.bloc]);
    expect(shownDefault, StateManagement.cubit);
  });

  test('falls back to Cubit when the terminal cannot enter raw mode', () {
    final picker = StatePicker(
      hasTerminal: () => true,
      choose: (_, _) => throw const StdinException('echo mode unavailable'),
      out: out,
    );
    expect(picker.resolve(null), StateManagement.cubit);
    expect(out.toString(), contains('No interactive terminal'));
  });
}
