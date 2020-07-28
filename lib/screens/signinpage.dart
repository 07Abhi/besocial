import 'dart:developer';
import 'package:besocial/screens/timelinepage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:besocial/model/usermodel.dart';
import 'package:besocial/screens/createuser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:besocial/screens/activityfeedpage.dart';
import 'package:besocial/screens/uploadpage.dart';
import 'package:besocial/screens/searchpage.dart';
import 'package:besocial/screens/profilepage.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final commentRef = Firestore.instance.collection('comments');
final userRef = Firestore.instance.collection('users');
final postRef = Firestore.instance.collection('userspost');
final StorageReference storageRef = FirebaseStorage.instance.ref();
UserData currentUser;
final DateTime timeStamp = DateTime.now();

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool isAuth = false;
  int pageindex = 0;

  PageController pageController;

  Scaffold BuildUnAuthPage() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: <Color>[
          Theme.of(context).accentColor,
          Theme.of(context).primaryColor,
        ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'BeSocial.',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 80.0,
                color: Colors.white70,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            GoogleSignInButton(
              splashColor: Colors.blue,
              onPressed: login,
              darkMode: true,
              textStyle: TextStyle(
                  fontFamily: 'Ubuntu', fontSize: 20.0, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Scaffold BuildAuthPage() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(),
          ActivityFeed(),
          Upload(currentUserData: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: pageChanged,
        //this physics makes the page non scrollable
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageindex,
        onTap: onTap,
        activeColor: Colors.teal,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.camera,
              size: 40.0,
            ),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createFirestoreUser();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createFirestoreUser() async {
    // 1. Check if the user is present or not in collection.
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.document(user.id).get();
    // 2. if not present then take them to the create user page.
    if (!doc.exists) {
      final username = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateUser(),
        ),
      );
      // 3. get username from create accounts and use it to make the documents in user collection.
      userRef.document(user.id).setData({
        'id': user.id,
        'username': username,
        'photourl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'timestamp': timeStamp
      });
      //we get the newly updated data.
      doc = await userRef.document(user.id).get();
    }
    currentUser = UserData.fromDocument(doc);
//    print(currentUser);
//    print(currentUser.username);
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onTap(int pagenum) {
    pageController.animateToPage(
      pagenum,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  pageChanged(int pageindex) {
    setState(() {
      this.pageindex = pageindex;
    });
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error in Signing in $err');
    });
    /*it will tries to login the previously signed in account*/
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error occurred $err');
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? BuildAuthPage() : BuildUnAuthPage();
  }
}
/*
  * Future<void> SignUpWithFacebook() async {
    try {
      var result = await _facebookLogin.logIn(['email']);
      if (result.status == FacebookLoginStatus.loggedIn) {
        final AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token);
        final token = result.accessToken.token;
        final graphRespone = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
        final profile = JSON.jsonDecode(graphRespone.body);

        setState(() {
          userProfile = profile;
        });
        FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
        return user;
      }
    } catch (e) {
      print(e.message);
    }
  }*/
