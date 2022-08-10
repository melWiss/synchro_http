import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../interface.dart';

class RequestsRepo implements RepoInterface {
  final String _name;

  RequestsRepo({
    /// the name of the repo
    required String name,
  }) : _name = name;

  Future<File> get _getDbFile async {
    Directory dirDB = await getApplicationSupportDirectory();
    File f = File(join(dirDB.path, "$_name.json"));
    if (!f.existsSync()) {
      f.writeAsStringSync(jsonEncode({}));
    }
    return f;
  }

  @override
  Future<Map<String, String>> get getAll async {
    File f = await _getDbFile;
    Map<String, String> data =
        Map.from(jsonDecode(utf8.decode(f.readAsBytesSync())));
    return data;
  }

  @override
  Future delete(String key) async {
    var db = await getAll;
    if (db.remove(key) != null) {
      var f = await _getDbFile;
      f.writeAsBytesSync(utf8.encode(jsonEncode(db)));
    }
  }

  @override
  Future<String> get(String key) async {
    var db = await getAll;
    return db[key]!;
  }

  @override
  Future insert(String json, String key) async {
    var db = await getAll;
    var f = await _getDbFile;
    if (key != null)
      db.addAll({key: json});
    else
      db.addAll({db.length.toString(): json});
    f.writeAsBytesSync(utf8.encode(jsonEncode(db)));
  }

  @override
  Future update(String json, String key) async {
    var db = await getAll;
    if (key != null && db.containsKey(key)) {
      var f = await _getDbFile;
      db[key] = json;
      f.writeAsBytesSync(utf8.encode(jsonEncode(db)));
    }
  }

  @override
  Future write(String json, String key) async {
    await insert(json, key);
  }

  @override
  Future clear() async {
    Directory dirDB = await getApplicationSupportDirectory();
    File f = File(join(dirDB.path, "$_name.json"));
    if (f.existsSync()) {
      f.deleteSync();
    }
  }
}
