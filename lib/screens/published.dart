import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rootasjey/components/post_card.dart';
import 'package:rootasjey/components/sliver_empty_view.dart';
import 'package:rootasjey/rooter/route_names.dart';
import 'package:rootasjey/rooter/router.dart';
import 'package:rootasjey/state/user_state.dart';
import 'package:rootasjey/types/post.dart';

class Published extends StatefulWidget {
  @override
  _PublishedState createState() => _PublishedState();
}

class _PublishedState extends State<Published> {
  final postsList = List<Post>();
  final limit = 10;

  bool hasNext = true;
  bool isLoading = false;
  var lastDoc;

  @override
  void initState() {
    super.initState();
    initAndCheck();
  }

  void initAndCheck() async {
    final result = await checkAuth();
    if (!result) { return; }

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() {
    if (!isLoading && postsList.isEmpty) {
      return SliverEmptyView();
    }

    return postsListView();
  }

  Widget headerTitle() {
    return Padding(
      padding: const EdgeInsets.all(
        90.0,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () => FluroRouter.router.pop(context),
              icon: Icon(Icons.arrow_back),
            ),
          ),

          Text(
            'Drafts',
            style: TextStyle(
              fontSize: 70.0,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 22.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget postsListView() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final post = postsList.elementAt(index);

          return PostCard(
            onTap: () async {
              await FluroRouter.router.navigateTo(
                context,
                EditPostRoute.replaceFirst(':postId', post.id),
              );

              fetch();
            },
            popupMenuButton: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    showDeleteDialog(index);
                    break;
                  case 'unpublish':
                    unpublish(index);
                    break;
                  default:
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'unpublish',
                  child: ListTile(
                    leading: Icon(Icons.public_off_sharp),
                    title: Text(
                      'Unpublish',
                      style: TextStyle(),
                    ),
                  ),
                ),

                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text(
                      'Delete',
                      style: TextStyle(),
                    ),
                  ),
                ),
              ],
            ),
            post: post,
            padding: const EdgeInsets.only(bottom: 20.0),
          );
        },
        childCount: postsList.length,
      ),
    );
  }

  void showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Are you sure?"
          ),
          content: SingleChildScrollView(
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "This action is irreversible.",
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => FluroRouter.router.pop(context),
              child: Text(
                'CANCEL',
                textAlign: TextAlign.end,
              ),
            ),

            TextButton(
              onPressed: () {
                FluroRouter.router.pop(context);
                delete(index);
              },
              child: Text(
                'DELETE',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.pink,
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  Future<bool> checkAuth() async {
    try {
      final userAuth = await userState.userAuth;
      if (userAuth != null) { return true; }

      FluroRouter.router.navigateTo(context, SigninRoute);
      return false;

    } catch (error) {
      debugPrint(error.toString());
      FluroRouter.router.navigateTo(context, SigninRoute);
      return false;
    }
  }

  void fetch() async {
    setState(() {
      postsList.clear();
      isLoading = true;
    });

    try {
      final userAuth = await userState.userAuth;
      final uid = userAuth.uid;

      final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('published', isEqualTo: true)
        .where('author', isEqualTo: uid)
        .limit(limit)
        .get();

      if (snapshot.size == 0) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      lastDoc = snapshot.docs.last;

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        postsList.add(Post.fromJSON(data));
      });

      setState(() {
        isLoading = false;
        hasNext = limit == snapshot.size;
      });

    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void delete(int index) async {
    setState(() => isLoading = true);

    final removedPost = postsList.removeAt(index);

    try {
      await FirebaseFirestore.instance
        .collection('posts')
        .doc(removedPost.id)
        .delete();

      setState(() => isLoading = false);

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        postsList.insert(index, removedPost);
      });
    }
  }

  void unpublish(int index) async {
    setState(() => isLoading = true);

    final removedPost = postsList.removeAt(index);

    try {
      await FirebaseFirestore.instance
        .collection('posts')
        .doc(removedPost.id)
        .update({
          'published': false,
        });

      setState(() => isLoading = false);

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        postsList.insert(index, removedPost);
      });
    }
  }
}
