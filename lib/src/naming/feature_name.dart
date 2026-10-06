/// The case variants of a validated snake_case feature name.
class FeatureName {
  /// e.g. `user_profile`, used in file and folder names.
  final String snake;

  const FeatureName(this.snake);

  List<String> get _words =>
      snake.split('_').where((w) => w.isNotEmpty).toList();

  /// e.g. `UserProfile`, used in class names.
  String get pascal => _words.map(_capitalize).join();

  /// e.g. `userProfile`, used in field and method names.
  String get camel {
    final value = pascal;
    return value[0].toLowerCase() + value.substring(1);
  }

  static String _capitalize(String word) =>
      word[0].toUpperCase() + word.substring(1);

  @override
  String toString() => snake;
}
