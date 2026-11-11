// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chess_escape_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChessEscapeGame)
final chessEscapeGameProvider = ChessEscapeGameProvider._();

final class ChessEscapeGameProvider
    extends $NotifierProvider<ChessEscapeGame, GameState> {
  ChessEscapeGameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chessEscapeGameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chessEscapeGameHash();

  @$internal
  @override
  ChessEscapeGame create() => ChessEscapeGame();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameState>(value),
    );
  }
}

String _$chessEscapeGameHash() => r'9d1ee7ec6cf3d710966a7ef91c57cda60ac61f78';

abstract class _$ChessEscapeGame extends $Notifier<GameState> {
  GameState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GameState, GameState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GameState, GameState>,
              GameState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
