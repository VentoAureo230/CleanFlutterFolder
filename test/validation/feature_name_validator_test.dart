import 'package:cff/src/cff_exception.dart';
import 'package:cff/src/validation/feature_name_validator.dart';
import 'package:test/test.dart';

void main() {
  final validator = FeatureNameValidator();

  for (final name in ['owl', 'user_profile', 'owl2', 'a_b_c']) {
    test('accepts "$name"', () => validator.validate(name));
  }

  for (final name in [
    'Owl',
    'userProfile',
    'user-profile',
    'user profile',
    '123owl',
    '_owl',
    'owl_',
    '',
    'class',
    'if',
  ]) {
    test('rejects "$name"', () {
      expect(() => validator.validate(name), throwsA(isA<CffException>()));
    });
  }
}
