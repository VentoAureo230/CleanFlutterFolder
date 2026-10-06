import 'package:path/path.dart' as p;

import '../args/argument_parser.dart';
import '../naming/feature_name.dart';

/// Identifies which template fills a generated file (used by the injector).
enum TemplateId {
  dataState,
  usecase,
  entity,
  deleteResponseEntity,
  domainRepository,
  getUseCase,
  postUseCase,
  editUseCase,
  deleteUseCase,
  model,
  deleteResponseModel,
  apiService,
  repositoryImpl,
  dependenciesCubit,
  dependenciesBloc,
  cubit,
  bloc,
  event,
  state,
  pageCubit,
  pageBloc,
  widget,
}

const _both = {StateManagement.cubit, StateManagement.bloc};

/// One file to generate. `{name}` in [path] is replaced by the snake_case
/// feature name.
class LayoutFile {
  final String path;
  final Set<StateManagement> variants;
  final TemplateId template;

  const LayoutFile(this.path, this.template, {this.variants = _both});

  bool appliesTo(StateManagement state) => variants.contains(state);

  String resolvePath(FeatureName name) =>
      p.joinAll(path.replaceAll('{name}', name.snake).split('/'));
}

/// The single source of truth for what `cff` generates.
abstract final class FeatureLayout {
  /// Where a feature lives, relative to the project root.
  static String featurePath(String projectRoot, FeatureName name) =>
      p.join(projectRoot, 'lib', 'feature', name.snake);

  /// Shared files, relative to the project root. Created only if missing.
  static const coreFiles = [
    LayoutFile('lib/core/resources/data_state.dart', TemplateId.dataState),
    LayoutFile('lib/core/usecases/usecase.dart', TemplateId.usecase),
  ];

  /// Folders inside a feature, including ones left empty.
  static const folders = [
    'data/data_sources/local',
    'data/data_sources/remote',
    'data/models',
    'data/repository',
    'domain/entities',
    'domain/repository',
    'domain/usecases',
    'presentation/bloc',
    'presentation/pages',
    'presentation/widget',
  ];

  /// Files inside a feature, relative to the feature folder.
  static const files = [
    LayoutFile(
      'data/data_sources/remote/{name}_api_service.dart',
      TemplateId.apiService,
    ),
    LayoutFile('data/models/{name}.dart', TemplateId.model),
    LayoutFile(
      'data/models/{name}_delete_response.dart',
      TemplateId.deleteResponseModel,
    ),
    LayoutFile(
      'data/repository/{name}_repository_impl.dart',
      TemplateId.repositoryImpl,
    ),
    LayoutFile('domain/entities/{name}.dart', TemplateId.entity),
    LayoutFile(
      'domain/entities/{name}_delete_response.dart',
      TemplateId.deleteResponseEntity,
    ),
    LayoutFile(
      'domain/repository/{name}_repository.dart',
      TemplateId.domainRepository,
    ),
    LayoutFile('domain/usecases/get_{name}.dart', TemplateId.getUseCase),
    LayoutFile('domain/usecases/post_{name}.dart', TemplateId.postUseCase),
    LayoutFile('domain/usecases/edit_{name}.dart', TemplateId.editUseCase),
    LayoutFile('domain/usecases/delete_{name}.dart', TemplateId.deleteUseCase),
    LayoutFile(
      '{name}_dependencies.dart',
      TemplateId.dependenciesCubit,
      variants: {StateManagement.cubit},
    ),
    LayoutFile(
      '{name}_dependencies.dart',
      TemplateId.dependenciesBloc,
      variants: {StateManagement.bloc},
    ),
    LayoutFile(
      'presentation/bloc/{name}_cubit.dart',
      TemplateId.cubit,
      variants: {StateManagement.cubit},
    ),
    LayoutFile(
      'presentation/bloc/{name}_bloc.dart',
      TemplateId.bloc,
      variants: {StateManagement.bloc},
    ),
    LayoutFile(
      'presentation/bloc/{name}_event.dart',
      TemplateId.event,
      variants: {StateManagement.bloc},
    ),
    LayoutFile('presentation/bloc/{name}_state.dart', TemplateId.state),
    LayoutFile(
      'presentation/pages/{name}_page.dart',
      TemplateId.pageCubit,
      variants: {StateManagement.cubit},
    ),
    LayoutFile(
      'presentation/pages/{name}_page.dart',
      TemplateId.pageBloc,
      variants: {StateManagement.bloc},
    ),
    LayoutFile('presentation/widget/{name}_widget.dart', TemplateId.widget),
  ];

  static Iterable<LayoutFile> filesFor(StateManagement state) =>
      files.where((file) => file.appliesTo(state));
}
