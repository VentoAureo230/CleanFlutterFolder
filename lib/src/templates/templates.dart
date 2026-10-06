import '../layout/feature_layout.dart';
import 'core_templates.dart';
import 'data_templates.dart';
import 'domain_templates.dart';
import 'presentation_templates.dart';

/// The template of each [TemplateId]. Exhaustive: a new id without a template
/// fails to compile.
String templateFor(TemplateId id) => switch (id) {
  TemplateId.dataState => dataStateTemplate,
  TemplateId.usecase => usecaseTemplate,
  TemplateId.entity => entityTemplate,
  TemplateId.deleteResponseEntity => deleteResponseEntityTemplate,
  TemplateId.domainRepository => domainRepositoryTemplate,
  TemplateId.getUseCase => getUseCaseTemplate,
  TemplateId.postUseCase => postUseCaseTemplate,
  TemplateId.editUseCase => editUseCaseTemplate,
  TemplateId.deleteUseCase => deleteUseCaseTemplate,
  TemplateId.model => modelTemplate,
  TemplateId.deleteResponseModel => deleteResponseModelTemplate,
  TemplateId.apiService => apiServiceTemplate,
  TemplateId.repositoryImpl => repositoryImplTemplate,
  TemplateId.dependenciesCubit => dependenciesCubitTemplate,
  TemplateId.dependenciesBloc => dependenciesBlocTemplate,
  TemplateId.cubit => cubitTemplate,
  TemplateId.bloc => blocTemplate,
  TemplateId.event => eventTemplate,
  TemplateId.state => stateTemplate,
  TemplateId.pageCubit => pageCubitTemplate,
  TemplateId.pageBloc => pageBlocTemplate,
  TemplateId.widget => widgetTemplate,
};
