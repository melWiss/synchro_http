import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:synchro_http/synchro_http.dart';

class SyncedDelete extends StatelessWidget {
  SyncedDelete({Key? key}) : super(key: key);
  final SynchroHttp http = SynchroHttp();
  TextEditingController textEditingController1 = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();
  TextEditingController textEditingController3 = TextEditingController();
  TextEditingController textEditingController4 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          keyboardType: TextInputType.number,
          controller: textEditingController1,
        ),
        ElevatedButton(
          child: const Text("Submit"),
          onPressed: () {
            http.delete(
              path: "/posts/${textEditingController1.text}",
            );
          },
        ),
        Expanded(
          child: FutureWidget<Map<String, dynamic>>(
            future: http.requestsRepo.getAll,
            widget: (snapshot) {
              var data = snapshot.values.toList();
              data = data
                  .where((element) => element['method'] == HttpMethods.DELETE)
                  .toList();
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Slidable(
                    child: ListTile(
                      leading: Icon(
                        data[index]['status'] != null &&
                                (data[index]['status'] >= 200 &&
                                    data[index]["status"] < 300)
                            ? Icons.check
                            : Icons.close,
                      ),
                      title: Text(data[index]['method']),
                      subtitle: Text(data[index]['url']),
                      trailing: Text(data[index]['status'].toString()),
                    ),
                    endActionPane: ActionPane(
                      children: [
                        SlidableAction(
                          icon: Icons.delete,
                          label: "Delete",
                          onPressed: (ctx) {},
                          backgroundColor: Colors.red,
                        ),
                      ],
                      motion: ScrollMotion(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
