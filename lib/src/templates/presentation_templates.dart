// Feature presentation layer and dependency registration, one template per
// state management variant where they differ.
// Placeholders: {{snake}}, {{pascal}}, {{camel}}, {{package}}.

const stateTemplate = r'''
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}_delete_response.dart';

enum {{pascal}}Operation { fetch, post, edit, delete }

sealed class {{pascal}}State extends Equatable {
  /// The {{snake}} currently displayed, kept while loading and on failure.
  final {{pascal}}Entity? {{camel}};

  const {{pascal}}State({this.{{camel}}});

  @override
  List<Object?> get props => [{{camel}}];
}

class {{pascal}}Initial extends {{pascal}}State {
  const {{pascal}}Initial();
}

class {{pascal}}Loading extends {{pascal}}State {
  final {{pascal}}Operation operation;

  const {{pascal}}Loading(this.operation, {super.{{camel}}});

  @override
  List<Object?> get props => [operation, {{camel}}];
}

class {{pascal}}FetchSuccess extends {{pascal}}State {
  const {{pascal}}FetchSuccess({{pascal}}Entity {{camel}}) : super({{camel}}: {{camel}});
}

class {{pascal}}PostSuccess extends {{pascal}}State {
  const {{pascal}}PostSuccess({{pascal}}Entity {{camel}}) : super({{camel}}: {{camel}});
}

class {{pascal}}EditSuccess extends {{pascal}}State {
  const {{pascal}}EditSuccess({{pascal}}Entity {{camel}}) : super({{camel}}: {{camel}});
}

class {{pascal}}DeleteSuccess extends {{pascal}}State {
  final {{pascal}}DeleteResponseEntity response;

  const {{pascal}}DeleteSuccess(this.response);

  @override
  List<Object?> get props => [response, {{camel}}];
}

class {{pascal}}Failure extends {{pascal}}State {
  final {{pascal}}Operation operation;
  final DioException error;

  const {{pascal}}Failure(this.operation, this.error, {super.{{camel}}});

  @override
  List<Object?> get props => [operation, error, {{camel}}];
}
''';

const cubitTemplate = r'''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{package}}/core/resources/data_state.dart';
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/delete_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/edit_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/get_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/post_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/presentation/bloc/{{snake}}_state.dart';

class {{pascal}}Cubit extends Cubit<{{pascal}}State> {
  final Get{{pascal}}UseCase _get{{pascal}}UseCase;
  final Post{{pascal}}UseCase _post{{pascal}}UseCase;
  final Edit{{pascal}}UseCase _edit{{pascal}}UseCase;
  final Delete{{pascal}}UseCase _delete{{pascal}}UseCase;

  /// Incremented by every request; a response is dropped if a newer request
  /// started meanwhile (e.g. a fetch finishing after a delete).
  int _generation = 0;

  {{pascal}}Cubit({
    required Get{{pascal}}UseCase get{{pascal}}UseCase,
    required Post{{pascal}}UseCase post{{pascal}}UseCase,
    required Edit{{pascal}}UseCase edit{{pascal}}UseCase,
    required Delete{{pascal}}UseCase delete{{pascal}}UseCase,
  }) : _get{{pascal}}UseCase = get{{pascal}}UseCase,
       _post{{pascal}}UseCase = post{{pascal}}UseCase,
       _edit{{pascal}}UseCase = edit{{pascal}}UseCase,
       _delete{{pascal}}UseCase = delete{{pascal}}UseCase,
       super(const {{pascal}}Initial());

  Future<void> fetch() {
    return _run(
      {{pascal}}Operation.fetch,
      () => _get{{pascal}}UseCase(),
      {{pascal}}FetchSuccess.new,
    );
  }

  Future<void> post({{pascal}}Entity {{camel}}) {
    return _run(
      {{pascal}}Operation.post,
      () => _post{{pascal}}UseCase(params: {{camel}}),
      {{pascal}}PostSuccess.new,
    );
  }

  Future<void> edit(String id, {{pascal}}Entity {{camel}}) {
    return _run(
      {{pascal}}Operation.edit,
      () => _edit{{pascal}}UseCase(
        params: Edit{{pascal}}Params(id: id, {{camel}}: {{camel}}),
      ),
      {{pascal}}EditSuccess.new,
    );
  }

  Future<void> delete(String id) {
    return _run(
      {{pascal}}Operation.delete,
      () => _delete{{pascal}}UseCase(params: id),
      {{pascal}}DeleteSuccess.new,
    );
  }

  Future<void> _run<T>(
    {{pascal}}Operation operation,
    Future<DataState<T>> Function() request,
    {{pascal}}State Function(T data) onSuccess,
  ) async {
    final generation = ++_generation;
    final previous = state.{{camel}};
    emit({{pascal}}Loading(operation, {{camel}}: previous));

    final result = await request();
    if (generation != _generation || isClosed) return;

    final error = result.error;
    if (error != null) {
      emit({{pascal}}Failure(operation, error, {{camel}}: previous));
    } else {
      emit(onSuccess(result.data as T));
    }
  }
}
''';

