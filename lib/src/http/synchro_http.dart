import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:synchro_http/src/enums/sync_status.dart';
import 'package:synchro_http/src/exceptions/no_internet.dart';
import 'package:synchro_http/src/http/models/request_model.dart';
import 'package:synchro_http/src/http/models/response_model.dart';
import 'package:synchro_http/src/repo/cache/impl/responses.dart';
import 'package:synchro_http/src/repo/cache/repo.dart';
import 'package:rxdart/rxdart.dart';

import 'package:http/http.dart' as http;

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
    if (kIsWeb) {
      _syncWeb().listen((event) => _controller.sink.add(event));
    } else {
      _sync().listen((event) => _controller.sink.add(event));
    }
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
    connection.onConnectivityChanged.listen((status) async {
      if (status != ConnectivityResult.none) {
        var requests = requestsRepo.getAll;
        requests.forEach((request) async {
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
    await _initHiveRepo();
    var connection = Connectivity();
    await for (ConnectivityResult status in connection.onConnectivityChanged) {
      if (status != ConnectivityResult.none) {
        var requests = requestsRepo.getAll;
        if (requests.isNotEmpty) {
          yield SyncStatus.synchronizing;
          requests.forEach((request) async {
            var response = await request.sendIt();
            if (!SynchroHttp.deleteOnSuccess) {
              requestsRepo.update(request.hashCode, request);
            } else {
              requestsRepo.delete(request.hashCode);
            }
            responsesRepo.write(request.hashCode, response);
          });
        }
        _toBeSynced.forEach((fn) => fn());
        yield SyncStatus.online;
      } else {
        yield SyncStatus.offline;
      }
    }
  }

  /// Stream Synchronize requests for the web
  Stream<SyncStatus> _syncWeb() async* {
    await _initHiveRepo();
    var streamController = BehaviorSubject.seeded("boo");
    Timer.periodic(const Duration(seconds: 3), (timer) {
      streamController.add("boo");
    });
    await for (var _ in streamController.stream) {
      var requests = requestsRepo.getAll;
      if (requests.isNotEmpty) {
        yield SyncStatus.synchronizing;
        requests.forEach((request) async {
          var response = await request.sendIt();
          if (!SynchroHttp.deleteOnSuccess) {
            requestsRepo.update(request.hashCode, request);
          } else {
            requestsRepo.delete(request.hashCode);
          }
          responsesRepo.write(request.hashCode, response);
        });
        _toBeSynced.forEach((fn) => fn());
        yield SyncStatus.online;
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

    /// from cache
    bool fromCache = false,
  }) async {
    assert((url != null && path == null) ||
        (url == null && baseUrl != null && path != null));

    url ??= Uri.parse("$baseUrl$path");
    SynchroRequest request = SynchroRequest(
      url.toString(),
      HttpMethods.GET,
      headers: headers ?? SynchroHttp.headers,
    );
    SynchroResponse response;
    if (fromCache) {
      response = _responsesRepo.get(request.hashCode);
      response.cached = true;
    } else {
      try {
        response = await request.sendIt();
        _responsesRepo.write(request.hashCode, response);
        return response;
      } on SocketException catch (_) {
        if (SynchroHttp.syncGetRequests) {
          _requestsRepo.write(request.hashCode, request);
        }
        response = _responsesRepo.get(request.hashCode);
        response.cached = true;
      }
    }
    return response;
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
    String? body,
  }) async {
    assert((url != null && path == null) ||
        (url == null && baseUrl != null && path != null));

    url ??= Uri.parse("$baseUrl$path");
    try {
      var response = await http.post(
        url,
        headers: headers ?? SynchroHttp.headers,
        body: body,
      );
      return SynchroResponse.fromResponse(response);
    } on SocketException catch (_) {
      SynchroRequest synchroRequest = SynchroRequest(
        url.toString(),
        HttpMethods.POST,
        body: body ?? "",
        headers: headers ?? SynchroHttp.headers,
      );
      _requestsRepo.write(synchroRequest.hashCode, synchroRequest);
      throw NoInternetException();
    }
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
    String? body,
  }) async {
    assert((url != null && path == null) ||
        (url == null && baseUrl != null && path != null));

    url ??= Uri.parse("$baseUrl$path");
    try {
      var response = await http.put(
        url,
        headers: headers ?? SynchroHttp.headers,
        body: body,
      );
      return SynchroResponse.fromResponse(response);
    } on SocketException catch (_) {
      SynchroRequest synchroRequest = SynchroRequest(
        url.toString(),
        HttpMethods.PUT,
        body: body ?? "",
        headers: headers ?? SynchroHttp.headers,
      );
      _requestsRepo.write(synchroRequest.hashCode, synchroRequest);
      throw NoInternetException();
    }
  }

  /// cached delete request
  Future<SynchroResponse> delete({
    /// the url to the api
    Uri? url,

    /// the path to the api
    String? path,

    /// the request headers
    Map<String, String>? headers,

    /// the request body
    String? body,
  }) async {
    assert((url != null && path == null) ||
        (url == null && baseUrl != null && path != null));

    url ??= Uri.parse("$baseUrl$path");
    try {
      var response = await http.delete(
        url,
        headers: headers ?? SynchroHttp.headers,
        body: body,
      );

      return SynchroResponse.fromResponse(response);
    } on SocketException catch (_) {
      SynchroRequest synchroRequest = SynchroRequest(
        url.toString(),
        HttpMethods.DELETE,
        body: body ?? "",
        headers: headers ?? SynchroHttp.headers,
      );
      _requestsRepo.write(synchroRequest.hashCode, synchroRequest);
      throw NoInternetException();
    }
  }

  /// init HiveRepo
  Future<void> _initHiveRepo() async {
    if (!kIsWeb) {
      await Hive.initFlutter();
    }
    _requestsRepo.init();
    _responsesRepo.init();
  }

  /// add a function to be called when the synchronization is completed
  void addSyncMethod(Function function) {
    _toBeSynced.add(function);
  }

  /// remove function from synchronization functions callback
  void removeSyncedMethod(Function function) {
    _toBeSynced.remove(function);
  }
}
