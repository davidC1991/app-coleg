import 'package:app_red_social/pages/edit_profile.dart';
import 'package:app_red_social/pages/home_page.dart';
import 'package:app_red_social/widgets/post_tile.dart';
import 'package:app_red_social/widgets/posts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_red_social/widgets/progress.dart';
import 'package:app_red_social/widgets/header.dart';
import 'package:app_red_social/models/user.dart';

class ProfilePage extends StatefulWidget {
  String profileId ;
  bool docenteb ;

  ProfilePage ({ this .profileId, this.docenteb});
 
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isFollowing = false;
  final String currentUserId= currentUser?.id;
  String postOrientation= 'grid';
  bool isLoading= false;
  int postCount=0;
  int followerCount=0;
  int followingCount=0;
  List<Post> posts=[];


  @override
  void initState() { 
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

    getFollowing() async{
       QuerySnapshot snapshot = await followingRef
          .document(widget.profileId)
          .collection('userFollowing')
          .getDocuments();
      setState(() {
        followingCount = snapshot.documents.length;
      }); 
    }

    checkIfFollowing() async{
      DocumentSnapshot doc = await followersRef
          .document(widget.profileId)
          .collection('userFollowers')
          .document(currentUserId)
          .get();
      setState(() {
        isFollowing = doc.exists;
      });    
   }
    
   getFollowers() async {
     QuerySnapshot snapshot = await followersRef
      .document(widget.profileId)
      .collection('userFollowers')
      .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    }); 
   } 

    getProfilePosts() async {
      setState(() {
        isLoading=true;
      });
      QuerySnapshot snapshot = await postsRef
        .document('105951231609486716903')
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
      setState(() {
        isLoading=false;
        postCount= snapshot.documents.length;
        posts= snapshot.documents.map((doc)=>Post.fromDocument(doc)).toList();

      });  
    
    }
   
      Column buildCountColumn(String label, int count){
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              count.toString(),
              style: TextStyle(fontSize:22.0, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: EdgeInsets.only(top:4.0),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400
                )
              ),
            ),  
          ],
        );
      }
      editProfile(){
        Navigator.push(context, MaterialPageRoute(builder: 
        (context)=> EditProfile(currentUserId : currentUserId, docenteb: widget.docenteb)));
      }
    
      Container buildButton({String text, Function function}){
        return Container(
          padding: EdgeInsets.only(top:1.0, left:77.0 ),
          child: FlatButton(
          onPressed: function,
          child: Container(
            width: 250.0,
            height: 27.0,
            child: Text(
              text,
              style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFollowing ? Colors.white : Colors.blue,
              border: Border.all(
                color: isFollowing ? Colors.grey : Colors.blue,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          ),
        );
      }
    
      buildProfileButton(){
        //para ver tu perfil y poder editarlo
        bool isProfileOwner = currentUserId == widget.profileId;
        if (isProfileOwner){
          return buildButton(
            text: 'Editar Perfil',
             function: editProfile);
        }else if(isFollowing){
          return buildButton(
            text: 'Unfollow',
            function: handleUnfollowUser
          );
        }else if(!isFollowing){
          return buildButton(
            text: 'Follow',
            function: handleFllowUser
          );
        }

      }

      handleUnfollowUser(){
        setState(() {
          isFollowing =false;
        });
        //remove followers
        followersRef
          .document(widget.profileId)
          .collection('userFollowers')
          .document(currentUserId)
          .get().then((doc){
            if(doc.exists){
              doc.reference.delete();
            }
          });
        //remove following
        followingRef
          .document(currentUserId)
          .collection('userFollowing')
          .document(widget.profileId)
          .get().then((doc){
            if(doc.exists){
              doc.reference.delete();
            }
          });
        //delete activity feed
        activityFeedRef
          .document(widget.profileId)
          .collection('feedItems')
          .document(currentUserId)
          .get().then((doc){
            if(doc.exists){
              doc.reference.delete();
            }
          });   
      }

      handleFllowUser(){
        setState(() {
          isFollowing =true;
        });
        // make auth user follower of that user (update their followers colletions)
        followersRef
          .document(widget.profileId)
          .collection('userFollowers')
          .document(currentUserId)
          .setData({});
        //put that user on your following collection (update your following collection)
        followingRef
          .document(currentUserId)
          .collection('userFollowing')
          .document(widget.profileId)
          .setData({});
        activityFeedRef
          .document(widget.profileId)
          .collection('feedItems')
          .document(currentUserId)
          .setData({
            'type' : 'follow',
            'ownerId' : widget.profileId,
            'username': currentUser.username,
            'userId' : currentUserId,
            'userProfileImg': currentUser.photoUrl,
            'timestamp': timestamp
          });  
      }
    
      buildProfileHeaders(){
        return FutureBuilder(
          future: widget.docenteb?docenteRef.document(widget.profileId).get():usersRef.document(widget.profileId).get(),
          builder: (context, snapshot){
             if(!snapshot.hasData){
               return circularProgress(context);
             } 
             User user = User.fromDocument(snapshot.data);
             return Padding(
               padding: EdgeInsets.all(16.0),
               child: Column(
                 children: <Widget>[
                   Row(
                     children: <Widget>[
                       CircleAvatar(
                         radius: 40.0,
                         backgroundColor: Colors.grey,
                         backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                       ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                 buildCountColumn('posts', postCount),
                                 buildCountColumn('followers', followerCount),
                                 buildCountColumn('following', followingCount), 
                              ],
                            )  
                          ],
                        )
                      )   
                     ],
                   ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: <Widget>[
                       buildProfileButton(),
                     ],
                   ), 
                   Container(
                     alignment: Alignment.centerLeft,
                     padding: EdgeInsets.only(top: 12.0),
                     child: Text(
                       user.username,
                       style: TextStyle(
                         fontWeight: FontWeight.bold,
                         fontSize: 16.0
                       ),
                     ),
                   ),
                   Container(
                     alignment:  Alignment.centerLeft,
                     padding: EdgeInsets.only(top:4.0),
                     child: Text(
                       user.displayName,
                       style: TextStyle(
                         fontWeight: FontWeight.bold,
                         //fontSize: 16.0
                       ),
                     ),
                   ),
                   Container(
                     alignment: Alignment.centerLeft,
                     padding: EdgeInsets.only(top: 20),
                     child: Text(
                       user.bio,
                     )
                   ),
                 ],
               ),
             );          
          },
        );
      }
      
      buildProfilePosts(){
        if(isLoading){
          return circularProgress(context);
        }else if(postOrientation=='grid'){
                 List<GridTile> gridTiles= [];
                 posts.forEach((post){
                   gridTiles.add(GridTile(child: PostTile(post)));
                 });
                 return GridView.count(
                   crossAxisCount: 3,
                   childAspectRatio: 1.0,
                   mainAxisSpacing: 1.5,
                   crossAxisSpacing: 1.5,
                   shrinkWrap: true,
                   physics: NeverScrollableScrollPhysics(),
                   children: gridTiles,
                 );
        }else if (postOrientation=='list'){
                   return Column(
                   children: posts,
                 ); 

        }
       
            }

    setPostOrientation(String postOrientation){
      setState(() {
        this.postOrientation= postOrientation;
      });
    } 

    buildTogglePostOrientation(){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            onPressed:() => setPostOrientation('grid'),
            icon: Icon(Icons.grid_on),
            color: postOrientation == 'grid' ? Theme.of(context).accentColor :
            Colors.grey,
          ),
          IconButton(
            onPressed:() => setPostOrientation('list'),
            icon: Icon(Icons.list),
            color: postOrientation == 'list' ? Theme.of(context).accentColor :
            Colors.grey,
          )
        ],
      );
    }
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: header(context, textoTitulo: 'perfil'),
          body: ListView(
            children: <Widget>[
              buildProfileHeaders(),
              Divider(),
              buildTogglePostOrientation(),
              Divider(
                height: 0.0,
              ),
              Text('Matematicas'),
              buildProfilePosts(),
            ],
          ),
        );
      }
    
 }