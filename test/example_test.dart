import 'dart:io';

import 'package:test/test.dart';

import '../tool/example_builder.dart';

void main() {
  test('example/example.md matches the current templates', () async {
    // Git on Windows may check the file out with CRLF line endings.
    String normalize(String text) => text.replaceAll('\r\n', '\n');

    expect(
      normalize(File(examplePath).readAsStringSync()),
      normalize(await buildExample()),
      reason:
          'example/example.md is out of date. '
          'Run: dart run tool/generate_example.dart',
    );
  });
}