const blocTemplate = r'''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{package}}/core/resources/data_state.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/delete_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/edit_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/get_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/post_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/presentation/bloc/{{snake}}_event.dart';
import 'package:{{package}}/feature/{{snake}}/presentation/bloc/{{snake}}_state.dart';

class {{pascal}}Bloc extends Bloc<{{pascal}}Event, {{pascal}}State> {
  final Get{{pascal}}UseCase _get{{pascal}}UseCase;
  final Post{{pascal}}UseCase _post{{pascal}}UseCase;
  final Edit{{pascal}}UseCase _edit{{pascal}}UseCase;
  final Delete{{pascal}}UseCase _delete{{pascal}}UseCase;

  /// Incremented by every request; a response is dropped if a newer request
  /// started meanwhile (e.g. a fetch finishing after a delete).
  int _generation = 0;

  {{pascal}}Bloc({
    required Get{{pascal}}UseCase get{{pascal}}UseCase,
    required Post{{pascal}}UseCase post{{pascal}}UseCase,
    required Edit{{pascal}}UseCase edit{{pascal}}UseCase,
    required Delete{{pascal}}UseCase delete{{pascal}}UseCase,
  }) : _get{{pascal}}UseCase = get{{pascal}}UseCase,
       _post{{pascal}}UseCase = post{{pascal}}UseCase,
       _edit{{pascal}}UseCase = edit{{pascal}}UseCase,
       _delete{{pascal}}UseCase = delete{{pascal}}UseCase,
       super(const {{pascal}}Initial()) {
    on<{{pascal}}FetchRequested>((event, emit) {
      return _run(
        emit,
        {{pascal}}Operation.fetch,
        () => _get{{pascal}}UseCase(),
        {{pascal}}FetchSuccess.new,
      );
    });
    on<{{pascal}}PostRequested>((event, emit) {
      return _run(
        emit,
        {{pascal}}Operation.post,
        () => _post{{pascal}}UseCase(params: event.{{camel}}),
        {{pascal}}PostSuccess.new,
      );
    });
    on<{{pascal}}EditRequested>((event, emit) {
      return _run(
        emit,
        {{pascal}}Operation.edit,
        () => _edit{{pascal}}UseCase(
          params: Edit{{pascal}}Params(id: event.id, {{camel}}: event.{{camel}}),
        ),
        {{pascal}}EditSuccess.new,
      );
    });
    on<{{pascal}}DeleteRequested>((event, emit) {
      return _run(
        emit,
        {{pascal}}Operation.delete,
        () => _delete{{pascal}}UseCase(params: event.id),
        {{pascal}}DeleteSuccess.new,
      );
    });
  }

  Future<void> _run<T>(
    Emitter<{{pascal}}State> emit,
    {{pascal}}Operation operation,
    Future<DataState<T>> Function() request,
    {{pascal}}State Function(T data) onSuccess,
  ) async {
    final generation = ++_generation;
    final previous = state.{{camel}};
    emit({{pascal}}Loading(operation, {{camel}}: previous));

    final result = await request();
    if (generation != _generation || emit.isDone) return;

    final error = result.error;
    if (error != null) {
      emit({{pascal}}Failure(operation, error, {{camel}}: previous));
    } else {
      emit(onSuccess(result.data as T));
    }
  }
}
''';

const eventTemplate = r'''
import 'package:equatable/equatable.dart';
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}.dart';

sealed class {{pascal}}Event extends Equatable {
  const {{pascal}}Event();

  @override
  List<Object?> get props => [];
}

class {{pascal}}FetchRequested extends {{pascal}}Event {
  const {{pascal}}FetchRequested();
}

class {{pascal}}PostRequested extends {{pascal}}Event {
  final {{pascal}}Entity {{camel}};

  const {{pascal}}PostRequested(this.{{camel}});

  @override
  List<Object?> get props => [{{camel}}];
}

class {{pascal}}EditRequested extends {{pascal}}Event {
  final String id;
  final {{pascal}}Entity {{camel}};

  const {{pascal}}EditRequested(this.id, this.{{camel}});

  @override
  List<Object?> get props => [id, {{camel}}];
}

class {{pascal}}DeleteRequested extends {{pascal}}Event {
  final String id;

  const {{pascal}}DeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
''';

const pageCubitTemplate = r'''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:{{package}}/feature/{{snake}}/presentation/bloc/{{snake}}_cubit.dart';
import 'package:{{package}}/feature/{{snake}}/presentation/bloc/{{snake}}_state.dart';
import 'package:{{package}}/feature/{{snake}}/presentation/widget/{{snake}}_widget.dart';

class {{pascal}}Page extends StatelessWidget {
  const {{pascal}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<{{pascal}}Cubit>()..fetch(),
      child: Scaffold(
        appBar: AppBar(title: const Text('{{pascal}}')),
        body: BlocBuilder<{{pascal}}Cubit, {{pascal}}State>(
          builder: (context, state) {
            if (state is {{pascal}}Loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is {{pascal}}Failure) {
              return Center(child: Text('Error: ${state.error.message}'));
            }
            final {{camel}} = state.{{camel}};
            if ({{camel}} == null) return const SizedBox.shrink();
            return {{pascal}}Widget({{camel}}: {{camel}});
          },
        ),
        // TODO: add the actions of the {{snake}} page.
        bottomNavigationBar: const BottomAppBar(),
      ),
    );
  }
}
''';

