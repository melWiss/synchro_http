import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:synchro_http/synchro_http.dart';

class StreamGet extends StatelessWidget {
  const StreamGet({
    Key? key,
    required this.synchronizedHttp,
  }) : super(key: key);
  final SynchronizedHttp synchronizedHttp;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: StreamBuilder<Response>(
          stream: synchronizedHttp.streamGet(
              Uri.parse("https://jsonplaceholder.typicode.com/posts")),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.hasData) {
              return Text(snapshot.data!.body);
            }
            return const Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}
