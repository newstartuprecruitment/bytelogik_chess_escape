import 'package:chess_escape/application/services/game_data.dart';
import 'package:chess_escape/domain/entities/game_state.dart';
import 'package:chess_escape/domain/services/game_engine.dart';
import 'package:chessboard_ui/domain/entities/turn.dart';

class GameRunner {
  final GameEngine engine;
  final GameData gameData;
  int currentLevel;
  GameState? _currentState;

  GameRunner({
    required this.engine,
    required this.gameData,
    this.currentLevel = 1,
  });

  GameState initialize() {
    final fen = gameData.getFen(currentLevel);
    final pieces = engine.parseFenToPieces(fen);
    _currentState = GameState(currentPieces: pieces);
    return _currentState!;
  }

  GameState executeTurn(Turn turn) {
    if (_currentState == null) {
      throw StateError('GameRunner is not initialized.');
    }
    _currentState = engine.handleTurn(_currentState!, turn);
    return _currentState!;
  }

  GameState reset([int? level]) {
    if (level != null) {
      currentLevel = level;
    }
    return initialize();
  }
}
