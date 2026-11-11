import 'package:chessboard_ui/domain/entities/piece.dart';
import 'package:chessboard_ui/domain/entities/square.dart';

abstract class GameDataRepository {
  Future<void> loadLevels();
  String getFen(int level);
  String generateInitialFen(List<String> positions);
  String fenFromPieces(Map<Piece, Square> pieces);
  int get totalLevels;
}
