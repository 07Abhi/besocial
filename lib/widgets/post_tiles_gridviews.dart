import 'package:besocial/widgets/custom_image_widget.dart';
import 'package:besocial/widgets/postwidget.dart';
import 'package:flutter/material.dart';
import 'package:besocial/screens/particularpostscreen.dart';
class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);

  showPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PostScreen(
            postId: post.postId,
            userId: post.ownerId,
          );
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:()=>showPost(context),
       child: cacheNetworkImage(post.mediaUrl),
    );
  }
}
