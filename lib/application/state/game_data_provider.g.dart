// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gameDataRepository)
final gameDataRepositoryProvider = GameDataRepositoryProvider._();

final class GameDataRepositoryProvider
    extends
        $FunctionalProvider<
          GameDataRepository,
          GameDataRepository,
          GameDataRepository
        >
    with $Provider<GameDataRepository> {
  GameDataRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameDataRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameDataRepositoryHash();

  @$internal
  @override
  $ProviderElement<GameDataRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GameDataRepository create(Ref ref) {
    return gameDataRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameDataRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameDataRepository>(value),
    );
  }
}

String _$gameDataRepositoryHash() =>
    r'd43a73fb00c04b73022e28a73ec26cd5b70eaceb';

@ProviderFor(GameLevelsLoader)
final gameLevelsLoaderProvider = GameLevelsLoaderProvider._();

final class GameLevelsLoaderProvider
    extends $AsyncNotifierProvider<GameLevelsLoader, int> {
  GameLevelsLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameLevelsLoaderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameLevelsLoaderHash();

  @$internal
  @override
  GameLevelsLoader create() => GameLevelsLoader();
}

String _$gameLevelsLoaderHash() => r'4d02f08edbe13471ccd7a55d85023d5adf00c571';

abstract class _$GameLevelsLoader extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
