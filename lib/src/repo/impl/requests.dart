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
  Future<Map<String, dynamic>> get getAll async {
    File f = await _getDbFile;
    Map<String, dynamic> data = jsonDecode(f.readAsStringSync());
    return data;
  }

  @override
  Future delete(String key) async {
    var db = await getAll;
    if (db.remove(key) != null) {
      var f = await _getDbFile;
      f.writeAsStringSync(jsonEncode(db));
    }
  }

  @override
  Future<Map<String, dynamic>> get(String key) async {
    var db = await getAll;
    return db[key];
  }

  @override
  Future insert(Map<String, dynamic> json, {String? key}) async {
    var db = await getAll;
    var f = await _getDbFile;
    if (key != null)
      db.addAll({key: json});
    else
      db.addAll({db.length.toString(): json});
    f.writeAsStringSync(jsonEncode(db));
  }

  @override
  Future update(Map<String, dynamic> json, {String? key}) async {
    var db = await getAll;
    if (key != null && db.containsKey(key)) {
      var f = await _getDbFile;
      db[key] = json;
      f.writeAsStringSync(jsonEncode(db));
    }
  }

  @override
  Future write(Map<String, dynamic> json, {String? key}) async {
    await insert(json, key: key);
  }
}
