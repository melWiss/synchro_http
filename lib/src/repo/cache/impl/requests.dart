import 'package:synchro_http/src/http/models/request_model.dart';
import 'package:synchro_http/src/repo/cache/repo.dart';

class RequestRepo extends RepoInterface<SynchroRequest> {
  RequestRepo({super.name = HttpType.REQUEST});
  
  @override
  void clear() {
    box?.clear();
  }
  
  @override
  void delete(int key) {
    box?.delete(key);
  }
  
  @override
  SynchroRequest? get(int key) {
    return box?.get(key);
  }
  
  @override
  Iterable<SynchroRequest>? get getAll => box?.values;
  
  @override
  void insert(int key, SynchroRequest data) {
    box?.put(key, data);
  }
  
  @override
  void update(int key, SynchroRequest data) {
    box?.put(key, data);
  }
  
  @override
  void write(int key, SynchroRequest data) {
    box?.put(key, data);
  }

  
}
