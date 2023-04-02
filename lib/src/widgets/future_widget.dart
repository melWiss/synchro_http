import 'package:flutter/material.dart';

class FutureWidget<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) widget;
  final Widget Function(Object? error)? onError;
  final Widget Function()? onWait;
  const FutureWidget({
    Key? key,
    required this.future,
    required this.widget,
    this.onError,
    this.onWait,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return widget(snapshot.data!);
        else if (snapshot.hasError) {
          if (onError == null)
            return Center(
              child: Text("Error while loading data:\n${snapshot.error}"),
            );
          else
            return onError!(snapshot.error);
        } else {
          if (onWait == null)
            return const Center(
              child: CircularProgressIndicator(),
            );
          else
            return onWait!();
        }
      },
    );
  }
}
