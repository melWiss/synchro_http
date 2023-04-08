import 'package:flutter/material.dart';
import 'package:synchro_http/src/enums/sync_status.dart';
import 'package:synchro_http/src/http/synchro_http.dart';
import 'package:synchro_http/src/widgets/widgets.dart';

class NetworkStatusWidget extends StatelessWidget {
  const NetworkStatusWidget({
    Key? key,
    this.child,
    this.showOnline = true,
    this.onlineString = "Online",
    this.syncingString = "Syncing data...",
    this.offlineString = "No Internet Connection",
    this.errorString = "Something went wrong during sync",
  }) : super(key: key);
  final Widget? child;
  final bool showOnline;
  final String onlineString;
  final String syncingString;
  final String offlineString;
  final String errorString;

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
              Material(
                child: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      offlineString,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            if (status == SyncStatus.synchronizing)
              Material(
                child: Container(
                  color: Colors.orange,
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      syncingString,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            if (status == SyncStatus.error)
              Material(
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      errorString,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            if (status == SyncStatus.online && showOnline)
              TimerWidget(
                child: Material(
                  child: Container(
                    color: Colors.green,
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Text(
                        onlineString,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
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
