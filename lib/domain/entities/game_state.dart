import 'package:chess_escape/domain/services/game_logic.dart';
import 'package:chessboard_ui/domain/entities/piece.dart';
import 'package:chessboard_ui/domain/entities/square.dart';
import 'package:chessboard_ui/domain/entities/turn.dart';

class GameState {
  static final GameLogic _logic = GameLogic();

  final Set<Square> deletedSquares;
  final bool isWon;
  final bool isLost;
  final Map<Piece, Square> currentPieces;
  final bool canUndo;
  final bool canRedo;

  const GameState({
    this.deletedSquares = const {},
    this.isWon = false,
    this.isLost = false,
    this.currentPieces = const {},
    this.canUndo = false,
    this.canRedo = false,
  });

  Piece? pieceAt(Square square) {
    for (final entry in currentPieces.entries) {
      if (entry.value == square) {
        return entry.key;
      }
    }
    return null;
  }

  bool canSelectPiece(Piece piece, Square square) {
    return _logic.isAdjacentToAnotherPiece(square, piece, currentPieces);
  }

  Set<Square> getValidMoves(Piece piece, Square square) {
    return _logic
        .getReachableSquares(piece, square, currentPieces, deletedSquares)
        .toSet();
  }

  bool isValid(Turn turn) {
    final piece = pieceAt(turn.from);
    if (piece == null) return false;
    return getValidMoves(piece, turn.from).contains(turn.to);
  }

  GameState copyWith({
    Set<Square>? deletedSquares,
    bool? isWon,
    bool? isLost,
    Map<Piece, Square>? currentPieces,
    bool? canUndo,
    bool? canRedo,
  }) {
    return GameState(
      deletedSquares: deletedSquares ?? this.deletedSquares,
      isWon: isWon ?? this.isWon,
      isLost: isLost ?? this.isLost,
      currentPieces: currentPieces ?? this.currentPieces,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
    );
  }
}
