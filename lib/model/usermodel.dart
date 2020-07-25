import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String id;
  final String username;
  final String photoUrl;
  final String displayName;
  final String email;
  final String bio;

  UserData(
      {this.id,
      this.email,
      this.displayName,
      this.photoUrl,
      this.username,
      this.bio});

  factory UserData.fromDocument(DocumentSnapshot doc) {
    return UserData(
        id: doc['id'],
        username: doc['username'],
        photoUrl: doc['photourl'],
        displayName: doc['displayName'],
        email: doc['email'],
        bio: doc['bio']);
  }
}
