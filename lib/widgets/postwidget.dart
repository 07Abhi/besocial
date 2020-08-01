import 'dart:async';
import 'package:besocial/screens/signinpage.dart';
import 'package:animator/animator.dart';
import 'package:besocial/screens/comments.dart';
import 'package:besocial/widgets/custom_image_widget.dart';
import 'package:besocial/model/usermodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:besocial/widgets/progressbars.dart';
import 'package:besocial/screens/signinpage.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String caption;
  final String mediaUrl;
  final String username;
  final String location;
  final dynamic likes;

  Post({
    this.postId,
    this.username,
    this.location,
    this.caption,
    this.mediaUrl,
    this.likes,
    this.ownerId,
  });

  factory Post.getDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      username: doc['username'],
      location: doc['location'],
      caption: doc['caption'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
      ownerId: doc['ownerId'],
    );
  }

  int getlikesCount(likes) {
    //if no likes then return Zero
    if (likes == null) {
      return 0;
    }
    int count = 0;
    //if the key is set to true then add a like.
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        caption: this.caption,
        username: this.username,
        location: this.location,
        likesCount: getlikesCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String currentUserId = currentUser?.id;
  final String ownerId;
  final String caption;
  final String mediaUrl;
  final String username;
  final String location;
  Map likes;
  int likesCount;
  bool isLiked;
  bool showHeart = false;

  _PostState({
    this.postId,
    this.ownerId,
    this.caption,
    this.mediaUrl,
    this.username,
    this.location,
    this.likes,
    this.likesCount,
  });

  FutureBuilder buildPostHeader() {
    return FutureBuilder(
      future: userRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData userInfo = new UserData.fromDocument(snapshot.data);
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(userInfo.photoUrl),
            ),
            title: GestureDetector(
              onTap: () {},
              child: Text(
                userInfo.displayName,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            subtitle: Text(
              location,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                color: Colors.grey,
                fontSize: 15.0,
              ),
            ),
            trailing: IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert),
              color: Colors.black87,
            ),
          );
        }
        return circularProgress();
      },
    );
  }

  addLikeToPost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      postRef
          .document(ownerId)
          .collection('userspost')
          .document(postId)
          .updateData({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likesCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      appLikeToActivity();
      postRef
          .document(ownerId)
          .collection('userspost')
          .document(postId)
          .updateData({'likes.$currentUserId': true});
      setState(() {
        likesCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  appLikeToActivity() {
    /*to get notification for the post liked by the other users not by our own */
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection('feeditems')
          .document(postId)
          .setData(
        {
          'type': 'like',
          'username': currentUser.username,
          'userId': currentUser.id,
          'userprofilieImgae': currentUser.photoUrl,
          'postId': postId,
          'mediaUrl': mediaUrl,
          'timeStamp': timeStamp
        },
      );
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection('feeditems')
          .document(postId)
          .get()
          .then(
        (doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        },
      );
    }
  }

  buildPostDisplay() {
    return GestureDetector(
      onDoubleTap: addLikeToPost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cacheNetworkImage(mediaUrl),
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 350),
                  tween: Tween(begin: 0.8, end: 1.2),
                  curve: Curves.easeIn,
                  cycles: 0,
                  builder: (context, anim, child) => Transform.scale(
                    scale: anim.value,
                    child: Icon(
                      Icons.favorite,
                      size: 80.0,
                      color: Colors.white70,
                    ),
                  ),
                )
              : Text(''),
//          showHeart?Icon(Icons.favorite,size: 80.0,color: Colors.white70,):Text(''),
        ],
      ),
    );
  }

//  commentSection(){
//
//  }

  buildPostFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.redAccent,
                  size: 28.0,
                ),
                onTap: addLikeToPost,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: GestureDetector(
                  child: Icon(
                    Icons.insert_comment,
                    color: Colors.blue.shade900,
                    size: 28.0,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Comments(
                          cpostId: postId,
                          postmediaUrl: mediaUrl,
                          postownerId: ownerId,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 10.0),
          child: Text(
            '$likesCount Likes',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15.0,
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 5.0),
              child: Text(
                username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Ubuntu',
                  fontSize: 17.0,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                child: Text(
                  caption,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu',
                    fontSize: 14.0,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Divider(
            height: 0.4,
            color: Colors.grey,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostDisplay(),
        buildPostFooter(),
      ],
    );
  }
}

commentsSection(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) {
      return Comments(
        cpostId: postId,
        postownerId: ownerId,
        postmediaUrl: mediaUrl,
      );
    }),
  );
}
