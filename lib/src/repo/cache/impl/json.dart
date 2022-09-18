import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../interface.dart';

class JsonRepo implements RepoInterface {
  final String _name;

  JsonRepo({
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
    Map<String, String> data = Map.from(jsonDecode(f.readAsStringSync()));
    Map<String, String> decodedData = data.map((key, value) =>
        MapEntry(key, String.fromCharCodes(base64Decode(value))));
    return decodedData;
  }

  @override
  Future delete(String key) async {
    var db = await getNonDecodedAll;
    if (db.remove(key) != null) {
      var f = await _getDbFile;
      f.writeAsStringSync(jsonEncode(db));
    }
  }

  @override
  Future<String> get(String key) async {
    var db = await getNonDecodedAll;
    return String.fromCharCodes(base64Decode(db[key]!));
  }

  @override
  Future insert(String json, String key) async {
    var db = await getNonDecodedAll;
    var f = await _getDbFile;
    db.addAll({key: base64Encode(json.codeUnits)});
    f.writeAsStringSync(jsonEncode(db));
  }

  @override
  Future update(String json, String key) async {
    var db = await getNonDecodedAll;
    var f = await _getDbFile;
    db[key] = base64Encode(json.codeUnits);
    f.writeAsStringSync(jsonEncode(db));
  }

  @override
  Future write(String json, String key) async {
    var db = await getNonDecodedAll;
    var f = await _getDbFile;
    db.addAll({key: base64Encode(json.codeUnits)});
    f.writeAsStringSync(jsonEncode(db));
  }

  @override
  Future clear() async {
    Directory dirDB = await getApplicationSupportDirectory();
    File f = File(join(dirDB.path, "$_name.json"));
    if (f.existsSync()) {
      f.deleteSync();
    }
  }

  @override
  // TODO: implement getNonDecodedAll
  Future<Map<String, String>> get getNonDecodedAll async {
    File f = await _getDbFile;
    Map<String, String> data = Map.from(jsonDecode(f.readAsStringSync()));
    return data;
  }
}
