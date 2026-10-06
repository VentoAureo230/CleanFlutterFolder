# cff

`cff` (Clean Flutter Folder) is a command-line tool that scaffolds a Flutter
feature following **Clean Architecture**: the `data`, `domain` and
`presentation` folders, plus working CRUD boilerplate for **Cubit** or
**BLoC**, in one command.

```
dart run cff user_profile --state cubit
```

It also creates the shared `core/` files the generated code relies on, if your
project doesn't have them yet.

> `cff` is built around my own project conventions (feature layout, `get_it`,
> `retrofit` + `dio`, `equatable`). It isn't meant to fit every architecture,
> but issues and pull requests are welcome.

## Installation

Add `cff` as a dev dependency of your Flutter project:

```yaml
dev_dependencies:
  cff: ^0.1.0
```

Then run `flutter pub get`. `cff` requires Dart `3.9.0` or later
(Flutter `3.35` or later).

## Usage

From anywhere inside your Flutter project:

```
dart run cff <feature_name> [--state <cubit|bloc>]
```

| Option | Description |
|---|---|
| `<feature_name>` | Required. snake_case: lowercase letters, digits and `_`, starting with a letter (e.g. `user_profile`). Dart reserved words are rejected. |
| `-s`, `--state` | `cubit` or `bloc`. When omitted, `cff` asks with an arrow-key menu; without an interactive terminal (CI, some IDE consoles) it defaults to `cubit`. |
| `-h`, `--help` | Shows the usage. |

What `cff` does:

1. Finds the project root (the nearest `pubspec.yaml`, which must depend on
   the Flutter SDK) and reads the package name for imports.
2. Warns about missing packages and prints the `flutter pub add` commands.
   Generation continues anyway.
3. Stops if `lib/feature/<feature_name>/` already exists. `cff` never
   overwrites a file.
4. Creates the missing core files, the feature folders and files, then runs
   `dart format` on the new feature.

If something fails halfway, the partial feature folder is left in place and
the error says which file failed. Delete the folder before running `cff`
again.

## Generated tree

`dart run cff owl --state cubit` creates:

```
lib/feature/owl/
├── owl_dependencies.dart          # get_it registrations
├── data/
│   ├── data_sources/
│   │   ├── local/
│   │   └── remote/
│   │       └── owl_api_service.dart   # retrofit: GET, POST, PUT, DELETE
│   ├── models/
│   │   ├── owl.dart                   # OwlModel extends OwlEntity
│   │   └── owl_delete_response.dart
│   └── repository/
│       └── owl_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── owl.dart
│   │   └── owl_delete_response.dart
│   ├── repository/
│   │   └── owl_repository.dart
│   └── usecases/
│       ├── get_owl.dart
│       ├── post_owl.dart
│       ├── edit_owl.dart              # with EditOwlParams
│       └── delete_owl.dart
└── presentation/
    ├── bloc/
    │   ├── owl_cubit.dart
    │   └── owl_state.dart
    ├── pages/
    │   └── owl_page.dart
    └── widget/
        └── owl_widget.dart
```

With `--state bloc`, `presentation/bloc/` contains `owl_bloc.dart`,
`owl_event.dart` and `owl_state.dart` instead, and the page and
`owl_dependencies.dart` use the bloc.

The state classes keep the displayed entity while loading and on failure, and
both the cubit and the bloc ignore responses from requests that were
superseded by a newer one.

## Core files

The generated code imports two shared files. `cff` creates each one only if it
is missing:

- `lib/core/resources/data_state.dart`
- `lib/core/usecases/usecase.dart`

If your project already has them, they are left untouched, so they must match
what the generated code expects:

```dart
// lib/core/usecases/usecase.dart
abstract class Usecase<Type, Params> {
  Future<Type> call({Params params});
}

// lib/core/resources/data_state.dart
abstract class DataState<T> {
  final T? data;
  final DioException? error;
  // ...
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(DioException error) : super(error: error);
}
```

## Setup

After generating a feature:

1. **Add the packages** the generated code uses, if `cff` warned about them:

   ```
   flutter pub add equatable flutter_bloc get_it retrofit dio
   flutter pub add dev:retrofit_generator dev:build_runner
   ```

2. **Generate the retrofit code** (`*_api_service.g.dart`):

   ```
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Register the feature** in your `get_it` setup. Dio must be registered
   first:

   ```dart
   final sl = GetIt.instance;

   sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(baseUrl: '...')));
   registerOwlDependencies(sl);
   ```

4. **Fill in the TODOs**: the entity fields, their JSON mapping in the model,
   and the endpoint paths in the API service (they start as `/api/v1/`).

`flutter analyze` reports `prefer_initializing_formals` infos on the cubit and
bloc constructors. They are expected; the code is correct as generated.

## Contributing

`cff` is a personal tool, but bug reports, ideas and pull requests are
welcome on the [issue tracker](https://github.com/VentoAureo230/CleanFlutterFolder/issues).

## License

MIT, see [LICENSE](LICENSE).

The code that `cff` generates in your project is yours: you can use, modify
and distribute it without attribution or any license notice.
