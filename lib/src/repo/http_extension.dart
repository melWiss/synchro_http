import 'dart:convert';

import 'package:http/http.dart';

extension ResponseMethods on Response {
  static Response fromMap(Map json) {
      return Response(
        jsonEncode(json['body']),
        json['status'],
        headers: Map<String, String>.from(json['headers']),
        request: Request(json['method'], Uri.parse(json['url'])),
      );
  }

  static Response fromJson(String json) {
    return fromMap(jsonDecode(json));
  }

  Map<String, dynamic> toMap() {
    return {
      "url": request!.url.toString(),
      "status": statusCode,
      "method": request!.method,
      "headers": headers,
      "body": jsonDecode(body),
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}

extension RequestMethods on Request {
  static Request fromMap(Map json) {
    var request = Request(
      json['method'],
      Uri.parse(json['url']),
    );
    request.headers.addAll(Map<String, String>.from(json['headers']));
    request.body = json['body'] ?? "";
    return request;
  }

  static Request fromJson(String json) {
    return fromMap(jsonDecode(json));
  }

  Map<String, dynamic> toMap() {
    return {
      "url": url.toString(),
      "status": null,
      "method": method,
      "headers": headers,
      "body": jsonDecode(body),
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
class HttpType {
  static const String REQUEST = "REQUEST";
  static const String RESPONSE = "RESPONSE";
}