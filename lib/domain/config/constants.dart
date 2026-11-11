import 'package:chessboard_ui/domain/entities/piece.dart';
import 'package:chessboard_ui/domain/entities/square.dart';

class Constants {
  static const List<Piece> pieces = [
    Piece.whitePawn,
    Piece.whiteKnight,
    Piece.whiteBishop,
    Piece.whiteRook,
    Piece.whiteQueen,
    Piece.whiteKing,
  ];

  static List<Square> get innerSquares => [
    for (int r = 1; r < 7; r++)
      for (int f = 1; f < 7; f++) Square.fromRankFile(r, f),
  ];

  static String toSquare(Square s) => s.name;
}
