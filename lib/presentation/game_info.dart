import 'package:chess_escape/application/state/chess_escape_provider.dart';
import 'package:chess_escape/presentation/game_board.dart';
import 'package:chessboard_ui/chessboard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameInfo extends ConsumerWidget {
  final Widget board;

  const GameInfo({super.key, required this.board});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(chessEscapeGameProvider);
    final gameNotifier = ref.read(chessEscapeGameProvider.notifier);
    final boardController = ref.read(boardControllerInstanceProvider);
    final initialFen = ref.read(initialFenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Escape'),
        actions: [
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
              boardController.loadFen(initialFen);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (gameState.isWon)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'You Won!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              )
            else if (gameState.isLost)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Game Over',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            board,
          ],
        ),
      ),
    );
  }
}
