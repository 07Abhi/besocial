import 'package:besocial/widgets/custom_image_widget.dart';
import 'package:besocial/widgets/postwidget.dart';
import 'package:flutter/material.dart';
class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){},
       child: cacheNetworkImage(post.mediaUrl),
    );
  }
}
