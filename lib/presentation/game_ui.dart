import 'package:chess_escape/application/state/chess_escape_provider.dart';
import 'package:chess_escape/application/state/game_data_provider.dart';
import 'package:chess_escape/presentation/game_board.dart';
import 'package:chess_escape/presentation/game_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameUi extends ConsumerWidget {
  const GameUi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameDataRepository = ref.watch(gameDataRepositoryProvider);

    ref.listen(chessEscapeGameProvider, (previous, next) {
      if (previous != next && !next.canUndo && !next.canRedo) {
        final fen = gameDataRepository.fenFromPieces(next.currentPieces);
        ref.read(boardControllerInstanceProvider).loadFen(fen);
      }
    });

    return const GameInfo(board: GameBoard());
  }
}
