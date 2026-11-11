import 'package:chess_escape/application/state/chess_escape_provider.dart';
import 'package:chess_escape/application/state/game_data_provider.dart';
import 'package:chess_escape/presentation/game_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameControls extends ConsumerWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(chessEscapeGameProvider);
    final gameNotifier = ref.read(chessEscapeGameProvider.notifier);
    final boardController = ref.read(boardControllerInstanceProvider);
    final gameDataRepo = ref.read(gameDataRepositoryProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: gameState.canUndo
              ? () {
                  gameNotifier.undo();
                  boardController.undo();
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: gameState.canRedo
              ? () {
                  gameNotifier.redo();
                  boardController.redo();
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            gameNotifier.reset();
            boardController.loadFen(
              gameDataRepo.getFen(gameState.currentLevel),
            );
          },
        ),
      ],
    );
  }
}
