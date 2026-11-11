import 'package:chess_escape/application/state/chess_escape_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameInfo extends ConsumerWidget {
  final Widget board;

  const GameInfo({super.key, required this.board});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(chessEscapeGameProvider);
    final gameNotifier = ref.read(chessEscapeGameProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Escape'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: gameNotifier.reset,
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
