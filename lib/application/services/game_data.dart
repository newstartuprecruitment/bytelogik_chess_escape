import 'package:chess_escape/domain/config/constants.dart';
import 'package:chessboard_ui/core/utils/debug_log.dart';
import 'package:chessboard_ui/domain/entities/piece.dart';
import 'package:chessboard_ui/domain/entities/square.dart';
import 'package:flutter/services.dart';

class GameData {
  static final List<String> _fens = [];

  static Future<void> load() async {
    try {
      _fens.clear();
      final data = await rootBundle.loadString('assets/data/input.csv');
      final lines = data.split('\n');
      for (var line in lines) {
        line = line.trim();
        if (line.isNotEmpty) {
          if (line.contains(',')) {
            final parts = line.split(',');
            _fens.add(parts[1].trim());
          } else if (line.contains(';')) {
            final parts = line.split(';');
            _fens.add(parts[1].trim());
          } else {
            _fens.add(line);
          }
        }
      }
    } catch (_) {}
  }

  String generateInitialFen(List<String> positions) {
    final grid = List.generate(8, (_) => List.filled(8, ''));

    for (int i = 0; i < positions.length && i < Constants.pieces.length; i++) {
      final pos = positions[i];
      final file = pos.codeUnitAt(0) - 97;
      final rank = 8 - int.parse(pos[1]);

      final piece = Constants.pieces[i];
      String char = '';
      switch (piece.role) {
        case PieceRole.pawn:
          char = 'p';
        case PieceRole.knight:
          char = 'n';
        case PieceRole.bishop:
          char = 'b';
        case PieceRole.rook:
          char = 'r';
        case PieceRole.queen:
          char = 'q';
        case PieceRole.king:
          char = 'k';
      }
      if (piece.color == PieceColor.white) {
        char = char.toUpperCase();
      }
      grid[rank][file] = char;
    }

    String fen = '';
    for (int r = 0; r < 8; r++) {
      int emptyCount = 0;
      for (int f = 0; f < 8; f++) {
        if (grid[r][f] == '') {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            fen += emptyCount.toString();
            emptyCount = 0;
          }
          fen += grid[r][f];
        }
      }
      if (emptyCount > 0) {
        fen += emptyCount.toString();
      }
      if (r < 7) fen += '/';
    }
    return '$fen w - - 0 1';
  }

  String fenFromPieces(Map<Piece, Square> pieces) {
    final grid = List.generate(8, (_) => List.filled(8, ''));

    pieces.forEach((piece, square) {
      final pos = square.name;
      final file = pos.codeUnitAt(0) - 97;
      final rank = 8 - int.parse(pos[1]);

      String char = '';
      switch (piece.role) {
        case PieceRole.pawn:
          char = 'p';
        case PieceRole.knight:
          char = 'n';
        case PieceRole.bishop:
          char = 'b';
        case PieceRole.rook:
          char = 'r';
        case PieceRole.queen:
          char = 'q';
        case PieceRole.king:
          char = 'k';
      }
      if (piece.color == PieceColor.white) {
        char = char.toUpperCase();
      }
      grid[rank][file] = char;
    });

    String fen = '';
    for (int r = 0; r < 8; r++) {
      int emptyCount = 0;
      for (int f = 0; f < 8; f++) {
        if (grid[r][f] == '') {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            fen += emptyCount.toString();
            emptyCount = 0;
          }
          fen += grid[r][f];
        }
      }
      if (emptyCount > 0) {
        fen += emptyCount.toString();
      }
      if (r < 7) fen += '/';
    }
    return '$fen w - - 0 1';
  }

  String getFen(int level) {
    if (_fens.isEmpty) {
      return '';
    }

    final boardData = _fens[level % _fens.length];
    infoLog(boardData);

    if (boardData.contains('-')) {
      final positions = boardData.split('-');
      return generateInitialFen(positions);
    }

    return boardData;
  }

  static int get totalLevels => _fens.length;
}
