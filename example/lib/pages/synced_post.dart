import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:synchro_http/synchro_http.dart';

class SyncedPost extends StatelessWidget {
  SyncedPost({Key? key, required this.synchronizedHttp}) : super(key: key);
  final SynchronizedHttp synchronizedHttp;
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
            synchronizedHttp.post(
              Uri.parse("https://jsonplaceholder.typicode.com/posts"),
              headers: {"Content-Type": "application/json"},
              body: {
                "userId": int.parse(textEditingController1.text),
                "id": int.parse(textEditingController2.text),
                "title": textEditingController3.text,
                "body": textEditingController4.text,
              },
            );
          },
        ),
        Expanded(
          child: StreamBuilder<Map<String, dynamic>>(
            stream: synchronizedHttp.requestsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else if (snapshot.hasData) {
                var data = snapshot.data!.values.toList();
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
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ],
    );
  }
}
