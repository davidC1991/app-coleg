
import 'package:app_red_social/models/post_model.dart';
import 'package:app_red_social/widgets/posts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_red_social/pages/home_page.dart';

class DatosProvider{
String usuarioId;
int postCount=0;
int followerCount=0;
int followingCount=0;
List<Post> posts=[];

getFollowing() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
       usuarioId= prefs.getString('keyUsuarioId');

       QuerySnapshot snapshot = await followingRef
          .document(usuarioId)
          .collection('userFollowing')
          .getDocuments();
      
        followingCount = snapshot.documents.length;

        return followingCount;
       
    }

    checkIfFollowing() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      usuarioId= prefs.getString('keyUsuarioId');

      /* DocumentSnapshot doc = await followersRef
          .document(widget.profileId)
          .collection('userFollowers')
          .document(currentUserId)
          .get();
      
        isFollowing = doc.exists;
  */         
   }
    
   getFollowers() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     usuarioId= prefs.getString('keyUsuarioId');

     QuerySnapshot snapshot = await followersRef
      .document(usuarioId)
      .collection('userFollowers')
      .getDocuments();
    
      followerCount = snapshot.documents.length;
      return followerCount;
   } 

    getProfilePosts() async {
       List<FireBaseModel> posts= new List();
      //conseguir los Id de todos los profesores disponibles
      QuerySnapshot snapshot_d= await docenteRef
      .getDocuments();
       print('<___________>');
       print(snapshot_d.documents.length);

      QuerySnapshot snapshot = await postsRef
        .document('105951231609486716903')
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
        
        //print(snapshot.documents);
        if (snapshot.documents.isEmpty){
          return [];
        } 
        
          //print(snapshot.documents.length);
          //print(snapshot.documents[1].data['materia']);
         for (var i = 0; i < snapshot.documents.length; i++) {
        
           final a = FireBaseModel.fromDocument(snapshot.documents[i]);
           posts.add(a);
           }  
           //posts = snapshot.documents.map((doc) => FireBaseModel.fromDocument(doc)).toList();
           //print(posts[1].nombreDoc);

           return posts;
    }
}
       
    




