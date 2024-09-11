import 'package:example/src/screens/posts.dart/index.dart';
import 'package:flutter/material.dart';
import 'package:synchro_http/synchro_http.dart';

void main() async {
  SynchroHttp.baseUrl = "http://localhost:3000";
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const NetworkStatusWidget(child: PostsIndex()),
    );
  }
}
