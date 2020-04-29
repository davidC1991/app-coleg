

import 'package:cloud_firestore/cloud_firestore.dart';


class User {
    final id;
    final username;
    final photoUrl;
    final email;
    final displayName;
    final bio;
    final timestamp;
    final docente;

    User({
        this.id,
        this.username,
        this.photoUrl,
        this.email,
        this.displayName,
        this.bio,
        this.timestamp,
        this.docente,
    });

    factory User.fromDocument(DocumentSnapshot doc) {
      return User(
        id          : doc["id"],
        username    : doc["username"],
        photoUrl    : doc["photoUrl"],
        email       : doc["email"],
        displayName : doc["displayName"],
        bio         : doc["bio"],
        timestamp   : doc["timestamp"],
        docente     : doc['docente'],
        );
    }

   
}
