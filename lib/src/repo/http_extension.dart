import 'dart:convert';

import 'package:http/http.dart';

extension ResponseMethods on Response {
  static Response fromJson(Map json) {
    if (json['type'] == HttpType.RESPONSE) {
      return Response(
        jsonEncode(json['body']),
        json['status'],
        headers: Map<String, String>.from(json['headers']),
        request: Request(json['method'], Uri.parse(json['url'])),
      );
    }
    throw HttpTypeException.NOT_COMPATIBLE_HTTP_TYPE;
  }

  Map<String, dynamic> toJson() {
    return {
      "url": request!.url.toString(),
      "status": statusCode,
      "method": request!.method,
      "headers": headers,
      "body": jsonDecode(body),
      "type": HttpType.RESPONSE,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

extension RequestMethods on Request {
  static Request fromJson(Map json) {
    if (json['type'] == HttpType.REQUEST) {
      var request = Request(
        json['method'],
        Uri.parse(json['url']),
      );
      request.headers.addAll(Map<String, String>.from(json['headers']));
      request.body = jsonEncode(json['body']);
      return request;
    }
    throw HttpTypeException.NOT_COMPATIBLE_HTTP_TYPE;
  }

  Map<String, dynamic> toJson() {
    return {
      "url": url.toString(),
      "status": null,
      "method": method,
      "headers": headers,
      "body": jsonDecode(body),
      "type": HttpType.REQUEST,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

class HttpType {
  static const String REQUEST = "REQUEST";
  static const String RESPONSE = "RESPONSE";
}

class HttpTypeException {
  static const String NOT_COMPATIBLE_HTTP_TYPE = "NOT_COMPATIBLE_HTTP_TYPE";
}
