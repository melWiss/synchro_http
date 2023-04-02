import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:synchro_http/synchro_http.dart';

class StreamGet extends StatelessWidget {
  StreamGet({
    Key? key,
  }) : super(key: key);
  final SynchroHttp http = SynchroHttp();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: FutureWidget<Response>(
          future: http.get(path: "/posts"),
          widget: (snapshot) {
            return Text(snapshot.body);
          },
          onError: (error) {
            if (error is NoInternetException<Response>) {
              return Text(error.data?.body ?? error.message);
            }
            return Center(
              child: Text(error.toString()),
            );
          },
        ),
      ),
    );
  }
}
