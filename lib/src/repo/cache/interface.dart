import 'package:hive/hive.dart';

abstract class RepoInterface<T> {
  /// db instance
  Box<T>? _box;

  /// the name of the box
  final String _name;

  RepoInterface({
    required String name,
  }) : _name = name;

  /// a getter for the box instance
  Box<T>? get box => _box;

  /// get cached [T] data by key
  T? get(int key);

  /// get all cached [T] data
  Iterable<T>? get getAll;

  /// initializes the repo
  Future<void> init() async {
    _box ??= await Hive.openBox<T>(_name);
  }

  /// insert new [T] data
  void insert(int key, T data);

  /// update an existent [T] data
  void update(int key, T data);

  /// a mix of insert and update
  void write(int key, T data);

  /// delete a cached [T] data by key
  void delete(int key);

  /// clear cached data
  void clear();
}

class HttpMethods {
  static const String GET = "GET";
  static const String HEAD = "HEAD";
  static const String POST = "POST";
  static const String PUT = "PUT";
  static const String DELETE = "DELETE";
  static const String CONNECT = "CONNECT";
  static const String OPTIONS = "OPTIONS";
  static const String TRACE = "TRACE";
  static const String PATCH = "PATCH";
}
