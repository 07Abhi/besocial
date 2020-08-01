import 'package:besocial/widgets/header.dart';
import 'package:besocial/widgets/postwidget.dart';
import 'package:besocial/widgets/progressbars.dart';
import 'package:besocial/screens/signinpage.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreen({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postRef
          .document(userId)
          .collection('userspost')
          .document(postId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Post postImage = new Post.getDocument(snapshot.data);
          return Scaffold(
            appBar: Header(context,
                isTitle: true,
                titleText: postImage.caption,
                removebackBtn: false),
            body: ListView(
              children: <Widget>[
                Container(
                  child: postImage,
                ),
              ],
            ),
          );
        }
        return circularProgress();
      },
    );
  }
}
