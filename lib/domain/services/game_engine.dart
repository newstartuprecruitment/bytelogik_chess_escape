import 'package:chess_escape/domain/entities/game_state.dart';
import 'package:chess_escape/domain/services/game_logic.dart';
import 'package:chessboard_ui/domain/entities/piece.dart';
import 'package:chessboard_ui/domain/entities/square.dart';
import 'package:chessboard_ui/domain/entities/turn.dart';
import 'package:chessboard_ui/domain/services/fen_service.dart';

class GameEngine {
  final GameLogic _logic;

  GameEngine({GameLogic? logic}) : _logic = logic ?? GameLogic();

  Map<Piece, Square> parseFenToPieces(String fen) {
    final parsed = FenService.parseFen(fen);
    final map = <Piece, Square>{};
    for (final entry in parsed.pieces.entries) {
      map[entry.value] = Square(entry.key);
    }
    return map;
  }

  GameState handleTurn(GameState state, Turn turn) {
    if (state.isWon || state.isLost) return state;

    final startCoord = turn.from;
    final targetCoord = turn.to;

    Piece? piece;
    for (final entry in state.currentPieces.entries) {
      if (entry.value == startCoord) {
        piece = entry.key;
        break;
      }
    }
    if (piece == null) return state;

    final nextDeleted = Set<Square>.from(state.deletedSquares);
    final nextPieces = Map<Piece, Square>.from(state.currentPieces);

    if (startCoord.rank >= 1 &&
        startCoord.rank <= 6 &&
        startCoord.file >= 1 &&
        startCoord.file <= 6) {
      nextDeleted.add(startCoord);
    }

    if (piece.role == PieceRole.pawn && nextDeleted.contains(targetCoord)) {
      nextDeleted.remove(targetCoord);
    }

    nextPieces[piece] = targetCoord;

    if (piece.role != PieceRole.king &&
        (targetCoord.rank == 0 ||
            targetCoord.rank == 7 ||
            targetCoord.file == 0 ||
            targetCoord.file == 7)) {
      nextPieces.remove(piece);
    }

    bool isWon = false;
    bool isLost = false;

    if (nextPieces.length == 1 && nextPieces.containsKey(Piece.whiteKing)) {
      isWon = true;
    } else {
      bool hasMoves = false;
      for (final entry in nextPieces.entries) {
        if (!_logic.isAdjacentToAnotherPiece(
          entry.value,
          entry.key,
          nextPieces,
        )) {
          continue;
        }
        final moves = _logic.getReachableSquares(
          entry.key,
          entry.value,
          nextPieces,
          nextDeleted,
        );
        if (moves.isNotEmpty) {
          hasMoves = true;
          break;
        }
      }
      if (!hasMoves) {
        isLost = true;
      }
    }

    return state.copyWith(
      deletedSquares: nextDeleted,
      currentPieces: nextPieces,
      isWon: isWon,
      isLost: isLost,
    );
  }
}
