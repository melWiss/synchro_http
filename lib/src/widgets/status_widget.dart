import 'package:flutter/material.dart';
import 'package:synchro_http/src/enums/sync_status.dart';
import 'package:synchro_http/src/http/synchro_http.dart';
import 'package:synchro_http/src/widgets/widgets.dart';

class NetworkStatusWidget extends StatelessWidget {
  const NetworkStatusWidget({
    Key? key,
    this.child,
    this.showOnline = true,
  }) : super(key: key);
  final Widget? child;
  final bool showOnline;

  @override
  Widget build(BuildContext context) {
    SynchroHttp http = SynchroHttp();
    return StreamWidget<SyncStatus>(
      stream: http.sync,
      widget: (context, status) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: child ?? Container()),
            if (status == SyncStatus.offline)
              Container(
                color: Colors.red,
                padding: const EdgeInsets.all(8),
                child: const Center(
                  child: Text(
                    "No Internet Connection",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (status == SyncStatus.synchronizing)
              Container(
                color: Colors.orange,
                padding: const EdgeInsets.all(8),
                child: const Center(
                  child: Text(
                    "Syncing data...",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            if (status == SyncStatus.online && showOnline)
              TimerWidget(
                child: Container(
                  color: Colors.green,
                  padding: const EdgeInsets.all(8),
                  child: const Center(
                    child: Text(
                      "Online",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
