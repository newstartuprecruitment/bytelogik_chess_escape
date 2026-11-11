import 'package:chess_escape/domain/entities/game_state.dart';
import 'package:chessboard_ui/chessboard_ui.dart';
import 'package:chessboard_ui/domain/entities/square.dart';

class GameDelegate implements ChessboardBehaviorDelegate {
  final GameState state;

  const GameDelegate(this.state);

  @override
  bool canSelectPiece(Piece piece, Square square) =>
      state.canSelectPiece(piece, square);

  @override
  bool isValid(Turn turn) => state.isValid(turn);

  @override
  Set<Square> getValidMoves(Piece piece, Square square) =>
      state.getValidMoves(piece, square);

  @override
  void onPieceSelected(Square square) {}
}
