

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
    final admin;

    User({
        this.id,
        this.username,
        this.photoUrl,
        this.email,
        this.displayName,
        this.bio,
        this.timestamp,
        this.docente,
        this.admin
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
        admin       : doc['admin']
        );
    }

   
}
