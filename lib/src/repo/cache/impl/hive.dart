import 'package:hive/hive.dart';
import 'package:synchro_http/src/repo/cache/repo.dart';

class HiveRepo implements RepoInterface {
  /// db instance
  Box<String>? _box;

  /// the name of the box
  String _name;

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
    // TODO: implement clear
    await _box!.clear();
  }

  @override
  Future delete(String key) async {
    // TODO: implement delete
    await _box!.delete(key);
  }

  @override
  Future<String> get(String key) async {
    // TODO: implement get
    return _box!.get(key)!;
  }

  @override
  // TODO: implement getAll
  Future<Map<String, String>> get getAll async {
    Map<String, String> returnedData = {};
    _box!.keys.forEach((element) {
      returnedData.addAll({element: _box!.get(element)!});
    });
    return returnedData;
  }

  @override
  // TODO: implement getNonDecodedAll
  Future<Map<String, String>> get getNonDecodedAll => getAll;

  @override
  Future insert(String json, String key) async {
    // TODO: implement insert
    await _box!.put(key, json);
  }

  @override
  Future update(String json, String key) async {
    // TODO: implement update
    await _box!.put(key, json);
  }

  @override
  Future write(String json, String key) async {
    // TODO: implement write
    await _box!.put(key, json);
  }
}
