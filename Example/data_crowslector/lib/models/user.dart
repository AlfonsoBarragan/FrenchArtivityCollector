import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_crowslector/models/youngster.dart';

class User {
   String id;
   String name;
   String email;
   String photoUrl;
   final Timestamp createdAt;
   Youngster _youngster;

   Youngster get youngster => this._youngster;

   set youngster(Youngster youngster) => this._youngster = youngster;

   User({this.id, this.email, this.photoUrl, this.name, this.createdAt});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      name: doc['name'],
      photoUrl: doc['photo'],
      createdAt: doc['created_at']
    );
  }

  @override
  String toString(){
    return 'id: $id, email: $email, photoUrl: $photoUrl, name: $name, createdAt: ${createdAt.toDate().toIso8601String()}';
  }
  
}
