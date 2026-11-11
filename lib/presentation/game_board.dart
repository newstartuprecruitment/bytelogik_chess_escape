import 'package:chess_escape/application/delegates/game_delegate.dart';
import 'package:chess_escape/application/state/chess_escape_provider.dart';
import 'package:chess_escape/application/state/game_data_provider.dart';
import 'package:chessboard_ui/chessboard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final boardControllerInstanceProvider = Provider<ChessboardController>((ref) {
  return ChessboardController();
});

class GameBoard extends ConsumerWidget {
  const GameBoard({super.key});

  static final _theme = BoardTheme(
    lightSquare: BoardTheme.green.lightSquare,
    darkSquare: BoardTheme.green.darkSquare,
    lightLastMove: Colors.transparent,
    darkLastMove: Colors.transparent,
  );

  static final _behaviour = BoardBehaviour(
    isPromotion: (from, to, piece) => false,
  );

  void _onMove(WidgetRef ref, Turn turn) {
    ref.read(chessEscapeGameProvider.notifier).handleTurn(turn);
    final pieces = ref.read(chessEscapeGameProvider).currentPieces;
    final gameDataRepository = ref.read(gameDataRepositoryProvider);
    ref
        .read(boardControllerInstanceProvider)
        .updateFromFen(gameDataRepository.fenFromPieces(pieces));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(chessEscapeGameProvider);
    final boardController = ref.watch(boardControllerInstanceProvider);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
      child: UniversalChessboard(
        controller: boardController,
        behaviour: _behaviour,
        mode: GameMode(GameDelegate(gameState)),
        onMove: (turn) => _onMove(ref, turn),
        style: BoardStyle(
          theme: _theme,
          builders: ChessboardBuilders(
            squareBuilder: (_, square) =>
                gameState.deletedSquares.contains(square)
                ? const Icon(Icons.lock)
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
