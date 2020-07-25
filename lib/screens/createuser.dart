import 'package:flutter/material.dart';
import 'package:besocial/widgets/header.dart';
import 'package:flutter/services.dart';

class CreateUser extends StatefulWidget {
  @override
  _CreateUserState createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  var formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  String username;
  submit(){
    formKey.currentState.save();
    Navigator.pop(context,username);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context, isTitle: true, titleText: 'Setup Profile'),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0,left: 20.0,right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Create a username',
              style: TextStyle(
                  color: Colors.black87, fontFamily: 'Ubuntu', fontSize: 25.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0,),
            Form(
              key: formKey,
              child: TextFormField(
                onSaved: (val)=>username=val,
                decoration: InputDecoration(
                  labelText: 'User Name',
                  labelStyle: TextStyle(fontFamily: 'Ubuntu'),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                ),
                controller: usernameController,
                validator: (val)=>val.isNotEmpty?null:'Username Required',
              ),
            ),
            SizedBox(height: 20.0,),
            Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 20.0),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0)
                ),
                onPressed: (){
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  if(formKey.currentState.validate()){
                    submit();
                    usernameController.clear();
                  }else{
                    print('Empty Field');
                  }
                },
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Text('Create',style: TextStyle(fontFamily: 'Ubuntu',fontSize: 20.0,color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
