import 'package:cff/src/args/argument_parser.dart';
import 'package:cff/src/cff_exception.dart';
import 'package:test/test.dart';

void main() {
  final parser = CffArgumentParser();

  test('parses the feature name without a state', () {
    final args = parser.parse(['owl'])!;
    expect(args.featureName, 'owl');
    expect(args.state, isNull);
  });

  test('parses --state and -s', () {
    expect(
      parser.parse(['owl', '--state', 'bloc'])!.state,
      StateManagement.bloc,
    );
    expect(parser.parse(['owl', '-s', 'cubit'])!.state, StateManagement.cubit);
  });

  test('returns null for --help', () {
    expect(parser.parse(['--help']), isNull);
  });

  test('rejects a missing feature name', () {
    expect(() => parser.parse([]), throwsA(isA<CffUsageException>()));
  });

  test('rejects more than one feature name', () {
    expect(
      () => parser.parse(['owl', 'cat']),
      throwsA(isA<CffUsageException>()),
    );
  });

  test('rejects an unknown state value', () {
    expect(
      () => parser.parse(['owl', '--state', 'riverpod']),
      throwsA(isA<CffUsageException>()),
    );
  });
}
