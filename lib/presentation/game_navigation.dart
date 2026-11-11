import 'package:chess_escape/application/state/chess_escape_provider.dart';
import 'package:chess_escape/application/state/game_data_provider.dart';
import 'package:chess_escape/application/state/progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameNavigation extends ConsumerWidget {
  const GameNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(chessEscapeGameProvider);
    final gameNotifier = ref.read(chessEscapeGameProvider.notifier);
    final gameDataRepo = ref.read(gameDataRepositoryProvider);
    final highestUnlockedAsync = ref.watch(highestUnlockedLevelProvider);

    final highestUnlocked = highestUnlockedAsync.value ?? 1;
    final totalLevels = gameDataRepo.totalLevels;
    final hasNextLevel =
        totalLevels == 0 || gameState.currentLevel < totalLevels;
    final canGoNext =
        hasNextLevel &&
        (gameState.currentLevel < highestUnlocked || gameState.isWon);

    return Row(
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
    );
  }
}
