import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_red_social/widgets/progress.dart';
import 'package:app_red_social/widgets/posts.dart';
import 'package:app_red_social/widgets/header.dart';
import 'package:app_red_social/models/user.dart';
import 'package:app_red_social/pages/home_page.dart';
import 'package:app_red_social/pages/search_page.dart';

final usersRef=Firestore.instance.collection('users');

class TimeLinePage extends StatefulWidget {
  final User currentUser;

  TimeLinePage({this.currentUser});
  
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
 List<Post> posts;
 List<String> followingList=[];
  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getTimeline() async {
   QuerySnapshot snapshot = await timelineRef
      .document(widget.currentUser.id)
      .collection('timelinePosts')
      .orderBy('timestamp',descending: true)
      .getDocuments();
    List<Post> posts = snapshot.documents.map((doc)=>Post.fromDocument(doc)).toList();  
    setState(() {
      this.posts = posts;
    });
  }

  getFollowing()async{
    QuerySnapshot snapshot = await followingRef
      .document(currentUser.id)
      .collection('userFollowing')
      .getDocuments();

      setState(() {
        followingList= snapshot.documents.map((doc)=>doc.documentID).toList();
      });
  }

  buildTimeline(){
    if(posts == null){
      return circularProgress(context);
    } else if(posts.isEmpty){
      return buildUserToFollow();
    }else{
    return ListView(children: posts);
    }
  }

  buildUserToFollow(){
    return StreamBuilder(
      stream: usersRef.orderBy('timestamp', descending: true)
      .limit(30).snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
        return circularProgress(context);
        }
      List<UserResult> userResults = [];
      
      
        snapshot.data.documents.forEach((doc){
          User user = User.fromDocument(doc);
          final bool isAuthUser = currentUser.id==user.id;
          final bool isFollowingUser = followingList.contains(user.id);
          //remove auth user from recommended list
          if (isAuthUser){
            return;
          }else if(isFollowingUser){
            return;
          }else{
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
          return Container(
            color: Theme.of(context).accentColor.withOpacity(0.2),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).primaryColor,
                        size:30.0
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        'Users to Follow',
                        style: TextStyle(
                          color: Theme.of(context).accentColor.withOpacity(0.2),
                          fontSize: 30.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(children: userResults),
              ],
            ),
          );
      });

     
  }

      
      


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: header(context, esTituloApp: true),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
