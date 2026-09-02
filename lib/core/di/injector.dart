import 'package:get_it/get_it.dart';

/// Central dependency injection container.
///
/// Data sources and repositories are registered as `lazySingleton` (one shared
/// instance — they hold state like the open DB / cache). Cubits are registered
/// as `factory` so a fresh instance is created per screen. Registrations are
/// grouped by feature with a comment header per block. Register repositories
/// before cubits so lazy resolution can depend on them.
abstract final class Injector {
  static final GetIt getIt = GetIt.instance;

  /// Must be called exactly once, from `main()`, before `runApp`.
  static void setupLocator() {
    // ------------------------------------------------------------------
    // Track 1 — Core & Foundation
    // (No feature registrations yet — this track is pure infrastructure.)
    // ------------------------------------------------------------------
  }
}