import 'package:synchro_http/src/http/models/response_model.dart';
import 'package:synchro_http/src/repo/cache/repo.dart';

class ResponseRepo extends RepoInterface<SynchroResponse> {
  ResponseRepo({super.name = HttpType.RESPONSE});
  
  @override
  void clear() {
    box.clear();
  }
  
  @override
  void delete(int key) {
    box.delete(key);
  }
  
  @override
  SynchroResponse? get(int key) {
    return box.get(key);
  }
  
  @override
  Iterable<SynchroResponse> get getAll => box.values;
  
  @override
  void insert(int key, SynchroResponse data) {
    box.put(key, data);
  }
  
  @override
  void update(int key, SynchroResponse data) {
    box.put(key, data);
  }
  
  @override
  void write(int key, SynchroResponse data) {
    box.put(key, data);
  }

  
}
