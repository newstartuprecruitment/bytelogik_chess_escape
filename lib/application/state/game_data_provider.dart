import 'package:chess_escape/domain/repositories/game_data_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_data_provider.g.dart';

@riverpod
GameDataRepository gameDataRepository(Ref ref) {
  throw UnimplementedError();
}

@riverpod
class GameLevelsLoader extends _$GameLevelsLoader {
  @override
  Future<int> build() async {
    final repo = ref.watch(gameDataRepositoryProvider);
    await repo.loadLevels();
    return repo.totalLevels;
  }

  String getFen(int level) {
    return ref.read(gameDataRepositoryProvider).getFen(level);
  }
}
