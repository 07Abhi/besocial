import 'profilepage.dart';
import 'package:besocial/screens/particularpostscreen.dart';
import 'package:besocial/screens/signinpage.dart';
import 'package:besocial/widgets/header.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:besocial/widgets/progressbars.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  Future getActvityfeeds() async {
    QuerySnapshot snapshotData = await activityFeedRef
        .document(currentUser?.id)
        .collection('feeditems')
        .orderBy('timeStamp')
        .limit(40)
        .getDocuments();
    List<ActivityFeedItems> activityFeed = [];
    snapshotData.documents.forEach((docs) {
      activityFeed.add(ActivityFeedItems.fromDocuments(docs));
    });
    return activityFeed;
  }

  @override
  void initState() {
    super.initState();
    //getActvityfeeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent.withOpacity(0.6),
      appBar: Header(context,
          isTitle: true, titleText: 'Notification', removebackBtn: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: getActvityfeeds(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: snapshot.data,
              );
            } else {
              return circularProgress();
            }
          },
        ),
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItems extends StatelessWidget {
  final String username;
  final String postId;
  final String type;
  final String userId;
  final String mediaUrl;
  final String userprofileImage;
  final Timestamp timestamp;
  final String commentData;

  ActivityFeedItems(
      {this.username,
      this.postId,
      this.type,
      this.timestamp,
      this.mediaUrl,
      this.commentData,
      this.userprofileImage,
      this.userId});

  factory ActivityFeedItems.fromDocuments(DocumentSnapshot docs) {
    return ActivityFeedItems(
      username: docs['username'],
      postId: docs['postId'],
      type: docs['type'],
      userId: docs['userId'],
      mediaUrl: docs['mediaUrl'],
      userprofileImage: docs['userprofileImage'],
      timestamp: docs['timeStamp'],
      commentData: docs['commentData'],
    );
  }

  showPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PostScreen(
            postId: postId,
            userId: userId,
          );
        },
      ),
    );
  }

  configureMediaPreview(BuildContext context) {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 60.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(mediaUrl),
                      fit: BoxFit.cover)),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('Nothing');
    }
    if (type == 'like') {
      activityItemText = 'Liked Your Post';
    } else if (type == 'follow') {
      activityItemText = 'is started following you';
    } else if (type == 'comment') {
      activityItemText = 'Replied: $commentData';
    } else {
      activityItemText = 'unknown Type Error!!!';
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Container(
        color: Colors.white70,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context,ProfileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                    fontSize: 14.0, color: Colors.black, fontFamily: 'Ubuntu'),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' $activityItemText'),
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(userprofileImage),
          ),
          subtitle: Text(
            timeAgo.format(
              timestamp.toDate(),
            ),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'Ubuntu'),
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String ProfileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return Profile(
          profileId: ProfileId,
        );
      },
    ),
  );
}
