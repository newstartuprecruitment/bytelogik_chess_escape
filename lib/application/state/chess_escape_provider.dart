import 'package:chess_escape/application/controller/game_runner.dart';
import 'package:chess_escape/application/services/game_data.dart';
import 'package:chess_escape/domain/entities/game_state.dart';
import 'package:chess_escape/domain/services/game_engine.dart';
import 'package:chessboard_ui/chessboard_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chess_escape_provider.g.dart';

@riverpod
class ChessEscapeGame extends _$ChessEscapeGame {
  final GameRunner runner;

  ChessEscapeGame()
    : runner = GameRunner(engine: GameEngine(), gameData: GameData());

  @override
  GameState build() {
    return runner.initialize();
  }

  void reset() {
    state = runner.reset();
  }

  void handleTurn(Turn turn) {
    state = runner.executeTurn(turn);
  }
}
