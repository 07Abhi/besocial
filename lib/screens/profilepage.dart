import 'package:besocial/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:besocial/widgets/post_tiles_gridviews.dart';
import 'package:besocial/widgets/postwidget.dart';
import 'package:besocial/widgets/header.dart';
import 'package:besocial/model/usermodel.dart';
import 'package:besocial/screens/signinpage.dart';
import 'package:besocial/widgets/progressbars.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:besocial/screens/updationpage.dart';

class Profile extends StatefulWidget {
  String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
  var profileData;
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  String postOrientation = 'grid';

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdationPage(
          profileId: currentUser?.id,
        ),
      ),
    );
  }

  Future<DocumentSnapshot> fetchData() async {
    profileData = await userRef.document(widget.profileId).get();
    return profileData;
  }

  Future refreshPage() async {
    //await Future.delayed(Duration(seconds: 1));
    var data = await userRef.document(widget.profileId).get();
    await getProfilePost();
    setState(() {
      profileData = data;
    });
    return null;
  }

  Container buildButton({String btnText, Function func}) {
    return Container(
      padding: EdgeInsets.only(top: 3.0),
      child: FlatButton(
        onPressed: func,
        child: Container(
          width: 250.0,
          height: 27.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Text(
            btnText,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Ubuntu'),
          ),
        ),
      ),
    );
  }

  buildEditButton() {
    /*Here we take care of viewing our own profile or viewing of another one */
    bool isProfileisMine = currentUserId == widget.profileId;
    if (isProfileisMine) {
      return buildButton(btnText: 'Edit Profile', func: editProfile);
    } else {
      buildButton(
        btnText: 'follow',
        func: () {
          print('followed');
        },
      );
    }
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
              fontFamily: 'Ubuntu',
            ),
          ),
        ),
      ],
    );
  }

  FutureBuilder buildProfileHeader() {
    return FutureBuilder(
      future: fetchData(), //userRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData userinfo = UserData.fromDocument(snapshot.data);
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(userinfo.photoUrl),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              buildCountColumn('Post', postCount),
                              buildCountColumn('Followers', 0),
                              buildCountColumn('Following', 0),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                buildEditButton(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 12.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    userinfo.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      fontFamily: 'Ubuntu',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    userinfo.displayName,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontFamily: 'Ubuntu',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 3.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    userinfo.bio,
                    style: TextStyle(
                      fontSize: 13.0,
                      fontFamily: 'Ubuntu',
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return circularProgress();
      },
    );
  }

  getProfilePost() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postRef
        .document(widget.profileId)
        .collection('userspost')
        .orderBy('timeStamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((docs) => Post.getDocument(docs)).toList();
    });
  }

  buildProfilePost() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return noPostAvailable('Let\'s Socialize');
    } else if (postOrientation == 'grid') {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        childAspectRatio: 1.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == 'list') {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOri) {
    setState(() {
      postOrientation = postOri;
    });
  }

  Padding buildTogglePostOrientation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            onPressed: () => setPostOrientation('grid'),
            icon: Icon(Icons.grid_on),
            color: postOrientation == 'grid'
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          IconButton(
            onPressed: () => setPostOrientation('list'),
            icon: Icon(Icons.format_list_bulleted),
            color: postOrientation == 'list'
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getProfilePost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context,
          isTitle: true, titleText: 'Profile', removebackBtn: true),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        child: ListView(
          children: <Widget>[
            buildProfileHeader(),
            Divider(
              height: 0.5,
            ),
            buildTogglePostOrientation(),
            Divider(
              height: 0.5,
            ),
            buildProfilePost()
          ],
        ),
      ),
    );
  }
}
