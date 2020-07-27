import 'package:besocial/screens/profilepage.dart';
import 'package:besocial/widgets/progressbars.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:besocial/model/usermodel.dart';
import 'package:besocial/screens/signinpage.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UpdationPage extends StatefulWidget {
  String profileId;

  UpdationPage({this.profileId});

  @override
  _UpdationPageState createState() => _UpdationPageState();
}

class _UpdationPageState extends State<UpdationPage> {
  bool isLoading = false;
  TextEditingController textNameController = TextEditingController();
  TextEditingController textBioController = TextEditingController();
  UserData userInfo;
  bool _validDisplayName = true;
  bool _validBioLength = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  logoutSession() async {
    await googleSignIn.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignInPage(),
      ),
    );
  }

  updateProfileData() {
    _validDisplayName = textNameController.text.trim().length < 3 ||
            textNameController.text.isEmpty
        ? false
        : true;
    _validBioLength = textBioController.text.trim().length > 100 ||
            textBioController.text.isEmpty
        ? false
        : true;
    if (_validBioLength && _validDisplayName) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      userRef.document(widget.profileId).updateData(
        {'displayName': textNameController.text, 'bio': textBioController.text},
      );
      SnackBar snackBar = SnackBar(
        content: Text(
          'Profile Updated!!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Ubuntu',
          ),
        ),
        duration: Duration(seconds: 2),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            top: 12.0,
          ),
          child: Text(
            'Display Name',
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Ubuntu',
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextField(
          controller: textNameController,
          decoration: InputDecoration(
              hintStyle: TextStyle(fontFamily: 'Ubuntu'),
              hintText: 'Display Name',
              errorText:
                  _validDisplayName ? null : 'Display Name is too short..'),
        ),
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            top: 12.0,
          ),
          child: Text(
            'Bio',
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Ubuntu',
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextField(
          controller: textBioController,
          decoration: InputDecoration(
              hintStyle: TextStyle(fontFamily: 'Ubuntu'),
              hintText: 'Your Social line',
              errorText: _validBioLength ? null : 'Bio Length exceeds...'),
        ),
      ],
    );
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot docs = await userRef.document(widget.profileId).get();
    userInfo = UserData.fromDocument(docs);
    textNameController.text = userInfo.displayName;
    textBioController.text = userInfo.bio;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white70,
        title: Text(
          'Edit Profile',
          style: TextStyle(
              fontSize: 20.0, fontFamily: 'Ubuntu', color: Colors.black87),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.check,
              color: Colors.green,
              size: 30.0,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 16.0,
                          bottom: 8.0,
                        ),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage:
                              CachedNetworkImageProvider(userInfo.photoUrl),
                          backgroundColor: Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildDisplayNameField(),
                            buildBioField(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 70.0, right: 70.0),
                  child: RaisedButton(
                    elevation: 6.0,
                    onPressed: updateProfileData,
                    color: Colors.blue,
                    child: Text(
                      'Update Info',
                      style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                FlatButton.icon(
                  onPressed: logoutSession,
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 30.0,
                  ),
                  label: Text(
                    'Logout',
                    style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.red),
                  ),
                ),
              ],
            ),
    );
  }
}
