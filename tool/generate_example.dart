import 'dart:io';

import 'example_builder.dart';

/// Regenerates example/example.md. Run from the package root:
/// `dart run tool/generate_example.dart`
Future<void> main() async {
  File(examplePath).writeAsStringSync(await buildExample());
  stdout.writeln('Wrote $examplePath');
}
