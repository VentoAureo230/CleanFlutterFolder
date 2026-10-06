import 'package:cff/src/cff_exception.dart';
import 'package:cff/src/templates/template_renderer.dart';
import 'package:test/test.dart';

void main() {
  final renderer = TemplateRenderer();

  test('replaces every occurrence of each placeholder', () {
    expect(
      renderer.render('class {{pascal}}Cubit {} // {{pascal}} {{snake}}', {
        'pascal': 'UserProfile',
        'snake': 'user_profile',
      }),
      'class UserProfileCubit {} // UserProfile user_profile',
    );
  });

  test('handles a placeholder right after a Dart brace', () {
    expect(
      renderer.render('call({{{pascal}}Entity? params})', {'pascal': 'Owl'}),
      'call({OwlEntity? params})',
    );
  });

  test(r'leaves Dart braces and $ interpolation untouched', () {
    const code = r"@PUT('/api/v1/{id}') Text('Error: ${state.error}')";
    expect(renderer.render(code, {'pascal': 'Owl'}), code);
  });

  test('fails on an unknown placeholder', () {
    expect(
      () => renderer.render('class {{pascl}}Cubit', {'pascal': 'Owl'}),
      throwsA(
        isA<CffException>().having(
          (e) => e.message,
          'message',
          contains('{{pascl}}'),
        ),
      ),
    );
  });
}
