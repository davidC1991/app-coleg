import 'package:app_red_social/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:app_red_social/widgets/posts.dart';
import 'package:app_red_social/widgets/progress.dart';
import 'package:app_red_social/pages/home_page.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId});


  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
      future: postsRef.document(userId).collection('userPosts').document(postId).get(),
      builder: (context, snapshot){
        if (!snapshot.hasData){
          return circularProgress(context);
        }
        Post post=Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, textoTitulo: post.description),
            body: ListView(
              children:<Widget>[
                Container(
                  child: post,
                ),
              ], 
            ),
          ),
        );
      }
      
    );
  }
}