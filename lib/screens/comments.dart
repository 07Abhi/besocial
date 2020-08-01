import 'package:timeago/timeago.dart' as timeago;
import 'package:besocial/screens/signinpage.dart';
import 'package:besocial/widgets/header.dart';
import 'package:besocial/widgets/progressbars.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:besocial/widgets/header.dart';

class Comments extends StatefulWidget {
  final String cpostId;
  final String postownerId;
  final String postmediaUrl;

  Comments({this.cpostId, this.postmediaUrl, this.postownerId});

  @override
  _CommentsState createState() => _CommentsState(
        cpostId: cpostId,
        postownerId: postownerId,
        postmediaUrl: postmediaUrl,
      );
}

class _CommentsState extends State<Comments> {
  final String cpostId;
  final String postownerId;
  final String postmediaUrl;

  TextEditingController textCommentsController = TextEditingController();

  _CommentsState({this.cpostId, this.postmediaUrl, this.postownerId});

  buildComments() {
    return StreamBuilder(
        stream: commentRef
            .document(cpostId)
            .collection('comments')
            .orderBy(
              'timeStamp',
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Comment> membersComments = [];
            snapshot.data.documents.forEach((doc) {
              membersComments.add(Comment.fromComment(doc));
            });
            return ListView(
              children: membersComments,
            );
          }
          return circularProgress();
        });
  }

  addComment() {
    commentRef.document(cpostId).collection('comments').add({
      'username': currentUser.username,
      'comment': textCommentsController.text,
      'timeStamp': timeStamp,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id
    });
    /*here we adding data not setting it */
    bool isNotPostOwner = postownerId != currentUser?.id;
   // if (isNotPostOwner) {
      activityFeedRef.document(postownerId).collection('feeditems').add({
        'type': 'comment',
        'commentData': textCommentsController.text,
        'username': currentUser.username,
        'userId': currentUser.id,
        'userprofileImage': currentUser.photoUrl,
        'postId': cpostId,
        'mediaUrl': postmediaUrl,
        'timeStamp': timeStamp
      });
    //}
    textCommentsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context,
          titleText: 'Comments', isTitle: true, removebackBtn: false),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: textCommentsController,
              decoration: InputDecoration(
                  hintText: 'Write a comment.....',
                  hintStyle: TextStyle(fontFamily: 'Ubuntu')),
            ),
            //here we are using outline button.
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide(width: 0.5, color: Colors.teal),
              child: Text('Post'),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String comment;
  final String avatarUrl;
  final String userId;
  final Timestamp timeStamp;

  Comment(
      {this.username,
      this.comment,
      this.avatarUrl,
      this.userId,
      this.timeStamp});

  factory Comment.fromComment(DocumentSnapshot docs) {
    return Comment(
      username: docs['username'],
      comment: docs['comment'],
      avatarUrl: docs['avatarUrl'],
      userId: docs['useId'],
      timeStamp: docs['timeStamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20.0,
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
        backgroundColor: Colors.grey,
      ),
      title: Text(
        comment,
        style: TextStyle(fontFamily: 'Ubuntu'),
      ),
      subtitle: Text(
        timeago.format(
          timeStamp.toDate(),
        ),
      ),
    );
  }
}
