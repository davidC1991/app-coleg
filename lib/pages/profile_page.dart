import 'package:app_red_social/bloc/firebase_bloc.dart';
import 'package:app_red_social/pages/edit_profile.dart';
import 'package:app_red_social/pages/home_page.dart';
import 'package:app_red_social/widgets/botones_cursos.dart';
import 'package:app_red_social/widgets/botones_materias.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:app_red_social/widgets/progress.dart';
import 'package:app_red_social/widgets/header.dart';
import 'package:app_red_social/models/user.dart';


import 'dart:ui';

class ProfilePage extends StatefulWidget {
  String profileId ;
  bool docenteb ;
  
  ProfilePage ({ this.profileId, this.docenteb});
 
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  bool isFollowing = false;
  final String currentUserId= currentUser?.id;
  String postOrientation= 'grid';
  bool isLoading= false;
  
  List<Widget> lista= List();

 /*  int postCount=0;
  int followerCount=0;
  int followingCount=0; 
 */
List<Widget> publicaciones=   new List();


  @override
  void initState() { 
    super.initState();
    pantallaCursos();
    /* getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing(); */
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
               padding: EdgeInsets.only(left:15.0,right:15.0, top: 10.0, bottom: 0.0),
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
                                 /* buildCountColumn('posts', postCount),
                                 buildCountColumn('followers', followerCount),
                                 buildCountColumn('following', followingCount), */
                                 buildCountColumn('posts', 2),
                                 buildCountColumn('followers', 2),
                                 buildCountColumn('following', 2), 
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
                     padding: EdgeInsets.only(top: 2.0),
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
                     padding: EdgeInsets.only(top:.0),
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
        final firebaseBloc  = FirebaseBloc();
        //firebaseBloc.cargarPosts();
          
        firebaseBloc.cargandoStream.listen((a){
        isLoading=a;
        print ('isLoading: $isLoading');
         });


        return Scaffold(
          appBar: header(context, textoTitulo: 'perfil'),
          body: SingleChildScrollView(
           
           
              child: Column(
                children: <Widget>[


                
                  buildProfileHeaders(),
               
                   buildTogglePostOrientation(),
                
                   pantallaCursos()
                
                
               
               // pantallaCursos(),
               // SingleChildScrollView(child: botonesMaterias()),
                //botonesMaterias()
                //tituloMateria(),
                //Expanded(child: _crearPost(context, firebaseBloc)),
                         
              ],
            ),
          )          
        );
      }
          
  Widget _crearPost(BuildContext context, FirebaseBloc firebaseBloc){
    
    return  StreamBuilder(
                  stream: firebaseBloc.firebaseStream,
                  builder: (context, snapshot){
                    
                    if ( !snapshot.data.isEmpty ){
                      //print(snapshot.data[1].materia);
                      //print(snapshot.data.length);
                      final ds= snapshot.data;
                      
                      if(postOrientation=='grid'){
                         return _dibujarCuadriculasReportes(context, ds, firebaseBloc);
                      }else if (postOrientation=='list'){
                        
                           return ListView.builder(
                             itemCount:ds.length ,
                             itemBuilder: (context, i){
                               return  imagen_list(context, ds, i, firebaseBloc);
                            }
                           );
                      }
                    }else{
                      return Center(child: CircularProgressIndicator());
                    }
                  }
                );
              }
                                
                

     

Widget _tablaDeMaterias(BuildContext context, final ds, int i, FirebaseBloc firebaseBloc){
  return Column(
    children: <Widget>[
     _dibujarCuadriculasReportes(context, ds, firebaseBloc),
   ],
  );
}                      
                       
                       
 tituloMateria(){
   return Container(
     height: 30.0,
     width: 300.0,
     color: Colors.blue,
     child: Text('Castellano'),
   );
 }                       
                    
 _dibujarCuadriculasReportes(BuildContext context, final ds, FirebaseBloc firebaseBloc){

  
  return GridView.builder(
      itemCount: ds.length,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (BuildContext context, int i){
         return imagen(context, ds, i, firebaseBloc);
          },);
       }


Widget imagen_list(BuildContext context, final ds, int i, FirebaseBloc firebaseBloc){
  return Container(
    height: 200.0,
    //width: 50.0,
    padding: EdgeInsets.all(10.0),
    child: Card(
                margin: EdgeInsets.symmetric(horizontal: 2.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
            //    child: Image.network(product.documents[i].data['mediaUrl'])
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FadeInImage(
                  image: NetworkImage(ds[i].mediaUrl),
                  placeholder: AssetImage('assets/cargando.gif'),
                  //height: 70.0,
                  //width: 100.0,
                  //fit: BoxFit.cover, 
              
            
          ),
         ),
        ),
  );
}

 Widget imagen(BuildContext context, final ds, int i, FirebaseBloc firebaseBloc){
      return Padding(
        padding: const EdgeInsets.all(1.0),
        child: Card(
                margin: EdgeInsets.symmetric(horizontal: 2.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
            //    child: Image.network(product.documents[i].data['mediaUrl'])
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FadeInImage(
                  image: NetworkImage(ds[i].mediaUrl),
                  placeholder: AssetImage('assets/cargando.gif'),
                  height: 70.0,
                  width: 100.0,
                  fit: BoxFit.cover, 
              
            
          ),
         ),
        ),
      );
    }


}




