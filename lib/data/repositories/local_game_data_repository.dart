import 'package:chess_escape/application/services/game_data.dart';
import 'package:chess_escape/domain/repositories/game_data_repository.dart';
import 'package:chessboard_ui/domain/entities/piece.dart';
import 'package:chessboard_ui/domain/entities/square.dart';

class LocalGameDataRepository implements GameDataRepository {
  final GameData _gameData;

  LocalGameDataRepository({GameData? gameData})
    : _gameData = gameData ?? GameData();

  @override
  Future<void> loadLevels() async {
    await GameData.load();
  }

  @override
  String getFen(int level) {
    return _gameData.getFen(level);
  }

  @override
  String generateInitialFen(List<String> positions) {
    return _gameData.generateInitialFen(positions);
  }

  @override
  String fenFromPieces(Map<Piece, Square> pieces) {
    return _gameData.fenFromPieces(pieces);
  }

  @override
  int get totalLevels => GameData.totalLevels;
}
