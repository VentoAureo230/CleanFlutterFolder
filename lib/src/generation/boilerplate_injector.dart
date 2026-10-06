import 'dart:io';

import 'package:path/path.dart' as p;

import '../args/argument_parser.dart';
import '../layout/feature_layout.dart';
import '../naming/feature_name.dart';
import '../templates/template_renderer.dart';
import '../templates/templates.dart';

/// Fills every file of a feature with its rendered template.
class BoilerplateInjector {
  final _renderer = TemplateRenderer();

  void inject(
    Directory featureDir,
    FeatureName name,
    StateManagement state,
    String packageName,
  ) {
    final values = {
      'snake': name.snake,
      'pascal': name.pascal,
      'camel': name.camel,
      'package': packageName,
    };

    for (final layoutFile in FeatureLayout.filesFor(state)) {
      File(
        p.join(featureDir.path, layoutFile.resolvePath(name)),
      ).writeAsStringSync(
        _renderer.render(templateFor(layoutFile.template), values),
      );
    }
  }
}
