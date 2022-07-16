import 'dart:convert';

import 'package:example/pages/stream_get.dart';
import 'package:example/pages/synced_delete.dart';
import 'package:example/pages/synced_post.dart';
import 'package:flutter/material.dart';
import 'package:synchro_http/synchro_http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  SynchronizedHttp syn = SynchronizedHttp();
  late TabController controller = TabController(length: 3, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            TabBar(
              controller: controller,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black87,
              tabs: const [
                Tab(
                  text: "Stream Get",
                ),
                Tab(
                  text: "Synced Post",
                ),
                Tab(
                  text: "Synced Delete",
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: controller,
                children: [
                  StreamGet(synchronizedHttp: syn),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: SyncedPost(
                      synchronizedHttp: syn,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: SyncedDelete(
                      synchronizedHttp: syn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
