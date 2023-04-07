import 'package:example/src/blocs/post.dart';
import 'package:example/src/models/post.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AddEditPostDialog extends StatelessWidget {
  AddEditPostDialog({super.key, this.post}) : isAdd = post == null;
  Post? post;
  final bool isAdd;

  @override
  Widget build(BuildContext context) {
    post ??= Post(body: "", id: 0, title: "", userId: 0);
    return AlertDialog(
      title: Text(isAdd ? "Add" : "Edit"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) => post!.id = int.parse(value),
            decoration: const InputDecoration(
              hintText: "ID",
            ),
          ),
          TextField(
            onChanged: (value) => post!.userId = int.parse(value),
            decoration: const InputDecoration(
              hintText: "userID",
            ),
          ),
          TextField(
            onChanged: (value) => post!.title = value,
            decoration: const InputDecoration(
              hintText: "Title",
            ),
          ),
          TextField(
            onChanged: (value) => post!.body = value,
            decoration: const InputDecoration(
              hintText: "Body",
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if(isAdd) {
              PostBloc().add(post!);
            } else {
              PostBloc().update(post!);
            }
            Navigator.of(context).pop();
          },
          child: const Text(
            "Save",
          ),
        ),
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
