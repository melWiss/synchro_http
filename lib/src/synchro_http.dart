import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:synchro_http/src/enums/sync_status.dart';
import 'package:synchro_http/src/exceptions/no_internet.dart';
import 'package:synchro_http/src/exceptions/status_code.dart';
import 'package:synchro_http/src/repo/cache/impl/hive.dart';
import 'package:synchro_http/src/repo/cache/repo.dart';
import 'package:rxdart/rxdart.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:http/http.dart' as http;

class SynchroHttp {
  /// the singleton
  static final SynchroHttp singleton = SynchroHttp._internal();

  /// Default lookup address
  @deprecated
  static String? lookup;

  /// Base url
  static String? baseUrl;

  /// sync get requests
  static bool syncGetRequests = false;

  /// sync get requests
  static bool deleteOnSuccess = false;

  /// Default http headers
  static Map<String, String> headers = {"Content-Type": "application/json"};

  /// Requests cache repo
  RepoInterface _requestsRepo = RequestsRepo(name: HttpType.REQUEST);

  /// Responses cache repo
  RepoInterface _responsesRepo = JsonRepo(name: HttpType.RESPONSE);

  /// Get Requests cache repo
  RepoInterface get requestsRepo => _requestsRepo;

  /// Get Responses cache repo
  RepoInterface get responsesRepo => _responsesRepo;

  /// private constructor
  SynchroHttp._internal() {
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
    RepoInterface requestsRepo = SynchroHttp()._requestsRepo;
    RepoInterface responsesRepo = SynchroHttp()._responsesRepo;
    http.Client client = http.Client();
    connection.onConnectivityChanged.listen((status) async {
      if (status != ConnectivityResult.none) {
        var requests = await requestsRepo.getAll;
        requests.forEach((url, request) async {
          Map<String, dynamic> map = jsonDecode(request);
          if (map["status"] == null ||
              (map['status'] >= 300 || map['status'] < 200)) {
            http.Request req = RequestMethods.fromJson(request);
            var response = await client.send(req);
            map['status'] = response.statusCode;
            if (!SynchroHttp.deleteOnSuccess) {
              await requestsRepo.update(jsonEncode(map), url);
            } else {
              await requestsRepo.delete(url);
            }
            if (map['method'] == HttpMethods.GET &&
                SynchroHttp.syncGetRequests) {
              await responsesRepo.write(
                  jsonEncode(
                      (await http.Response.fromStream(response)).toJson()),
                  url);
            }
          }
        });
      }
    });
  }

  /// Stream synchronize requests
  Stream<SyncStatus> _sync() async* {
    RepoInterface requestsRepo = _requestsRepo;
    RepoInterface responsesRepo = _responsesRepo;
    if (responsesRepo is HiveRepo || requestsRepo is HiveRepo) {
      await _initHiveRepo();
    }
    http.Client client = http.Client();
    var connection = Connectivity();
    await for (ConnectivityResult status in connection.onConnectivityChanged) {
      if (status != ConnectivityResult.none) {
        var requests = await requestsRepo.getAll;
        if (requests.isNotEmpty) {
          yield SyncStatus.synchronizing;
          requests.forEach((url, request) async {
            Map<String, dynamic> map = jsonDecode(request);
            if (map["status"] == null ||
                (map['status'] >= 300 || map['status'] < 200)) {
              http.Request req = RequestMethods.fromJson(request);
              var response = await client.send(req);
              map['status'] = response.statusCode;
              if (!SynchroHttp.deleteOnSuccess) {
                await requestsRepo.update(jsonEncode(map), url);
              } else {
                await requestsRepo.delete(url);
              }
              if (map['method'] == HttpMethods.GET &&
                  SynchroHttp.syncGetRequests) {
                await responsesRepo.write(
                    jsonEncode(
                        (await http.Response.fromStream(response)).toJson()),
                    url);
              }
            }
          });
        }
        yield SyncStatus.online;
      } else {
        yield SyncStatus.offline;
      }
    }
  }

