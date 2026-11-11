import 'package:chess_escape/application/state/chess_escape_provider.dart';
import 'package:chess_escape/application/state/game_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameStatusDisplay extends ConsumerWidget {
  const GameStatusDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(chessEscapeGameProvider);
    final gameNotifier = ref.read(chessEscapeGameProvider.notifier);
    final gameDataRepo = ref.read(gameDataRepositoryProvider);
    final totalLevels = gameDataRepo.totalLevels;
    final hasNextLevel =
        totalLevels == 0 || gameState.currentLevel < totalLevels;

    if (gameState.isWon) {
      return Padding(
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
      );
    } else if (gameState.isLost) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Game Over',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
