import 'package:equatable/equatable.dart';

enum PieceRole { pawn, knight, bishop, rook, queen, king }

enum PieceColor { white, black }

class Piece extends Equatable {
  final PieceRole role;
  final PieceColor color;

  const Piece({required this.role, required this.color});

  @override
  List<Object?> get props => [role, color];

  @override
  String toString() => '$color $role';

  static const whitePawn = Piece(role: PieceRole.pawn, color: PieceColor.white);
  static const whiteKnight = Piece(
    role: PieceRole.knight,
    color: PieceColor.white,
  );
  static const whiteBishop = Piece(
    role: PieceRole.bishop,
    color: PieceColor.white,
  );
  static const whiteRook = Piece(role: PieceRole.rook, color: PieceColor.white);
  static const whiteQueen = Piece(
    role: PieceRole.queen,
    color: PieceColor.white,
  );
  static const whiteKing = Piece(role: PieceRole.king, color: PieceColor.white);

  static const blackPawn = Piece(role: PieceRole.pawn, color: PieceColor.black);
  static const blackKnight = Piece(
    role: PieceRole.knight,
    color: PieceColor.black,
  );
  static const blackBishop = Piece(
    role: PieceRole.bishop,
    color: PieceColor.black,
  );
  static const blackRook = Piece(role: PieceRole.rook, color: PieceColor.black);
  static const blackQueen = Piece(
    role: PieceRole.queen,
    color: PieceColor.black,
  );
  static const blackKing = Piece(role: PieceRole.king, color: PieceColor.black);
}
