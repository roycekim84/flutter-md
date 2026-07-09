import 'package:web/web.dart' as web;

class GameStorage {
  static const _key = 'lumir_mud_save';

  String? load() => web.window.localStorage.getItem(_key);

  void save(String value) {
    web.window.localStorage.setItem(_key, value);
  }
}
