/// An expected failure that stops the tool with a readable message.
class CffException implements Exception {
  final String message;

  const CffException(this.message);

  @override
  String toString() => message;
}

/// The command was called incorrectly (missing or unknown arguments).
class CffUsageException extends CffException {
  const CffUsageException(super.message);
}
