import 'dart:math';

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

  int getHeuristic(Map<Piece, Square> pieces, Set<Square> isDeleted) {
    int h = (pieces.length - 1) * 10;
    Set<Square> occupied = pieces.values.toSet();

    pieces.forEach((piece, coord) {
      if (piece.role == PieceRole.king) return;

      int rank = coord.rank;
      int file = coord.file;
      int distToEdge = [rank, 7 - rank, file, 7 - file].reduce(min);

      if (piece.role == PieceRole.pawn) {
        h += distToEdge;
      } else if (piece.role == PieceRole.knight) {
        h += (distToEdge + 1) ~/ 2;
      } else if (piece.role == PieceRole.queen ||
          piece.role == PieceRole.rook ||
          piece.role == PieceRole.bishop) {
        List<(int, int)> directions = [];
        if (piece.role == PieceRole.queen || piece.role == PieceRole.rook) {
          directions.addAll(const [(-1, 0), (1, 0), (0, -1), (0, 1)]);
        }
        if (piece.role == PieceRole.queen || piece.role == PieceRole.bishop) {
          directions.addAll(const [(-1, -1), (-1, 1), (1, -1), (1, 1)]);
        }

        bool hasValidPath = false;
        for (final d in directions) {
          int currentRank = rank + d.$1;
          int currentFile = file + d.$2;
          while (currentRank >= 0 &&
              currentRank < 8 &&
              currentFile >= 0 &&
              currentFile < 8) {
            final currentSquare = Square.fromRankFile(currentRank, currentFile);
            if (occupied.contains(currentSquare) ||
                isDeleted.contains(currentSquare)) {
              break;
            }
            if (currentRank == 0 ||
                currentRank == 7 ||
                currentFile == 0 ||
                currentFile == 7) {
              hasValidPath = true;
              break;
            }
            currentRank += d.$1;
            currentFile += d.$2;
          }
          if (hasValidPath) break;
        }
        h += hasValidPath ? 1 : 2;
      }
    });

    return h;
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