  /// Stream Synchronize requests for the web
  Stream<SyncStatus> _syncWeb() async* {
    await useHiveRepo();
    await _initHiveRepo();
    RepoInterface requestsRepo = _requestsRepo;
    RepoInterface responsesRepo = _responsesRepo;
    http.Client client = http.Client();
    var connection = Connectivity();
    var streamController = BehaviorSubject.seeded("boo");
    Timer.periodic(Duration(seconds: 3), (timer) {
      streamController.add("boo");
    });
    await for (var ev in streamController.stream) {
      // var status = await connection.checkConnectivity();
      // if (status != ConnectivityResult.none) {
      var requests = await requestsRepo.getAll;
      if (requests.isNotEmpty) {
        yield SyncStatus.synchronizing;
        requests.forEach((url, request) async {
          Map<String, dynamic> map = jsonDecode(request);
          if (map["status"] == null ||
              (map['status'] >= 300 || map['status'] < 200)) {
            http.Request req = RequestMethods.fromJson(request);
            var response = await client.send(req);
            map['status'] = response.statusCode;
            if (!SynchroHttp.deleteOnSuccess) {
              await requestsRepo.update(jsonEncode(map), url);
            } else {
              await requestsRepo.delete(url);
            }
            if (map['method'] == HttpMethods.GET &&
                SynchroHttp.syncGetRequests) {
              await responsesRepo.write(
                  jsonEncode(
                      (await http.Response.fromStream(response)).toJson()),
                  url);
            }
          }
        });
      }
      yield SyncStatus.online;
      // } else {
      // yield SyncStatus.offline;
      // }
    }
  }

  /// delete cached data
  Future clearCache() async {
    await _responsesRepo.clear();
    await _requestsRepo.clear();
  }

  /// cached get request
  Future<http.Response> get({
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

    if (fromCache) {
      var cached = await _responsesRepo.get(url.toString());
      http.Response cachedResponse = ResponseMethods.fromJson(cached);
      return cachedResponse;
    } else {
      try {
        var response =
            await http.get(url, headers: headers ?? SynchroHttp.headers);
        await _responsesRepo.write(response.toJson(), url.toString());

        if (response.statusCode >= 300 || response.statusCode < 200) {
          throw StatusException(
              statusCode: response.statusCode, data: response);
        }
        return response;
      } on SocketException catch (e) {
        if (SynchroHttp.syncGetRequests) {
          await _requestsRepo.write(
            jsonEncode({
              "url": url.toString(),
              "status": null,
              "method": HttpMethods.GET,
              "headers": headers ?? SynchroHttp.headers,
              "type": HttpType.REQUEST,
            }),
            url.toString(),
          );
        }
        var cached = await _responsesRepo.get(url.toString());
        http.Response cachedResponse = ResponseMethods.fromJson(cached);
        throw NoInternetException<http.Response>(
          data: cachedResponse,
        );
      }
    }
  }

  /// cached post request
  Future<http.Response> post({
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
      if (response.statusCode >= 300 || response.statusCode < 200) {
        throw StatusException(statusCode: response.statusCode, data: response);
      }
      return response;
    } on SocketException catch (e) {
      await _requestsRepo.write(
        jsonEncode({
          "url": url.toString(),
          "status": null,
          "method": HttpMethods.POST,
          "headers": headers ?? SynchroHttp.headers,
          "body": body,
          "type": HttpType.REQUEST,
        }),
        url.toString(),
      );
      throw NoInternetException();
    }
  }

  /// cached put request
  Future<http.Response> put({
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
      if (response.statusCode >= 300 || response.statusCode < 200) {
        throw StatusException(statusCode: response.statusCode, data: response);
      }
      return response;
    } on SocketException catch (e) {
      await _requestsRepo.write(
        jsonEncode({
          "url": url.toString(),
          "status": null,
          "method": HttpMethods.PUT,
          "headers": headers ?? SynchroHttp.headers,
          "body": body,
          "type": HttpType.REQUEST,
        }),
        url.toString(),
      );
      throw NoInternetException();
    }
  }

  /// cached delete request
  Future<http.Response> delete({
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
      if (response.statusCode >= 300 || response.statusCode < 200) {
        throw StatusException(statusCode: response.statusCode, data: response);
      }
      return response;
    } on SocketException catch (e) {
      await _requestsRepo.write(
        jsonEncode({
          "url": url.toString(),
          "status": null,
          "method": HttpMethods.DELETE,
          "headers": headers ?? SynchroHttp.headers,
          "body": body,
          "type": HttpType.REQUEST,
        }),
        url.toString(),
      );
      throw NoInternetException();
    }
  }

  /// use JsonRepo
  Future<void> useJsonRepo() async {
    _requestsRepo = RequestsRepo(name: HttpType.REQUEST);
    _responsesRepo = JsonRepo(name: HttpType.RESPONSE);
  }

  /// use HiveRepo
  Future<void> useHiveRepo() async {
    _requestsRepo = HiveRepo(name: HttpType.REQUEST);
    _responsesRepo = HiveRepo(name: HttpType.RESPONSE);
  }

  /// init HiveRepo
  Future<void> _initHiveRepo() async {
    if (!kIsWeb) {
      await Hive.initFlutter();
    }
    await _requestsRepo.init();
    await _responsesRepo.init();
  }
}
