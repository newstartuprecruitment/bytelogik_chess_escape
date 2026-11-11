import 'package:chess_escape/application/state/chess_escape_provider.dart';
import 'package:chess_escape/application/state/game_data_provider.dart';
import 'package:chess_escape/application/state/progress_provider.dart';
import 'package:chess_escape/presentation/game_board.dart';
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
    final gameDataRepo = ref.read(gameDataRepositoryProvider);
    final highestUnlockedAsync = ref.watch(highestUnlockedLevelProvider);

    final highestUnlocked = highestUnlockedAsync.value ?? 1;
    final totalLevels = gameDataRepo.totalLevels;
    final hasNextLevel =
        totalLevels == 0 || gameState.currentLevel < totalLevels;
    final canGoNext =
        hasNextLevel &&
        (gameState.currentLevel < highestUnlocked || gameState.isWon);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous Level',
              onPressed: gameState.currentLevel > 1
                  ? () => gameNotifier.previousLevel()
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next Level',
              onPressed: canGoNext ? () => gameNotifier.nextLevel() : null,
            ),
          ],
        ),
        title: Text('Chess Escape - Level ${gameState.currentLevel}'),
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
              boardController.loadFen(
                gameDataRepo.getFen(gameState.currentLevel),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (gameState.isWon)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      hasNextLevel ? 'You Won!' : 'You completed All Levels!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (hasNextLevel) ...[
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => gameNotifier.nextLevel(),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next Level'),
                      ),
                    ],
                  ],
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
