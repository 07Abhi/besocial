import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final textController = TextEditingController();

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.grey.shade100,
      title: TextFormField(
        controller: textController,
        decoration: InputDecoration(
          hintText: 'Search for User...',
          hintStyle: TextStyle(fontFamily: 'Ubuntu'),
          filled: true,
          prefixIcon: Icon(
            Icons.portrait,
            size: 28.0,
          ),
          suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: () {}),
        ),
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'images/search.svg',
              height: orientation == Orientation.portrait?300.0:200.0,
            ),
            Text(
              'Search Socialites!!',
              textAlign:TextAlign.center,
              style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Dancing_Script',
                  fontWeight: FontWeight.w600,
                  fontSize: 52.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: buildSearchField(),
      body: buildNoContent(),
    );
  }
}

class UserResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('results');
  }
}
