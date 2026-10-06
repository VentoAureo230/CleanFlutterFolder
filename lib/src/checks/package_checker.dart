import '../root/root_finder.dart';

/// Packages the generated code needs that the project doesn't declare yet.
class MissingPackages {
  final List<String> runtime;
  final List<String> dev;

  const MissingPackages({required this.runtime, required this.dev});

  bool get isEmpty => runtime.isEmpty && dev.isEmpty;
}

class PackageChecker {
  /// Imported by the generated code.
  static const runtimePackages = [
    'equatable',
    'flutter_bloc',
    'get_it',
    'retrofit',
    'dio',
  ];

  /// Generate `*_api_service.g.dart`.
  static const devPackages = ['retrofit_generator', 'build_runner'];

  /// A package counts as present in either `dependencies` or
  /// `dev_dependencies`.
  MissingPackages check(FlutterProject project) {
    bool missing(String package) => !project.dependencies.contains(package);
    return MissingPackages(
      runtime: runtimePackages.where(missing).toList(),
      dev: devPackages.where(missing).toList(),
    );
  }
}
