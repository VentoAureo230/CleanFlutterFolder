import 'package:cff/src/layout/feature_layout.dart';
import 'package:cff/src/templates/template_renderer.dart';
import 'package:cff/src/templates/templates.dart';
import 'package:test/test.dart';

void main() {
  const values = {
    'snake': 'user_profile',
    'pascal': 'UserProfile',
    'camel': 'userProfile',
    'package': 'demo_app',
  };

  for (final id in TemplateId.values) {
    test('$id renders without leftover placeholders', () {
      final rendered = TemplateRenderer().render(templateFor(id), values);
      expect(rendered.trim(), isNotEmpty);
      expect(rendered, isNot(contains('{{')));
    });
  }
}
