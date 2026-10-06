import '../cff_exception.dart';

class FeatureNameValidator {
  static final _snakeCase = RegExp(r'^[a-z][a-z0-9_]*$');

  static const _reservedWords = {
    'assert',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'do',
    'else',
    'enum',
    'extends',
    'false',
    'final',
    'finally',
    'for',
    'if',
    'in',
    'is',
    'new',
    'null',
    'rethrow',
    'return',
    'super',
    'switch',
    'this',
    'throw',
    'true',
    'try',
    'var',
    'void',
    'while',
    'with',
  };

  void validate(String name) {
    if (!_snakeCase.hasMatch(name) || name.endsWith('_')) {
      throw CffException(
        'Invalid feature name "$name". Use snake_case: lowercase letters, '
        'digits and underscores, starting with a letter (e.g. user_profile).',
      );
    }
    if (_reservedWords.contains(name)) {
      throw CffException(
        'Invalid feature name "$name": it is a Dart reserved word.',
      );
    }
  }
}
