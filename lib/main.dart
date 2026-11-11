import 'package:chess_escape/application/state/chess_escape_provider.dart';
import 'package:chess_escape/application/state/game_data_provider.dart';
import 'package:chess_escape/application/state/progress_provider.dart';
import 'package:chess_escape/data/repositories/local_game_data_repository.dart';
import 'package:chess_escape/data/repositories/local_progress_repository.dart';
import 'package:chess_escape/presentation/game_ui.dart';
import 'package:chessboard_ui/chessboard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final gameDataRepository = LocalGameDataRepository();
  await gameDataRepository.loadLevels();

  final progressRepository = LocalProgressRepository();
  final initialLevel = await progressRepository.getHighestUnlockedLevel();

  runApp(
    ProviderScope(
      overrides: [
        progressRepositoryProvider.overrideWithValue(progressRepository),
        gameDataRepositoryProvider.overrideWithValue(gameDataRepository),
        initialFenProvider.overrideWithValue(
          gameDataRepository.getFen(initialLevel),
        ),
        chessEscapeGameProvider.overrideWith(
          () => ChessEscapeGame()..runner.currentLevel = initialLevel,
        ),
      ],
      child: const ChessEscapeApp(),
    ),
  );
}

final _router = GoRouter(
  routes: [GoRoute(path: '/', builder: (context, state) => const GameUi())],
);

class ChessEscapeApp extends StatelessWidget {
  const ChessEscapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Chess Escape',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
