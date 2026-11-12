import 'package:chess_escape/presentation/game_controls.dart';
import 'package:chess_escape/presentation/game_navigation.dart';
import 'package:chess_escape/presentation/game_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameInfo extends ConsumerWidget {
  final Widget board;

  const GameInfo({super.key, required this.board});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: const GameNavigation(),
        title: Text('Chess Escape'),
        actions: const [GameControls()],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const GameStatusDisplay(), board],
        ),
      ),
    );
  }
}
