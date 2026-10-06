import 'dart:io';

import 'package:cff/cff.dart';

Future<void> main(List<String> arguments) async {
  exit(await CffRunner().run(arguments));
}
