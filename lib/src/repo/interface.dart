abstract class RepoInterface {
  /// get cached json data by key
  Future<Map<String, dynamic>> get(String key);

  /// get all cached json data
  Future<Map<String, dynamic>> get getAll;
  // Future<Map<String, dynamic>> get(
  //   String key, {
  //   Function(Map<String, dynamic> m1, Map<String, dynamic> m2)? where,
  // });

  /// insert new json data
  Future insert(Map<String, dynamic> json, {String? key});

  /// update an existent json data
  Future update(Map<String, dynamic> json, {String? key});

  /// a mix of insert and update
  Future write(Map<String, dynamic> json, {String? key});

  /// delete a cached json data by key
  Future delete(String key);
}

class HttpMethods {
  static const String GET = "GET";
  static const String POST = "POST";
  static const String PUT = "PUT";
  static const String DELETE = "DELETE";
}
