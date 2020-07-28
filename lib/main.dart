import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/comments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'screens/signinpage.dart';
import 'screens/createuser.dart';
import 'screens/updationpage.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.pinkAccent,
      ),
      home: SignInPage(),
    );
  }
}

Container noPostAvailable(String msg) {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
          'images/no_content.svg',
          height: 260.0,
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 20.0,
          ),
          child: Text(
            msg,
            style: TextStyle(
              fontFamily: 'Signatra',
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 50.0,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ],
    ),
  );
}
