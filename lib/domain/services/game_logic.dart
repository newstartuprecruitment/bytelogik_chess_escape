import 'package:chessboard_ui/domain/entities/piece.dart';
import 'package:chessboard_ui/domain/entities/square.dart';

class GameLogic {
  bool hasAdjacentPair(List<Square> coords) {
    for (int i = 0; i < coords.length; i++) {
      for (int j = i + 1; j < coords.length; j++) {
        if ((coords[i].rank - coords[j].rank).abs() <= 1 &&
            (coords[i].file - coords[j].file).abs() <= 1) {
          return true;
        }
      }
    }
    return false;
  }

  bool isAdjacentToAnotherPiece(
    Square square,
    Piece movingPiece,
    Map<Piece, Square> currentPieces,
  ) {
    for (final int dRank in const [-1, 0, 1]) {
      for (final int dFile in const [-1, 0, 1]) {
        if (dRank == 0 && dFile == 0) continue;
        int adjRank = square.rank + dRank;
        int adjFile = square.file + dFile;

        if (adjRank >= 0 && adjRank < 8 && adjFile >= 0 && adjFile < 8) {
          for (final entry in currentPieces.entries) {
            if (entry.key != movingPiece &&
                entry.value.rank == adjRank &&
                entry.value.file == adjFile) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  List<Square> getReachableSquares(
    Piece piece,
    Square start,
    Map<Piece, Square> pieces,
    Set<Square> isDeleted,
  ) {
    List<Square> reachable = [];
    Set<Square> occupied = pieces.values.toSet();
    int startRank = start.rank;
    int startFile = start.file;

    void addDirectionalMoves(List<(int, int)> directions) {
      for (final d in directions) {
        int targetRank = startRank + d.$1;
        int targetFile = startFile + d.$2;
        while (targetRank >= 0 &&
            targetRank < 8 &&
            targetFile >= 0 &&
            targetFile < 8) {
          final targetSquare = Square.fromRankFile(targetRank, targetFile);
          if (occupied.contains(targetSquare) ||
              isDeleted.contains(targetSquare)) {
            break;
          }
          reachable.add(targetSquare);
          targetRank += d.$1;
          targetFile += d.$2;
        }
      }
    }

    void addFixedMoves(List<(int, int)> moves, {bool requireDeleted = false}) {
      for (final d in moves) {
        int targetRank = startRank + d.$1;
        int targetFile = startFile + d.$2;
        if (targetRank >= 0 &&
            targetRank < 8 &&
            targetFile >= 0 &&
            targetFile < 8) {
          final targetSquare = Square.fromRankFile(targetRank, targetFile);
          bool isOccupied = occupied.contains(targetSquare);
          bool isDel = isDeleted.contains(targetSquare);

          if (!isOccupied && (requireDeleted ? isDel : !isDel)) {
            reachable.add(targetSquare);
          }
        }
      }
    }

    switch (piece.role) {
      case PieceRole.queen:
      case PieceRole.rook:
      case PieceRole.bishop:
        List<(int, int)> directions = [];
        if (piece.role == PieceRole.queen || piece.role == PieceRole.rook) {
          directions.addAll(const [(-1, 0), (1, 0), (0, -1), (0, 1)]);
        }
        if (piece.role == PieceRole.queen || piece.role == PieceRole.bishop) {
          directions.addAll(const [(-1, -1), (-1, 1), (1, -1), (1, 1)]);
        }
        addDirectionalMoves(directions);
      case PieceRole.knight:
        addFixedMoves(const [
          (-2, -1),
          (-2, 1),
          (-1, -2),
          (-1, 2),
          (1, -2),
          (1, 2),
          (2, -1),
          (2, 1),
        ]);
      case PieceRole.king:
        addFixedMoves(const [
          (-1, -1),
          (-1, 0),
          (-1, 1),
          (0, -1),
          (0, 1),
          (1, -1),
          (1, 0),
          (1, 1),
        ]);
      case PieceRole.pawn:
        addFixedMoves(const [(-1, 0), (1, 0)]);
        addFixedMoves(const [
          (-1, -1),
          (-1, 1),
          (1, -1),
          (1, 1),
        ], requireDeleted: true);
    }
    return reachable;
  }
}
