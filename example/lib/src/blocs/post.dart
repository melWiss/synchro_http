import 'package:synchro_http/synchro_http.dart';
import '../models/post.dart';
import '../services/post.dart';
import '../events/post.dart';

class PostBloc {
  /// the controller of PostBloc events
  final BehaviorSubject<PostEvent> _controller =
      BehaviorSubject<PostEvent>.seeded(PostEvent.loaded);

  /// the stream of Post events
  Stream<PostEvent> get stream => _controller.stream;

  /// the state variable of Post
  List<Post>? _state = [];

  /// the state getter of Post
  List<Post>? get state => _state;

  /// the current event of Post stream
  PostEvent get event => _controller.value;

  /// the singleton
  static final PostBloc instance = PostBloc._();

  /// private constructor
  PostBloc._() {
    fetchAll(false);
    SynchroHttp().addSyncMethod(fetchAll);
  }

  /// factory constructor, don't touch it
  factory PostBloc() {
    return instance;
  }

  /// fetches all Post
  Future<void> fetchAll([bool fromCache = true]) async {
    _controller.add(PostEvent.loading);
    _state = await PostService.all(fromCache: fromCache);
    _controller.add(PostEvent.loaded);
  }

  /// add post
  Future<void> add(Post post, [bool fromCache = false]) async {
    _controller.add(PostEvent.loading);
    await PostService.add(post,fromCache: fromCache);
    fetchAll(false);
  }
  /// update post
  Future<void> update(Post post, [bool fromCache = false]) async {
    _controller.add(PostEvent.loading);
    await PostService.update(post,fromCache: fromCache);
    fetchAll(false);
  }
  /// update delete
  Future<void> delete(Post post, [bool fromCache = false]) async {
    _controller.add(PostEvent.loading);
    await PostService.delete(post,fromCache: fromCache);
    fetchAll(false);
  }
}
