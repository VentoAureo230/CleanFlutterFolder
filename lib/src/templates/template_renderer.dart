import '../cff_exception.dart';

/// Replaces `{{key}}` placeholders in a template with their values.
class TemplateRenderer {
  /// A placeholder left after rendering, e.g. a typo like `{{pascl}}`.
  static final _leftover = RegExp(r'\{\{\w+\}\}');

  String render(String template, Map<String, String> values) {
    var result = template;
    values.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
    });

    final leftover = _leftover.firstMatch(result);
    if (leftover != null) {
      throw CffException('Unknown placeholder ${leftover[0]} in a template.');
    }
    return result;
  }
}
