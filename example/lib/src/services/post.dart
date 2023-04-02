import 'dart:convert';
import '../models/post.dart';
import 'package:synchro_http/synchro_http.dart';

class PostService {
  static final SynchroHttp _http = SynchroHttp();

  /// fetch all Post
  static Future<List<Post>> all({bool fromCache = true}) async {
    var response = await _http.get(path: "/posts", fromCache: fromCache);
    var decodedResponse =
        List<Map<String, dynamic>>.from(jsonDecode(response.body));
    var posts = decodedResponse.map((e) => Post.fromMap(e)).toList();
    return posts;
  }

  /// fetch Post by id
  static Future<Post> get(String id, {bool fromCache = true}) async {
    var response = await _http.get(path: "/posts/$id", fromCache: fromCache);
    var decodedResponse = Map<String, dynamic>.from(jsonDecode(response.body));
    var post = Post.fromMap(decodedResponse);
    return post;
  }

  /// add Post
  static Future<Post> add(Post post, {bool fromCache = true}) async {
    var response = await _http.post(
        path: "/posts", body: post.toJson(), fromCache: fromCache);
    var decodedResponse = Map<String, dynamic>.from(jsonDecode(response.body));
    post = Post.fromMap(decodedResponse);
    return post;
  }

  /// update Post
  static Future<Post> update(Post post, {bool fromCache = true}) async {
    var response = await _http.put(
        path: "/posts/${post.id}", body: post.toJson(), fromCache: fromCache);
    var decodedResponse = Map<String, dynamic>.from(jsonDecode(response.body));
    post = Post.fromMap(decodedResponse);
    return post;
  }

  /// delete Post
  static Future<Post> delete(Post post, {bool fromCache = true}) async {
    var response =
        await _http.delete(path: "/posts/${post.id}", fromCache: fromCache);
    var decodedResponse = Map<String, dynamic>.from(jsonDecode(response.body));
    post = Post.fromMap(decodedResponse);
    return post;
  }
}
