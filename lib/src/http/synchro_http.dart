import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchro_http/src/enums/sync_status.dart';
import 'package:synchro_http/src/exceptions/no_cache.dart';
import 'package:synchro_http/src/http/models/request_model.dart';
import 'package:synchro_http/src/http/models/response_model.dart';
import 'package:synchro_http/src/repo/cache/impl/responses.dart';
import 'package:synchro_http/src/repo/cache/repo.dart';

class SynchroHttp {
  /// the singleton
  static final SynchroHttp singleton = SynchroHttp._internal();

  /// Base url
  static String? baseUrl;

  /// sync get requests
  static bool syncGetRequests = false;

  /// sync get requests
  static bool deleteOnSuccess = false;

  /// Default http headers
  static Map<String, String> headers = {"Content-Type": "application/json"};

  /// The waiting duration between each synchronized request call
  static Duration coolDownDuration = Duration.zero;

  /// Requests cache repo
  final RequestRepo _requestsRepo = RequestRepo(name: HttpType.REQUEST);

  /// Responses cache repo
  final ResponseRepo _responsesRepo = ResponseRepo(name: HttpType.RESPONSE);

  /// Get Requests cache repo
  RequestRepo get requestsRepo => _requestsRepo;

  /// Get Responses cache repo
  ResponseRepo get responsesRepo => _responsesRepo;

  /// Set of methods to be executed when synchronization is completed
  final Set<Function> _toBeSynced = {};

  /// private constructor
  SynchroHttp._internal() {
    Hive.registerAdapter(SynchroRequestAdapter());
    Hive.registerAdapter(SynchroResponseAdapter());
    _init().then((value) {
      // _sync().listen((event) => _controller.sink.add(event));
      if (kIsWeb) {
        _syncWeb().listen((event) => _controller.sink.add(event));
      } else {
        _sync().listen((event) => _controller.sink.add(event));
      }
    });
  }

  /// factory constructor
  factory SynchroHttp() => singleton;

  /// Sync controller
  final BehaviorSubject<SyncStatus> _controller = BehaviorSubject<SyncStatus>();

  /// Sync stream
  Stream<SyncStatus> get sync => _controller.stream;

  /// Future synchronize requests
  static Future async() async {
    Connectivity connection = Connectivity();
    RequestRepo requestsRepo = SynchroHttp().requestsRepo;
    ResponseRepo responsesRepo = SynchroHttp().responsesRepo;
    await requestsRepo.init();
    await responsesRepo.init();
    connection.onConnectivityChanged.listen((status) async {
      if (status != ConnectivityResult.none) {
        var requests = requestsRepo.getAll;
        requests?.forEach((request) async {
          var response = await request.sendIt();
          if (!SynchroHttp.deleteOnSuccess) {
            requestsRepo.update(request.hashCode, request);
          } else {
            requestsRepo.delete(request.hashCode);
          }
          responsesRepo.write(request.hashCode, response);
          await Future.delayed(coolDownDuration);
        });
      }
    });
  }

  /// Stream synchronize requests
  Stream<SyncStatus> _sync() async* {
    var connection = Connectivity();
    await for (ConnectivityResult status in connection.onConnectivityChanged) {
      if (status != ConnectivityResult.none) {
        try {
          var requests = requestsRepo.getAll;
          if (requests?.isNotEmpty ?? false) {
            yield SyncStatus.synchronizing;
            for (var request in requests!) {
              await Future.delayed(coolDownDuration);
              var response = await request.sendIt();
              requestsRepo.delete(request.hashCode);
              responsesRepo.write(request.hashCode, response);
            }
          }
        } on SocketException catch (_) {
          yield SyncStatus.error;
          await Future.delayed(const Duration(seconds: 3));
        } on ClientException catch (_) {
          yield SyncStatus.error;
          await Future.delayed(const Duration(seconds: 3));
        } catch (_) {
          yield SyncStatus.error;
          await Future.delayed(const Duration(seconds: 3));
          _requestsRepo.clear();
        }
        _toBeSynced.forEach((fn) {
          try {
            fn();
          } catch (_) {}
        });
        yield SyncStatus.online;
      } else {
        yield SyncStatus.offline;
      }
    }
  }

  /// Stream Synchronize requests for the web
  Stream<SyncStatus> _syncWeb() async* {
    var streamController = BehaviorSubject.seeded("boo");
    Timer.periodic(const Duration(seconds: 3), (timer) {
      streamController.add("boo");
    });
    await for (var _ in streamController.stream) {
      var requests = requestsRepo.getAll;
      if (requests?.isNotEmpty ?? false) {
        try {
          yield SyncStatus.synchronizing;
          for (var request in requests!) {
            await Future.delayed(coolDownDuration);
            var response = await request.sendIt();
            requestsRepo.delete(request.hashCode);
            responsesRepo.write(request.hashCode, response);
          }
          _toBeSynced.forEach((fn) => fn());
          yield SyncStatus.online;
        } catch (_) {
          yield SyncStatus.offline;
        }
      } else {
        yield SyncStatus.offline;
      }
    }
  }

