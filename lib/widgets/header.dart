import 'package:flutter/material.dart';
/*//{}we included this becuase we need to make the named parameter.*/
PreferredSize Header(BuildContext context,{bool isTitle = false,String titleText}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(65.0),
    child: AppBar(
      title: Text(
        isTitle?titleText:'BeSocial',
        style: TextStyle(
          color: isTitle?Colors.white:Colors.white70,
          fontFamily: isTitle?'Ubuntu':'Signatra',
          fontSize: isTitle?25.0:50.0,
        ),
      ),
      leading: isTitle?IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){}):null,
      centerTitle: true,
      backgroundColor: Colors.teal,
    ),
  );
}
