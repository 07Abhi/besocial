import 'package:flutter/material.dart';
Container circularProgress(){
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10.0),
    child: CircularProgressIndicator(
      strokeWidth: 4.0,
      valueColor: AlwaysStoppedAnimation(Colors.teal),
    ),
  );
}
Container linearProgress(){
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}