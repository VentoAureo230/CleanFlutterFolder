import 'package:cff/src/naming/feature_name.dart';
import 'package:test/test.dart';

void main() {
  test('single word', () {
    const name = FeatureName('owl');
    expect(name.pascal, 'Owl');
    expect(name.camel, 'owl');
  });

  test('multiple words', () {
    const name = FeatureName('user_profile');
    expect(name.snake, 'user_profile');
    expect(name.pascal, 'UserProfile');
    expect(name.camel, 'userProfile');
  });

  test('digits', () {
    const name = FeatureName('owl2_nest');
    expect(name.pascal, 'Owl2Nest');
    expect(name.camel, 'owl2Nest');
  });
}
