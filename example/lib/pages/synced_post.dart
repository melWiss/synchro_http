import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:synchro_http/synchro_http.dart';

class SyncedPost extends StatefulWidget {
  SyncedPost({Key? key}) : super(key: key);

  @override
  State<SyncedPost> createState() => _SyncedPostState();
}

class _SyncedPostState extends State<SyncedPost> {
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
        TextField(
          keyboardType: TextInputType.number,
          controller: textEditingController2,
        ),
        TextField(
          controller: textEditingController3,
        ),
        TextField(
          controller: textEditingController4,
        ),
        ElevatedButton(
          child: const Text("Submit"),
          onPressed: () {
            SynchroHttp.singleton
                .post(
                  path: "/posts",
                  body: jsonEncode({
                    "userId": int.parse(textEditingController1.text),
                    "id": int.parse(textEditingController2.text),
                    "title": textEditingController3.text,
                    "body": textEditingController4.text,
                  }),
                )
                .then((value) => setState(() {}));
          },
        ),
        Expanded(
          child: FutureWidget<Map<String, dynamic>>(
            future: SynchroHttp.singleton.requestsRepo.getAll,
            widget: (snapshot) {
              var data = snapshot.values.toList();
              data = data
                  .where((element) => element['method'] == HttpMethods.POST)
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
