import 'dart:math';

import 'package:chess_escape/domain/services/game_logic.dart';
import 'package:chessboard_ui/domain/entities/piece.dart';
import 'package:chessboard_ui/domain/entities/square.dart';
import 'package:collection/collection.dart';

const List<Piece> pieces = [
  Piece.whitePawn,
  Piece.whiteKnight,
  Piece.whiteBishop,
  Piece.whiteRook,
  Piece.whiteQueen,
  Piece.whiteKing,
];

List<Square> get innerSquares => [
  for (int r = 1; r < 7; r++)
    for (int f = 1; f < 7; f++) Square.fromRankFile(r, f),
];

String toSquare(Square s) => s.name;

class SearchNode implements Comparable<SearchNode> {
  final int h;
  final int stateId;
  final Map<Piece, Square> pieces;
  final Set<Square> isDeleted;
  final int steps;
  final String solution;

  SearchNode(
    this.h,
    this.stateId,
    this.pieces,
    this.isDeleted,
    this.steps,
    this.solution,
  );

  @override
  int compareTo(SearchNode other) {
    int res = h.compareTo(other.h);
    if (res == 0) {
      return stateId.compareTo(other.stateId);
    }
    return res;
  }
}

class SimulationData {
  int infeasibleCount = 0;
  int feasibleCount = 0;
  final Map<int, int> stepsCount = {for (var i = 5; i <= 15; i++) i: 0};
  int steps15PlusCount = 0;
  final List<String> csvRows = [];

  void recordSuccess(
    int steps,
    Map<Piece, Square> initialBoard,
    String solution,
  ) {
    feasibleCount++;
    if (steps >= 5 && steps <= 15) {
      stepsCount[steps] = stepsCount[steps]! + 1;
    } else if (steps > 15) {
      steps15PlusCount++;
    }

    String initialBoardStr = [
      Piece.whitePawn,
      Piece.whiteKnight,
      Piece.whiteBishop,
      Piece.whiteRook,
      Piece.whiteQueen,
      Piece.whiteKing,
    ].map((piece) => toSquare(initialBoard[piece]!)).join("-");
    csvRows.add("$steps;$initialBoardStr;$solution");
  }

  void recordFailure() {
    infeasibleCount++;
  }

  void printResults() {
    print("infeasible_count: $infeasibleCount");
    print("feasible_count: $feasibleCount");
    for (int stepValue = 5; stepValue <= 15; stepValue++) {
      print("$stepValue: ${stepsCount[stepValue]}");
    }
    print("15+: $steps15PlusCount");
  }

  void printCsv() {
    print("number_of_steps;initial_board;solution");
    for (final row in csvRows) {
      print(row);
    }
  }
}

class ZobristHasher {
  final Random _random;
  final Map<Piece, Map<Square, int>> _piecesHash = {};
  final Map<Square, int> _deletedHash = {};

  ZobristHasher(this._random) {
    _initHashes();
  }

  int _random64() {
    return (_random.nextInt(0x7FFFFFFF) << 32) ^ _random.nextInt(0x7FFFFFFF);
  }

  void _initHashes() {
    for (final piece in pieces) {
      _piecesHash[piece] = {};
      for (int i = 0; i < 64; i++) {
        _piecesHash[piece]![Square(i)] = _random64();
      }
    }

    for (int i = 0; i < 64; i++) {
      _deletedHash[Square(i)] = _random64();
    }
  }

  int getHash(Map<Piece, Square> pieces, Set<Square> isDeleted) {
    int h = 0;
    pieces.forEach((piece, coord) {
      h ^= _piecesHash[piece]![coord]!;
    });
    for (final coord in isDeleted) {
      h ^= _deletedHash[coord]!;
    }
    return h;
  }
}

class ChessSimulation {
  final int iterations;
  final Random random = Random();
  late final ZobristHasher hasher;
  final SimulationData data = SimulationData();
  final GameLogic logic = GameLogic();

  ChessSimulation(this.iterations) {
    hasher = ZobristHasher(random);
  }

  void run() {
    Set<int> usedInputs = {};
    for (int i = 0; i < iterations; i++) {
      Map<Piece, Square> initialPieces = {};
      Set<Square> isDeleted = {};

      while (true) {
        var selectedCoords = (List.of(
          innerSquares,
        )..shuffle(random)).sublist(0, 6);
        if (logic.hasAdjacentPair(selectedCoords)) {
          var shuffledPieces = List.of(pieces)..shuffle(random);
          initialPieces = {
            for (int j = 0; j < shuffledPieces.length; j++)
              shuffledPieces[j]: selectedCoords[j],
          };

          isDeleted = {};
          int h = hasher.getHash(initialPieces, isDeleted);
          if (!usedInputs.contains(h)) {
            usedInputs.add(h);
            break;
          }
        }
      }

      _solveState(initialPieces, isDeleted);
    }

    data.printCsv();
    data.printResults();
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

  void _solveState(
    Map<Piece, Square> initialPieces,
    Set<Square> initialDeleted,
  ) {
    int stateId = 0;
    var queue = PriorityQueue<SearchNode>();
    Set<int> visited = {hasher.getHash(initialPieces, initialDeleted)};

    queue.add(
      SearchNode(
        getHeuristic(initialPieces, initialDeleted),
        stateId,
        initialPieces,
        initialDeleted,
        0,
        "",
      ),
    );

    bool goalReached = false;

    while (queue.isNotEmpty) {
      SearchNode current = queue.removeFirst();

      if (current.pieces.length == 1 &&
          current.pieces.containsKey(Piece.whiteKing)) {
        goalReached = true;
        data.recordSuccess(current.steps, initialPieces, current.solution);
        break;
      }

      if (current.steps >= 25) continue;

      for (final entry in current.pieces.entries) {
        Piece piece = entry.key;
        Square startCoord = entry.value;

        if (!logic.isAdjacentToAnotherPiece(
          startCoord,
          piece,
          current.pieces,
        )) {
          continue;
        }

        var reachableSquares = logic.getReachableSquares(
          piece,
          startCoord,
          current.pieces,
          current.isDeleted,
        );

        for (final target in reachableSquares) {
          var nextPieces = Map<Piece, Square>.from(current.pieces);
          var nextIsDeleted = Set<Square>.from(current.isDeleted);

          nextPieces[piece] = target;

          if (startCoord.rank >= 1 &&
              startCoord.rank <= 6 &&
              startCoord.file >= 1 &&
              startCoord.file <= 6) {
            nextIsDeleted.add(startCoord);
          }

          if (piece.role == PieceRole.pawn && nextIsDeleted.contains(target)) {
            nextIsDeleted.remove(target);
          }

          if (piece.role != PieceRole.king &&
              (target.rank == 0 ||
                  target.rank == 7 ||
                  target.file == 0 ||
                  target.file == 7)) {
            nextPieces.remove(piece);
          }

          int nextHash = hasher.getHash(nextPieces, nextIsDeleted);
          if (!visited.contains(nextHash)) {
            visited.add(nextHash);
            stateId++;

            String moveStr =
                "${toSquare(startCoord)}"
                "${toSquare(target)}";
            String nextSolution = current.solution.isEmpty
                ? moveStr
                : "${current.solution} $moveStr";

            queue.add(
              SearchNode(
                getHeuristic(nextPieces, nextIsDeleted),
                stateId,
                nextPieces,
                nextIsDeleted,
                current.steps + 1,
                nextSolution,
              ),
            );
          }
        }
      }
    }

    if (!goalReached) {
      data.recordFailure();
    }
  }
}

void main() {
  final simulation = ChessSimulation(50);
  simulation.run();
}