const pageBlocTemplate = r'''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:{{package}}/feature/{{snake}}/presentation/bloc/{{snake}}_bloc.dart';
import 'package:{{package}}/feature/{{snake}}/presentation/bloc/{{snake}}_event.dart';
import 'package:{{package}}/feature/{{snake}}/presentation/bloc/{{snake}}_state.dart';
import 'package:{{package}}/feature/{{snake}}/presentation/widget/{{snake}}_widget.dart';

class {{pascal}}Page extends StatelessWidget {
  const {{pascal}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<{{pascal}}Bloc>()..add(const {{pascal}}FetchRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('{{pascal}}')),
        body: BlocBuilder<{{pascal}}Bloc, {{pascal}}State>(
          builder: (context, state) {
            if (state is {{pascal}}Loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is {{pascal}}Failure) {
              return Center(child: Text('Error: ${state.error.message}'));
            }
            final {{camel}} = state.{{camel}};
            if ({{camel}} == null) return const SizedBox.shrink();
            return {{pascal}}Widget({{camel}}: {{camel}});
          },
        ),
        // TODO: add the actions of the {{snake}} page.
        bottomNavigationBar: const BottomAppBar(),
      ),
    );
  }
}
''';

const widgetTemplate = r'''
import 'package:flutter/material.dart';
import 'package:{{package}}/feature/{{snake}}/domain/entities/{{snake}}.dart';

class {{pascal}}Widget extends StatelessWidget {
  final {{pascal}}Entity {{camel}};

  const {{pascal}}Widget({super.key, required this.{{camel}}});

  @override
  Widget build(BuildContext context) {
    // TODO: display the fields of {{pascal}}Entity.
    return Text({{camel}}.id ?? 'No id');
  }
}
''';

const dependenciesCubitTemplate = r'''
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:{{package}}/feature/{{snake}}/data/data_sources/remote/{{snake}}_api_service.dart';
import 'package:{{package}}/feature/{{snake}}/data/repository/{{snake}}_repository_impl.dart';
import 'package:{{package}}/feature/{{snake}}/domain/repository/{{snake}}_repository.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/delete_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/edit_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/get_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/post_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/presentation/bloc/{{snake}}_cubit.dart';

/// Registers the {{snake}} feature. Dio must already be registered in [sl].
void register{{pascal}}Dependencies(GetIt sl) {
  sl.registerLazySingleton<{{pascal}}ApiService>(
    () => {{pascal}}ApiService(sl<Dio>()),
  );
  sl.registerLazySingleton<{{pascal}}Repository>(
    () => {{pascal}}RepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => Get{{pascal}}UseCase(sl()));
  sl.registerLazySingleton(() => Post{{pascal}}UseCase(sl()));
  sl.registerLazySingleton(() => Edit{{pascal}}UseCase(sl()));
  sl.registerLazySingleton(() => Delete{{pascal}}UseCase(sl()));
  sl.registerFactory(
    () => {{pascal}}Cubit(
      get{{pascal}}UseCase: sl(),
      post{{pascal}}UseCase: sl(),
      edit{{pascal}}UseCase: sl(),
      delete{{pascal}}UseCase: sl(),
    ),
  );
}
''';

const dependenciesBlocTemplate = r'''
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:{{package}}/feature/{{snake}}/data/data_sources/remote/{{snake}}_api_service.dart';
import 'package:{{package}}/feature/{{snake}}/data/repository/{{snake}}_repository_impl.dart';
import 'package:{{package}}/feature/{{snake}}/domain/repository/{{snake}}_repository.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/delete_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/edit_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/get_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/domain/usecases/post_{{snake}}.dart';
import 'package:{{package}}/feature/{{snake}}/presentation/bloc/{{snake}}_bloc.dart';

/// Registers the {{snake}} feature. Dio must already be registered in [sl].
void register{{pascal}}Dependencies(GetIt sl) {
  sl.registerLazySingleton<{{pascal}}ApiService>(
    () => {{pascal}}ApiService(sl<Dio>()),
  );
  sl.registerLazySingleton<{{pascal}}Repository>(
    () => {{pascal}}RepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => Get{{pascal}}UseCase(sl()));
  sl.registerLazySingleton(() => Post{{pascal}}UseCase(sl()));
  sl.registerLazySingleton(() => Edit{{pascal}}UseCase(sl()));
  sl.registerLazySingleton(() => Delete{{pascal}}UseCase(sl()));
  sl.registerFactory(
    () => {{pascal}}Bloc(
      get{{pascal}}UseCase: sl(),
      post{{pascal}}UseCase: sl(),
      edit{{pascal}}UseCase: sl(),
      delete{{pascal}}UseCase: sl(),
    ),
  );
}
''';
