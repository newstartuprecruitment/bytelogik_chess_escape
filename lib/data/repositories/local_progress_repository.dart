import 'package:chess_escape/domain/repositories/progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProgressRepository implements ProgressRepository {
  static const String _levelKey = 'highest_unlocked_level';

  @override
  Future<int> getHighestUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_levelKey) ?? 1;
  }

  @override
  Future<void> updateHighestUnlockedLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_levelKey, level);
  }
}
