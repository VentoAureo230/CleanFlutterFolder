// Feature data layer: models, retrofit service, repository implementation.
// Placeholders: {{snake}}, {{pascal}}, {{camel}}, {{package}}.
// {{camel}} always takes a suffix ({{camel}}Entity): a bare feature name
// like `id` or `state` would clash with identifiers in the templates.

const modelTemplate = r'''
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}.dart';

class {{pascal}}Model extends {{pascal}}Entity {
  const {{pascal}}Model({super.id});

  // TODO: read the fields of {{pascal}}Entity.
  factory {{pascal}}Model.fromJson(Map<String, dynamic> json) {
    return {{pascal}}Model(id: json['id'] as String?);
  }

  factory {{pascal}}Model.fromEntity({{pascal}}Entity entity) {
    return {{pascal}}Model(id: entity.id);
  }

  // TODO: write the fields of {{pascal}}Entity.
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
''';

const deleteResponseModelTemplate = r'''
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}_delete_response.dart';

class {{pascal}}DeleteResponseModel extends {{pascal}}DeleteResponseEntity {
  const {{pascal}}DeleteResponseModel({super.message});

  factory {{pascal}}DeleteResponseModel.fromJson(Map<String, dynamic> json) {
    return {{pascal}}DeleteResponseModel(message: json['message'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'message': message};
  }
}
''';

const apiServiceTemplate = r'''
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:{{package}}/feature/{{snake}}/data/models/{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/data/models/{{snake}}_delete_response.dart';

part '{{snake}}_api_service.g.dart';

// TODO: add the {{snake}} resource to each path, e.g. /api/v1/{{snake}}.
@RestApi()
abstract class {{pascal}}ApiService {
  factory {{pascal}}ApiService(Dio dio) = _{{pascal}}ApiService;

  @GET('/api/v1/')
  Future<HttpResponse<{{pascal}}Model>> get{{pascal}}();

  @POST('/api/v1/')
  Future<HttpResponse<{{pascal}}Model>> post{{pascal}}(
    @Body() {{pascal}}Model {{camel}}Model,
  );

  @PUT('/api/v1/{id}')
  Future<HttpResponse<{{pascal}}Model>> edit{{pascal}}(
    @Path('id') String id,
    @Body() {{pascal}}Model {{camel}}Model,
  );

  @DELETE('/api/v1/{id}')
  Future<HttpResponse<{{pascal}}DeleteResponseModel>> delete{{pascal}}(
    @Path('id') String id,
  );
}
''';

const repositoryImplTemplate = r'''
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:{{package}}/core/resources/data_state.dart';
import 'package:{{package}}/feature/{{snake}}/data/data_sources/remote/{{snake}}_api_service.dart';
import 'package:{{package}}/feature/{{snake}}/data/models/{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}_delete_response.dart';
import 'package:{{package}}/feature/{{snake}}/domain/repository/{{snake}}_repository.dart';

class {{pascal}}RepositoryImpl implements {{pascal}}Repository {
  final {{pascal}}ApiService _apiService;

  {{pascal}}RepositoryImpl(this._apiService);

  @override
  Future<DataState<{{pascal}}Entity>> get{{pascal}}() {
    return _send(() => _apiService.get{{pascal}}());
  }

  @override
  Future<DataState<{{pascal}}Entity>> post{{pascal}}({{pascal}}Entity {{camel}}Entity) {
    return _send(
      () => _apiService.post{{pascal}}({{pascal}}Model.fromEntity({{camel}}Entity)),
    );
  }

  @override
  Future<DataState<{{pascal}}Entity>> edit{{pascal}}(
    String id,
    {{pascal}}Entity {{camel}}Entity,
  ) {
    return _send(
      () => _apiService.edit{{pascal}}(id, {{pascal}}Model.fromEntity({{camel}}Entity)),
    );
  }

  @override
  Future<DataState<{{pascal}}DeleteResponseEntity>> delete{{pascal}}(String id) {
    return _send(() => _apiService.delete{{pascal}}(id));
  }

  /// Sends [request]: 2xx is a success, anything else becomes a DataFailed.
  Future<DataState<T>> _send<T>(
    Future<HttpResponse<T>> Function() request,
  ) async {
    try {
      final httpResponse = await request();
      final statusCode = httpResponse.response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        return DataSuccess(httpResponse.data);
      }
      return DataFailed(
        DioException(
          error: httpResponse.response.statusMessage,
          response: httpResponse.response,
          type: DioExceptionType.badResponse,
          requestOptions: httpResponse.response.requestOptions,
        ),
      );
    } on DioException catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(DioException(requestOptions: RequestOptions(), error: e));
    }
  }
}
''';
