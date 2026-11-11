import 'package:chess_escape/domain/repositories/progress_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'progress_provider.g.dart';

@riverpod
ProgressRepository progressRepository(Ref ref) {
  throw UnimplementedError();
}

@riverpod
class HighestUnlockedLevel extends _$HighestUnlockedLevel {
  @override
  Future<int> build() {
    return ref.watch(progressRepositoryProvider).getHighestUnlockedLevel();
  }

  Future<void> updateLevel(int level) async {
    final currentLevel = state.value ?? 1;
    if (level > currentLevel) {
      await ref
          .read(progressRepositoryProvider)
          .updateHighestUnlockedLevel(level);
      state = AsyncData(level);
    }
  }
}
