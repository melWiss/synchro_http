import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:synchro_http/src/enums/sync_status.dart';
import 'package:synchro_http/src/exceptions/no_cache.dart';
import 'package:synchro_http/src/exceptions/no_internet.dart';
import 'package:synchro_http/src/exceptions/status_code.dart';
import 'package:synchro_http/src/repo/cache/repo.dart';
import 'package:synchro_http/src/repo/cache/impl/requests.dart';

import 'package:http/http.dart' as http;

class SynchroHttp {
  /// the singleton
  static final SynchroHttp _singleton = SynchroHttp._internal();

  /// Default lookup address
  static String? lookup;

  /// Base url
  static String? baseUrl;

  /// sync get requests
  static bool syncGetRequests = false;

  /// Default http headers
  static Map<String, String> headers = {"Content-Type": "application/json"};

  /// Requests cache repo
  final RepoInterface _requestsRepo = RequestsRepo(name: HttpType.REQUEST);

  /// Responses cache repo
  final RepoInterface _responsesRepo = JsonRepo(name: HttpType.RESPONSE);

  /// Get Requests cache repo
  RepoInterface get requestsRepo => _requestsRepo;

  /// Get Responses cache repo
  RepoInterface get responsesRepo => _responsesRepo;

  /// private constructor
  SynchroHttp._internal();

  /// factory constructor
  factory SynchroHttp() => _singleton;

  /// Future synchronize requests
  static Future async() async {
    SimpleConnectionChecker connection = SimpleConnectionChecker();
    RepoInterface requestsRepo = RequestsRepo(name: HttpType.REQUEST);
    RepoInterface responsesRepo = JsonRepo(name: HttpType.RESPONSE);
    http.Client client = http.Client();
    connection.onConnectionChange.listen((event) async {
      if (event) {
        var requests = await requestsRepo.getAll;
        requests.forEach((url, request) async {
          if (request["status"] == null ||
              (request['status'] >= 300 || request['status'] < 200)) {
            http.Request req = RequestMethods.fromJson(request);
            var response = await client.send(req);
            request['status'] = response.statusCode;
            await requestsRepo.update(request, key: url);
            if (request['method'] == HttpMethods.GET &&
                SynchroHttp.syncGetRequests) {
              await responsesRepo.write(
                (await http.Response.fromStream(response)).toJson(),
              );
            }
          }
        });
      }
    });
  }

  /// Stream synchronize requests
  static Stream<SyncStatus> sync({bool deleteOnSuccess = false}) async* {
    SimpleConnectionChecker connection = SimpleConnectionChecker();
    connection.setLookUpAddress(lookup);
    RepoInterface requestsRepo = RequestsRepo(name: HttpType.REQUEST);
    RepoInterface responsesRepo = JsonRepo(name: HttpType.RESPONSE);
    http.Client client = http.Client();
    await for (bool status in connection.onConnectionChange) {
      if (status) {
        var requests = await requestsRepo.getAll;
        if (requests.isNotEmpty) {
          yield SyncStatus.synchronizing;
          requests.forEach((url, request) async {
            if (request["status"] == null ||
                (request['status'] >= 300 || request['status'] < 200)) {
              http.Request req = RequestMethods.fromJson(request);
              var response = await client.send(req);
              request['status'] = response.statusCode;
              if (!deleteOnSuccess) {
                await requestsRepo.update(request, key: url);
              } else {
                await requestsRepo.delete(url);
              }
              if (request['method'] == HttpMethods.GET &&
                  SynchroHttp.syncGetRequests) {
                await responsesRepo.write(
                  (await http.Response.fromStream(response)).toJson(),
                );
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

  /// delete cached data
  static Future clearCache() async {
    RepoInterface requests = RequestsRepo(name: HttpType.REQUEST);
    RepoInterface responses = JsonRepo(name: HttpType.RESPONSE);
    await responses.clear();
    await requests.clear();
  }

  /// cached get request
  Future<http.Response> get({
    /// the url to the api
    Uri? url,

    /// the path to the api
    String? path,

    /// the request headers
    Map<String, String>? headers,
  }) async {
    assert((url != null && path == null) ||
        (url == null && baseUrl != null && path != null));

    url ??= Uri.parse("$baseUrl$path");

    try {
      var response =
          await http.get(url, headers: headers ?? SynchroHttp.headers);
      await _responsesRepo.write(response.toJson());

      if (response.statusCode >= 300 || response.statusCode < 200) {
        throw StatusException(statusCode: response.statusCode, data: response);
      }
      return response;
    } on SocketException catch (e) {
      if (SynchroHttp.syncGetRequests) {
        await _requestsRepo.write({
          "url": url.toString(),
          "status": null,
          "method": HttpMethods.GET,
          "headers": headers ?? SynchroHttp.headers,
          "type": HttpType.REQUEST,
        });
      }
      var cached = await _responsesRepo.get(url.toString());
      http.Response cachedResponse = ResponseMethods.fromJson(cached);
      throw NoInternetException<http.Response>(
        data: cachedResponse,
      );
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
    Map<String, dynamic>? body,
  }) async {
    assert((url != null && path == null) ||
        (url == null && baseUrl != null && path != null));

    url ??= Uri.parse("$baseUrl$path");
    try {
      var response = await http.post(
        url,
        headers: headers ?? SynchroHttp.headers,
        body: body != null ? jsonEncode(body) : null,
      );
      if (response.statusCode >= 300 || response.statusCode < 200) {
        throw StatusException(statusCode: response.statusCode, data: response);
      }
      return response;
    } on SocketException catch (e) {
      await _requestsRepo.write({
        "url": url.toString(),
        "status": null,
        "method": HttpMethods.POST,
        "headers": headers ?? SynchroHttp.headers,
        "body": body ?? {},
        "type": HttpType.REQUEST,
      });
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
    Map<String, dynamic>? body,
  }) async {
    assert((url != null && path == null) ||
        (url == null && baseUrl != null && path != null));

    url ??= Uri.parse("$baseUrl$path");
    try {
      var response = await http.put(
        url,
        headers: headers ?? SynchroHttp.headers,
        body: body != null ? jsonEncode(body) : null,
      );
      if (response.statusCode >= 300 || response.statusCode < 200) {
        throw StatusException(statusCode: response.statusCode, data: response);
      }
      return response;
    } on SocketException catch (e) {
      await _requestsRepo.write({
        "url": url.toString(),
        "status": null,
        "method": HttpMethods.PUT,
        "headers": headers ?? SynchroHttp.headers,
        "body": body ?? {},
        "type": HttpType.REQUEST,
      });
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
    Map<String, dynamic>? body,
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
      await _requestsRepo.write({
        "url": url.toString(),
        "status": null,
        "method": HttpMethods.DELETE,
        "headers": headers ?? SynchroHttp.headers,
        "body": body ?? {},
        "type": HttpType.REQUEST,
      });
      throw NoInternetException();
    }
  }
}
