import 'package:app_red_social/pages/post_screen.dart';
import 'package:app_red_social/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:app_red_social/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_red_social/pages/home_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:app_red_social/pages/profile_page.dart';


class NotificatiosPage extends StatefulWidget {
  @override
  _NotificatiosPageState createState() => _NotificatiosPageState();
}

class _NotificatiosPageState extends State<NotificatiosPage> {
  
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUser.id)
        .collection('feedItems')
        .orderBy('timestamp',descending: true)
        .limit(50)
        .getDocuments();
    List<ActivityFeedItem> feedItems=[];    
    snapshot.documents.forEach((doc){
      //print('activity feed item: ${doc.data}');
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });   

    return feedItems;    
  }
        
  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: header(context, textoTitulo: 'Notificaciones'),
       body: Container(
         child: FutureBuilder(
           future: getActivityFeed(),
           builder: (context, snapshot){
             if(!snapshot.hasData){
               return circularProgress(context);
             }
            return ListView(
              children: snapshot.data,
            );
           }
         ),
       ),
     );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type;  //like, follow, comment
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem({
  this.username,
  this.userId,
  this.type,  //like, follow, comment
  this.mediaUrl,
  this.postId,
  this.userProfileImg,
  this.commentData,
  this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc){
    return ActivityFeedItem(
      username        :doc['username'],
      userId          :doc['userId'],
      type            :doc['type'],
      mediaUrl        :doc['mediaUrl'],
      postId          :doc['postId'],
      userProfileImg  :doc['userProfileImg'],
      commentData     :doc['commentData'],
      timestamp       :doc['timestamp'],
    );
  }

  showPost(context){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: userId,
        )
      ),
    );
  }

  configureMediaPreview(context){
    if(type == 'like' || type== 'comment'){
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl),
                ),
              ),
            ),
          ), 
        ),
      );
    }else {
      mediaPreview=Text('');
    }
    if (type== 'like'){
      activityItemText = 'liked your post';
    }else if ( type== 'follow'){
      activityItemText='comment';
    }else if ( type== 'comment'){
      activityItemText='replied: $commentData';
    }else {
      activityItemText="Error: tipo desconocido '$type'";
    }
  }
  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: ()=> showProfile(context,profileId:userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
              children: [
                TextSpan(
                  text: username,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' $activityItemText',
                ),
              ]  
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
      );
    
  }
}

showProfile(BuildContext context,{String profileId}){
  Navigator.push(context, MaterialPageRoute(builder: (context)=>
  ProfilePage(profileId: profileId,)
  
  ));

}