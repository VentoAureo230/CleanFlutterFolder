import 'package:cff/src/args/argument_parser.dart';
import 'package:cff/src/layout/feature_layout.dart';
import 'package:cff/src/naming/feature_name.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  const owl = FeatureName('owl');

  Set<String> pathsFor(StateManagement state) => FeatureLayout.filesFor(
    state,
  ).map((file) => p.split(file.resolvePath(owl)).join('/')).toSet();

  test('cubit variant has the cubit and state, no bloc or event', () {
    final paths = pathsFor(StateManagement.cubit);
    expect(paths, contains('presentation/bloc/owl_cubit.dart'));
    expect(paths, contains('presentation/bloc/owl_state.dart'));
    expect(paths, isNot(contains('presentation/bloc/owl_bloc.dart')));
    expect(paths, isNot(contains('presentation/bloc/owl_event.dart')));
  });

  test('bloc variant has bloc, event and state, no cubit', () {
    final paths = pathsFor(StateManagement.bloc);
    expect(paths, contains('presentation/bloc/owl_bloc.dart'));
    expect(paths, contains('presentation/bloc/owl_event.dart'));
    expect(paths, contains('presentation/bloc/owl_state.dart'));
    expect(paths, isNot(contains('presentation/bloc/owl_cubit.dart')));
  });

  test('both variants share the other layers', () {
    for (final state in StateManagement.values) {
      expect(
        pathsFor(state),
        containsAll([
          'data/data_sources/remote/owl_api_service.dart',
          'data/models/owl.dart',
          'data/models/owl_delete_response.dart',
          'data/repository/owl_repository_impl.dart',
          'domain/entities/owl.dart',
          'domain/entities/owl_delete_response.dart',
          'domain/repository/owl_repository.dart',
          'domain/usecases/get_owl.dart',
          'domain/usecases/post_owl.dart',
          'domain/usecases/edit_owl.dart',
          'domain/usecases/delete_owl.dart',
          'owl_dependencies.dart',
          'presentation/pages/owl_page.dart',
          'presentation/widget/owl_widget.dart',
        ]),
      );
    }
  });

  test('every file sits in a declared folder or the feature root', () {
    for (final file in FeatureLayout.files) {
      final folder = file.path.contains('/')
          ? file.path.substring(0, file.path.lastIndexOf('/'))
          : null;
      if (folder != null) expect(FeatureLayout.folders, contains(folder));
    }
  });
}
