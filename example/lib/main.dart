import 'dart:convert';

import 'package:example/pages/stream_get.dart';
import 'package:example/pages/synced_delete.dart';
import 'package:example/pages/synced_post.dart';
import 'package:flutter/material.dart';
import 'package:synchro_http/synchro_http.dart';

void main() {
  SynchroHttp.baseUrl = "http://localhost:3000";
  // SynchroHttp.lookup = "https://bridella.herokuapp.com/api/ping";
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
  SynchroHttp syn = SynchroHttp();
  late TabController controller = TabController(length: 3, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: NetworkStatusWidget(
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
                    StreamGet(http: syn),
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: SyncedPost(
                        http: syn,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: SyncedDelete(
                        http: syn,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const FloatingActionButton(
        child: Icon(Icons.delete),
        onPressed: SynchroHttp.clearCache,
      ),
    );
  }
}
