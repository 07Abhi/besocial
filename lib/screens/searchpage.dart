import 'package:besocial/model/usermodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:besocial/screens/signinpage.dart';
import 'package:besocial/widgets/progressbars.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final textController = TextEditingController();
  Future<QuerySnapshot> searchResultFuture;

  handleSearch(String query) async {
    //here we do the query using displayname as a parameter.
    Future<QuerySnapshot> users = userRef
        .where('displayName', isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultFuture = users;
    });
  }

  clearSearch() {
    textController.clear();
    setState(() {
      searchResultFuture = null;
    });
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.grey.shade100,
      title: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        controller: textController,
        decoration: InputDecoration(
          hintText: 'Search for User...',
          hintStyle: TextStyle(fontFamily: 'Ubuntu'),
          filled: true,
          prefixIcon: Icon(
            Icons.portrait,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        //when th euser press enter through keyboard.
        onFieldSubmitted: handleSearch,
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
            GestureDetector(
              onTap: ()async{
                await SystemChannels.textInput.invokeMethod('TextInput.hide');
              },
              child: SvgPicture.asset(
                'images/search.svg',
                height: orientation == Orientation.portrait ? 300.0 : 200.0,
              ),
            ),
            Text(
              'Search Socialites!!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Dancing_Script',
                fontWeight: FontWeight.w600,
                fontSize: 50.0,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder buildsearchResult() {
    return FutureBuilder(
      future: searchResultFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<UserResult> searchResults = [];
          snapshot.data.documents.forEach((doc) {
            // by doing this we get instance of userData and we can slice the data from it;
            UserData users = UserData.fromDocument(doc);
            UserResult searchData = UserResult(users);
            searchResults.add(searchData);
          });
          return ListView(
            children: searchResults,
          );
        }
        return circularProgress();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body: searchResultFuture == null ? buildNoContent() : buildsearchResult(),
    );
  }
}

class UserResult extends StatelessWidget {
  UserData user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {},
            child: ListTile(
              leading: CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Ubuntu',
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Divider(height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),

    );
  }
}