  /// delete cached data
  void clearCache() {
    _responsesRepo.clear();
    _requestsRepo.clear();
  }

  /// cached get request
  Future<SynchroResponse> get({
    /// the url to the api
    Uri? url,

    /// the path to the api
    String? path,

    /// the request headers
    Map<String, String>? headers,

    /// whether to get the response from cache or not
    bool fromCache = false,
  }) async {
    return await call(
      method: HttpMethods.GET,
      headers: headers,
      path: path,
      url: url,
      fromCache: fromCache,
    );
  }

  /// cached post request
  Future<SynchroResponse> post({
    /// the url to the api
    Uri? url,

    /// the path to the api
    String? path,

    /// the request headers
    Map<String, String>? headers,

    /// the request body
    String body = "",

    /// whether to get the response from cache or not
    bool fromCache = false,
  }) async {
    return await call(
      method: HttpMethods.POST,
      headers: headers,
      path: path,
      url: url,
      body: body,
      fromCache: fromCache,
    );
  }

  /// cached put request
  Future<SynchroResponse> put({
    /// the url to the api
    Uri? url,

    /// the path to the api
    String? path,

    /// the request headers
    Map<String, String>? headers,

    /// the request body
    String body = "",

    /// whether to get the response from cache or not
    bool fromCache = false,
  }) async {
    return await call(
      method: HttpMethods.PUT,
      headers: headers,
      path: path,
      url: url,
      body: body,
      fromCache: fromCache,
    );
  }

  /// cached delete request
  Future<SynchroResponse> delete({
    /// the url to the api
    Uri? url,

    /// the path to the api
    String? path,

    /// the request headers
    Map<String, String>? headers,

    /// whether to get the response from cache or not
    bool fromCache = false,
  }) async {
    return await call(
      method: HttpMethods.DELETE,
      headers: headers,
      path: path,
      url: url,
      fromCache: fromCache,
    );
  }

  /// this method call is a general way to call any HTTP method
  Future<SynchroResponse> call({
    /// HTTTP method
    required String method,

    /// the url to the api
    Uri? url,

    /// the path to the api
    String? path,

    /// the request headers
    Map<String, String>? headers,

    /// the request body
    String body = "",

    /// whether to get the response from cache or not
    bool fromCache = false,
  }) async {
    assert((url != null && path == null) ||
        (url == null && baseUrl != null && path != null));
    await _init();
    url ??= Uri.parse("$baseUrl$path");
    SynchroRequest request = SynchroRequest(
      url.toString(),
      method,
      body: body,
      headers: headers ?? SynchroHttp.headers,
    );
    try {
      if (fromCache) {
        var response = _responsesRepo.get(request.hashCode);
        if (response == null) throw NotCachedException();
        return response;
      } else {
        _requestsRepo.write(request.hashCode, request);
        var response = await request.sendIt();
        response.requestHash = request.hashCode;
        _responsesRepo.write(request.hashCode, response);
        _requestsRepo.delete(request.hashCode);
        return response;
      }
    } on NotCachedException {
      _requestsRepo.write(request.hashCode, request);
      var response = await request.sendIt();
      response.requestHash = request.hashCode;
      _responsesRepo.write(request.hashCode, response);
      _requestsRepo.delete(request.hashCode);
      return response;
    } on SocketException {
      var response = _responsesRepo.get(request.hashCode);
      if (response != null) {
        response.cached = true;
        return response;
      }
      rethrow;
    } on ClientException {
      var response = _responsesRepo.get(request.hashCode);
      if (response != null) {
        response.cached = true;
        return response;
      }
      rethrow;
    }
  }

  /// init SynchroHttp
  Future<void> _init() async {
    if (!kIsWeb) {
      await Hive.initFlutter();
    }
    await _requestsRepo.init();
    await _responsesRepo.init();
  }

  /// add a function to be called when the synchronization is completed
  void addSyncMethod(Function function) {
    _toBeSynced.add(function);
  }

  /// remove function from synchronization functions callback
  void removeSyncedMethod(Function function) {
    _toBeSynced.remove(function);
  }

  /// add a new global header
  void addGlobalHeader(String header, String value) {
    headers.addAll({header: value});
  }

  /// remove a global header
  void removeGlobalHeader(String header) {
    headers.remove(header);
  }
}
