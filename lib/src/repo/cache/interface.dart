abstract class RepoInterface {
  /// get cached json data by key
  Future<String> get(String key);

  /// get all cached json data
  Future<Map<String, String>> get getAll;

  Future<Map<String, String>> get getNonDecodedAll;
  // Future<Map<String, dynamic>> get(
  //   String key, {
  //   Function(Map<String, dynamic> m1, Map<String, dynamic> m2)? where,
  // });

  /// initializes the repo
  Future init();

  /// insert new json data
  Future insert(String json, String key);

  /// update an existent json data
  Future update(String json, String key);

  /// a mix of insert and update
  Future write(String json, String key);

  /// delete a cached json data by key
  Future delete(String key);

  /// clear cached data
  Future clear();
}

class HttpMethods {
  static const String GET = "GET";
  static const String POST = "POST";
  static const String PUT = "PUT";
  static const String DELETE = "DELETE";
}
