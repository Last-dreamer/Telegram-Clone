import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String nickname;
  final String photoUrl;
  final String createdAt;

  User({
    this.id,
    this.nickname,
    this.photoUrl,
    this.createdAt,
  });


  DocumentSnapshot ref;


  factory User.fromDocument(Map<String, dynamic> doc) {
    return User(
      id: doc['id'].toString(),
      photoUrl: doc["photourl"].toString(),
      nickname: doc["nickname"].toString(),
      createdAt: doc["createAt"].toString(),
    );
  }
}
