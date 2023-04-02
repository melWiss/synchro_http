import 'dart:convert';
import 'package:http/http.dart';
import 'package:synchro_http/src/repo/cache/repo.dart';

part 'response_model.g.dart';

@HiveType(typeId: 1)
class SynchroResponse extends Response {
  SynchroResponse(
    this.body,
    this.statusCode, {
    required this.headers,
    required this.isRedirect,
    required this.persistentConnection,
    required this.reasonPhrase,
    this.cached = false,
  }) : super(body, statusCode);

  @override
  @HiveField(0)
  final String body;
  @override
  @HiveField(1)
  final int statusCode;
  @override
  @HiveField(2)
  final Map<String, String> headers;
  @override
  @HiveField(3)
  final bool isRedirect;
  @override
  @HiveField(4)
  final bool persistentConnection;
  @override
  @HiveField(5)
  final String? reasonPhrase;
  
  bool cached;

  factory SynchroResponse.fromResponse(Response response) => SynchroResponse(
        response.body,
        response.statusCode,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );

  factory SynchroResponse.fromMap(Map<String, dynamic> map) {
    return SynchroResponse(
      map['body'],
      map['statusCode'],
      headers: map['headers'],
      isRedirect: map['isRedirect'],
      persistentConnection: map['persistentConnection'],
      reasonPhrase: map['reasonPhrase'],
    );
  }

  factory SynchroResponse.fromJson(String json) =>
      SynchroResponse.fromMap(jsonDecode(json));

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'body': body,
      'statusCode': statusCode,
      'headers': headers,
      'isRedirect': isRedirect,
      'persistentConnection': persistentConnection,
      'reasonPhrase': reasonPhrase,
    };
  }

  String toJson() => jsonEncode(toMap());
}
