/// Low-level exceptions thrown by data sources.
///
/// These are NOT meant to reach the UI. Data source code throws one of these
/// (or a normal platform exception) and the corresponding repository
/// implementation catches it and maps it to a [Failure] in `core/error/failures.dart`.
///
/// Each repository implementation is the single place where `try/catch` turns
/// one of these into a [Failure].
class CacheException implements Exception {
  const CacheException([this.message]);

  final String? message;

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when a requested item is not present.
class NotFoundException implements Exception {
  const NotFoundException([this.message]);

  final String? message;

  @override
  String toString() => 'NotFoundException: $message';
}