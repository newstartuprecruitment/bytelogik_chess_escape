import 'package:chess_escape/presentation/game_board.dart';
import 'package:chess_escape/presentation/game_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameUi extends ConsumerWidget {
  const GameUi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const GameInfo(board: GameBoard());
  }
}
