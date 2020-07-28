import 'package:besocial/widgets/header.dart';
import 'package:flutter/material.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body:Text('Hello world!!'),
    );
  }
}
/*
*  createUser()async{
//  userRef.add({
//    'username':'Raman',
//    'isAdmin':true,
//    'postcount': 4
//  });
//  }
/*CRUD operation*/
  createUser() {
    userRef
        .document('qwqiwoiqpwo')
        .setData({'username': 'Raman', 'isAdmin': true, 'postcount': 4});
  }

  updateData() async {
    String docId = 'RQscJUUJDPRyKI7K01nb';
    final doc = await userRef.document(docId).get();
    if (doc.exists) {
//    userRef.document(docId).updateData(
//        {'username': 'Raman Yadav', 'isAdmin': false, 'postcount': 3});
      doc.reference.updateData({
        'isAdmin': false,
        'postcount': 3,
        'username': 'Alok Mishra',
      });
    } else {
      print('No data exits');
    }
  }

  deleteData() async {
    String docId = 'RQscJUUJDPRyKI7K01nb';
    final doc = await userRef.document(docId).get();
    if (doc.exists) {
//    userRef.document(docId).delete();
      doc.reference.delete();
    } else {
      print('No data exits for deletion');
    }
  }
   getUser() async {
//    final QuerySnapshot snapshot = await userRef
//        .where('postcount', isGreaterThanOrEqualTo: 2)
//        .where('isAdmin', isEqualTo: true)
//        .getDocuments();
//  final QuerySnapshot snapshot = await userRef.orderBy('postcount',descending:true).getDocuments();
//    snapshot.documents.forEach((docs) {
//      print(docs.data);
//      print(docs.data['username']);
//      print(docs.documentID);
//      print(docs.exists);
//    });
    final QuerySnapshot snapshot = await userRef.getDocuments();
  }

//
//    userRef.getDocuments().then((QuerySnapshot snapshot) {
//      snapshot.documents.forEach((DocumentSnapshot docs) {
////        print(docs.data);
//        //print(docs.data['username']);
//        print(docs.documentID);
////        print(docs.exists);
//      });
//    });

  getUserById() async {
    String id = 'RQscJUUJDPRyKI7K01nb';
    final DocumentSnapshot doc = await userRef.document(id).get();
    print(doc.data);
    print(doc.metadata);
  }

  @override
  void initState() {
    //getUser();
//    createUser();
//    updateData();
//  deleteData();
    super.initState();
  }
  //body of the scaffold
  StreamBuilder<QuerySnapshot>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Text> child = snapshot.data.documents
                .map((user) => Text(user['username']))
                .toList();
            return ListView(
              children: child,
            );
          }
          return circularProgress();
        },
      ),

*/