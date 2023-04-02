import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:synchro_http/src/http/models/response_model.dart';

part 'request_model.g.dart';

@HiveType(typeId: 0)
class SynchroRequest extends Request {
  SynchroRequest(
    this.urlStr,
    this.method, {
    this.body = "",
    this.persistentConnection = true,
    this.headers = const {},
  }) : super(method, Uri.parse(urlStr));

  @HiveField(0)
  final String urlStr;

  @override
  @HiveField(1)
  final String method;

  @override
  @HiveField(2)
  final String body;

  @override
  @HiveField(3)
  final bool persistentConnection;

  @override
  @HiveField(4)
  Map<String, String> headers = {};

  factory SynchroRequest.fromRequest(Request request) {
    return SynchroRequest(
      request.url.toString(),
      request.method,
      body: request.body,
      headers: request.headers,
      persistentConnection: request.persistentConnection,
    );
  }

  factory SynchroRequest.fromMap(Map<String, dynamic> map) {
    return SynchroRequest(
      map['url'],
      map['method'],
      body: map['body'],
      headers: map['headers'],
      persistentConnection: map['persistentConnection'],
    );
  }

  factory SynchroRequest.fromJson(String json) =>
      SynchroRequest.fromMap(jsonDecode(json));

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'method': method,
      'url': url,
      'body': body,
      'headers': headers,
      'persistentConnection': persistentConnection,
    };
  }

  String toJson() => jsonEncode(toMap());

  @override
  int get hashCode =>
      method.hashCode ^
      url.toString().hashCode ^
      body.hashCode ^
      jsonEncode(headers).hashCode;

  @override
  bool operator ==(Object other) {
    if (other is SynchroRequest)
      return hashCode == other.hashCode;
    else if (other is Request) {
      return (method == other.method &&
          url.toString() == other.url.toString() &&
          body == other.body &&
          mapEquals(headers, other.headers));
    }
    return false;
  }

  Future<SynchroResponse> sendIt() async {
    var response = await Response.fromStream(await send());
    return SynchroResponse.fromResponse(response);
  }
}
