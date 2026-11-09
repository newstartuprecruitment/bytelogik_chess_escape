extension type const Square(int index) implements int {
  static const int minIndex = 0;
  static const int maxIndex = 63;
  static const int numRanks = 8;
  static const int numFiles = 8;

  factory Square.fromRankFile(int rank, int file) {
    if (rank < 0 || rank > 7) throw RangeError.range(rank, 0, 7, 'rank');
    if (file < 0 || file > 7) throw RangeError.range(file, 0, 7, 'file');
    return Square(rank * 8 + file);
  }

  factory Square.fromName(String name) {
    if (name.length != 2) {
      throw const FormatException('Invalid algebraic notation length');
    }

    final fileChar = name[0].toLowerCase();
    final rankChar = name[1];

    final file = fileChar.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rankVal = int.tryParse(rankChar);

    if (file < 0 || file > 7 || rankVal == null || rankVal < 1 || rankVal > 8) {
      throw FormatException('Invalid coordinate: $name');
    }

    final rank = 8 - rankVal;

    return Square(rank * 8 + file);
  }

  int get rank => index ~/ 8;

  int get file => index % 8;

  bool get isValid => index >= 0 && index <= 63;

  bool get isLight => (rank + file).isEven;

  bool get isDark => !isLight;

  String get fileName => String.fromCharCode('a'.codeUnitAt(0) + file);

  String get rankName => (8 - rank).toString();

  String get name {
    if (!isValid) return 'invalid';
    final fileChar = String.fromCharCode('a'.codeUnitAt(0) + file);
    final rankChar = (8 - rank).toString();
    return '$fileChar$rankChar';
  }

  Square? offset(int rankOffset, int fileOffset) {
    final newRank = rank + rankOffset;
    final newFile = file + fileOffset;
    if (newRank < 0 || newRank > 7 || newFile < 0 || newFile > 7) return null;
    return Square.fromRankFile(newRank, newFile);
  }
}
