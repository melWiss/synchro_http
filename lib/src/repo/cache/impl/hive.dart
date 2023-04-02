import 'package:synchro_http/src/repo/cache/repo.dart';

class HiveRepo implements RepoInterface {
  /// db instance
  Box<String>? _box;

  /// the name of the box
  final String _name;

  HiveRepo({
    required String name,
  }) : _name = name;

  @override
  Future init() async {
    _box = await Hive.openBox<String>(_name);
  }

  /// a getter for the box instance
  Box get box => _box!;
  @override
  Future clear() async {
    await _box!.clear();
  }

  @override
  Future delete(String key) async {
    await _box!.delete(key);
  }

  @override
  Future<String> get(String key) async {
    return _box!.get(key)!;
  }

  @override
  Future<Map<String, String>> get getAll async {
    Map<String, String> returnedData = {};
    _box!.keys.forEach((element) {
      returnedData.addAll({element: _box!.get(element)!});
    });
    return returnedData;
  }

  @override
  Future<Map<String, String>> get getNonDecodedAll => getAll;

  @override
  Future insert(String json, String key) async {
    await _box!.put(key, json);
  }

  @override
  Future update(String json, String key) async {
    await _box!.put(key, json);
  }

  @override
  Future write(String json, String key) async {
    await _box!.put(key, json);
  }
}
