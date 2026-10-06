// Feature domain layer: entities, repository contract, use cases.
// Placeholders: {{snake}}, {{pascal}}, {{camel}}, {{package}}.

const entityTemplate = r'''
import 'package:equatable/equatable.dart';

class {{pascal}}Entity extends Equatable {
  final String? id;
  // TODO: add the fields of {{pascal}}Entity.

  const {{pascal}}Entity({this.id});

  @override
  List<Object?> get props => [id];
}
''';

const deleteResponseEntityTemplate = r'''
import 'package:equatable/equatable.dart';

class {{pascal}}DeleteResponseEntity extends Equatable {
  final String? message;

  const {{pascal}}DeleteResponseEntity({this.message});

  @override
  List<Object?> get props => [message];
}
''';

const domainRepositoryTemplate = r'''
import 'package:{{package}}/core/resources/data_state.dart';
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}_delete_response.dart';

abstract class {{pascal}}Repository {
  Future<DataState<{{pascal}}Entity>> get{{pascal}}();

  Future<DataState<{{pascal}}Entity>> post{{pascal}}({{pascal}}Entity {{camel}});

  Future<DataState<{{pascal}}Entity>> edit{{pascal}}(
    String id,
    {{pascal}}Entity {{camel}},
  );

  Future<DataState<{{pascal}}DeleteResponseEntity>> delete{{pascal}}(String id);
}
''';

const getUseCaseTemplate = r'''
import 'package:{{package}}/core/resources/data_state.dart';
import 'package:{{package}}/core/usecases/usecase.dart';
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/repository/{{snake}}_repository.dart';

class Get{{pascal}}UseCase
    implements Usecase<DataState<{{pascal}}Entity>, void> {
  final {{pascal}}Repository _repository;

  Get{{pascal}}UseCase(this._repository);

  @override
  Future<DataState<{{pascal}}Entity>> call({void params}) {
    return _repository.get{{pascal}}();
  }
}
''';

const postUseCaseTemplate = r'''
import 'package:{{package}}/core/resources/data_state.dart';
import 'package:{{package}}/core/usecases/usecase.dart';
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/repository/{{snake}}_repository.dart';

class Post{{pascal}}UseCase
    implements Usecase<DataState<{{pascal}}Entity>, {{pascal}}Entity?> {
  final {{pascal}}Repository _repository;

  Post{{pascal}}UseCase(this._repository);

  @override
  Future<DataState<{{pascal}}Entity>> call({{{pascal}}Entity? params}) {
    if (params == null) throw ArgumentError.notNull('params');
    return _repository.post{{pascal}}(params);
  }
}
''';

const editUseCaseTemplate = r'''
import 'package:{{package}}/core/resources/data_state.dart';
import 'package:{{package}}/core/usecases/usecase.dart';
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/repository/{{snake}}_repository.dart';

class Edit{{pascal}}Params {
  final String id;
  final {{pascal}}Entity {{camel}};

  const Edit{{pascal}}Params({required this.id, required this.{{camel}}});
}

class Edit{{pascal}}UseCase
    implements Usecase<DataState<{{pascal}}Entity>, Edit{{pascal}}Params?> {
  final {{pascal}}Repository _repository;

  Edit{{pascal}}UseCase(this._repository);

  @override
  Future<DataState<{{pascal}}Entity>> call({Edit{{pascal}}Params? params}) {
    if (params == null) throw ArgumentError.notNull('params');
    return _repository.edit{{pascal}}(params.id, params.{{camel}});
  }
}
''';

const deleteUseCaseTemplate = r'''
import 'package:{{package}}/core/resources/data_state.dart';
import 'package:{{package}}/core/usecases/usecase.dart';
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}_delete_response.dart';
import 'package:{{package}}/feature/{{snake}}/domain/repository/{{snake}}_repository.dart';

class Delete{{pascal}}UseCase
    implements Usecase<DataState<{{pascal}}DeleteResponseEntity>, String?> {
  final {{pascal}}Repository _repository;

  Delete{{pascal}}UseCase(this._repository);

  @override
  Future<DataState<{{pascal}}DeleteResponseEntity>> call({String? params}) {
    if (params == null) throw ArgumentError.notNull('params');
    return _repository.delete{{pascal}}(params);
  }
}
''';
