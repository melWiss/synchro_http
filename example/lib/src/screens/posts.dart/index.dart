import 'package:example/src/blocs/post.dart';
import 'package:example/src/events/post.dart';
import 'package:example/src/screens/posts.dart/add.dart';
import 'package:flutter/material.dart';
import 'package:synchro_http/synchro_http.dart';

class PostsIndex extends StatelessWidget {
  const PostsIndex({super.key});

  @override
  Widget build(BuildContext context) {
    PostBloc bloc = PostBloc();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AddEditPostDialog();
                },
              );
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () => bloc.fetchAll(false),
            icon: const Icon(Icons.replay_outlined),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: NetworkStatusWidget(
        child: StreamWidget<PostEvent>(
          stream: bloc.stream,
          widget: (context, posts) {
            return ListView.builder(
              itemCount: bloc.state!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text("${bloc.state?[index].id.toString()}"),
                  title: Text(
                      "${bloc.state?[index].title} by ${bloc.state?[index].userId}"),
                  subtitle: Text("${bloc.state?[index].body}"),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => bloc.delete(bloc.state![index]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AddEditPostDialog(
                                    post: bloc.state![index]);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
