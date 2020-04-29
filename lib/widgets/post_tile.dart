import 'package:app_red_social/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:app_red_social/pages/post_screen.dart';
import 'package:app_red_social/widgets/custom_image.dart';
import 'package:app_red_social/widgets/posts.dart';

class PostTile extends StatelessWidget {
  final FireBaseModel post;

  PostTile(this.post);

  /* showPost(context){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: post.postId,
          userId: post.ownerId,
        )
      ),
    );
  } */
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: cachedNetworkImage(post.mediaUrl),
    );    
    
  }
}