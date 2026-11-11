import 'package:chess_escape/application/services/game_data.dart';
import 'package:chess_escape/domain/entities/game_state.dart';
import 'package:chess_escape/domain/services/game_engine.dart';
import 'package:chessboard_ui/domain/entities/turn.dart';

class GameRunner {
  final GameEngine engine;
  final GameData gameData;
  int currentLevel;
  GameState? _currentState;
  final List<GameState> _undoStack = [];
  final List<GameState> _redoStack = [];

  GameRunner({
    required this.engine,
    required this.gameData,
    this.currentLevel = 1,
  });

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  GameState _syncFlags(GameState state) {
    return state.copyWith(
      canUndo: _undoStack.isNotEmpty,
      canRedo: _redoStack.isNotEmpty,
    );
  }

  GameState initialize() {
    _undoStack.clear();
    _redoStack.clear();
    final fen = gameData.getFen(currentLevel);
    final pieces = engine.parseFenToPieces(fen);
    _currentState = _syncFlags(GameState(currentPieces: pieces));
    return _currentState!;
  }

  GameState executeTurn(Turn turn) {
    if (_currentState == null) {
      throw StateError('GameRunner is not initialized.');
    }
    final nextState = engine.handleTurn(_currentState!, turn);
    if (!identical(nextState, _currentState)) {
      _undoStack.add(_currentState!);
      _redoStack.clear();
      _currentState = _syncFlags(nextState);
    }
    return _currentState!;
  }

  GameState undo() {
    if (_currentState == null) {
      throw StateError('GameRunner is not initialized.');
    }
    if (_undoStack.isEmpty) {
      return _currentState!;
    }
    _redoStack.add(_currentState!);
    final previousState = _undoStack.removeLast();
    _currentState = _syncFlags(previousState);
    return _currentState!;
  }

  GameState redo() {
    if (_currentState == null) {
      throw StateError('GameRunner is not initialized.');
    }
    if (_redoStack.isEmpty) {
      return _currentState!;
    }
    _undoStack.add(_currentState!);
    final nextState = _redoStack.removeLast();
    _currentState = _syncFlags(nextState);
    return _currentState!;
  }

  GameState reset([int? level]) {
    if (level != null) {
      currentLevel = level;
    }
    return initialize();
  }
}
