import 'dart:async';

import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);
  final Widget child;
  final Duration duration;

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  bool show = true;
  @override
  void initState() {
    super.initState();
    Timer(
      widget.duration,
      () {
        setState(() {
          show = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (show) return widget.child;
    return Container();
  }
}
