class GameStorage {
  static String? _savedGame;

  String? load() => _savedGame;

  void save(String value) {
    _savedGame = value;
  }
}
