abstract class ProgressRepository {
  Future<int> getHighestUnlockedLevel();
  Future<void> updateHighestUnlockedLevel(int level);
}
