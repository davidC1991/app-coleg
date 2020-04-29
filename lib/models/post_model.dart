

import 'package:cloud_firestore/cloud_firestore.dart';


class FireBaseModel {
    final postId;
    final nombreDoc;
    final materia;
    final mediaUrl;
    final descripcion;
    final calificacion;
    final revisado;
    final likes;
    final timestamp;

    FireBaseModel({
      this.postId,
      this.nombreDoc,
      this.materia,
      this.mediaUrl,
      this.descripcion,
      this.calificacion,
      this.revisado,
      this.likes,
      this.timestamp,
      
    });

    factory FireBaseModel.fromDocument(DocumentSnapshot doc) {
      return FireBaseModel(
        postId      : doc["postId"],
        nombreDoc   : doc["nombreDoc"],
        materia     : doc["materia"],
        mediaUrl    : doc["mediaUrl"],
        descripcion : doc["descripcion"],
        calificacion: doc["calificacion"],
        revisado    : doc['revisado'],
        likes       : doc["likes"],
        timestamp   : doc["timestamp"],
        
        );
    }

   
}
