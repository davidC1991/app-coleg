import 'package:app_red_social/bloc/firebase_bloc.dart';
import 'package:app_red_social/bloc/provider.dart';
import 'package:app_red_social/pages/edit_profile.dart';
import 'package:app_red_social/pages/home_page.dart';
import 'package:app_red_social/pages/subir_tarea.dart';
import 'package:app_red_social/pages/upLoad_page.dart';
//import 'package:app_red_social/widgets/botones_cursos.dart';
import 'package:app_red_social/widgets/botones_materias.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_red_social/widgets/progress.dart';
import 'package:app_red_social/widgets/header.dart';
import 'package:app_red_social/models/user.dart';


import 'dart:ui';

import 'package:flutter/scheduler.dart';

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
  String materiaSelected;
  String cursoSelected;
  int contPantalla=0;
  List<String> cursos= List();
  List<Widget> lista= List();
  List<DocumentSnapshot> tareas = new List();

 /*  int postCount=0;
  int followerCount=0;
  int followingCount=0; 
 */
List<Widget> publicaciones=   new List();



  @override
  void initState() { 
    super.initState();
    //pantallaCursos();
    /* getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing(); */
    
        //firebaseBloc.cargarPosts();
          
       
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
          height: 35.0,
          //color: Colors.pink.withOpacity(0.3),
          padding: EdgeInsets.only(top:1.0, left:77.0 ),
          child: FlatButton(
          onPressed: function,
          child: Container(
            width: 200.0,
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
      FlatButton tareaButton(){
        return FlatButton(
          onPressed: ()=>  Navigator.pushNamed(context, 'foto'),
          child: Container(
            width: 200.0,
            height: 27.0,
            child: Text(
              'Crear Tarea',
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
                      ),
                         
                     ],
                   ),
                 
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: <Widget>[
                         buildProfileButton(),
                         
                       ],
                     ),
                    
                    
                   Container(
                     //color: Colors.blue.withOpacity(0.3),
                     alignment: Alignment.centerLeft,
                     padding: EdgeInsets.only(top: 0.0),
                     height: 27.0,
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.start,
                       mainAxisSize: MainAxisSize.max,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: <Widget>[
                         Text(
                           user.username,
                           style: TextStyle(
                             fontWeight: FontWeight.bold,
                             fontSize: 16.0
                           ),
                         ),
                         SizedBox(width: 24.0,),
                         
                         contPantalla==2?tareaButton():Container(),
                       ],
                     ),
                   ),
                   Container(
                     //color: Colors.yellow.withOpacity(0.3),
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
                     //color: Colors.red.withOpacity(0.3),
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
      print('orientacion: $postOrientation');
      setState(() {
        this.postOrientation= postOrientation;
      });
    } 

    buildTogglePostOrientation(){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            onPressed:() { 
              setPostOrientation('grid');
              //setState(() {});
              },
            icon: Icon(Icons.grid_on),
            color: postOrientation == 'grid' ? Theme.of(context).accentColor :
            Colors.grey,
          ),
          IconButton(
            onPressed:() { 
              setPostOrientation('list');
              //setState(() {});
              },
            icon: Icon(Icons.list),
            color: postOrientation == 'list' ? Theme.of(context).accentColor :
            Colors.grey,
          )
        ],
      );
    }
      @override
      Widget build(BuildContext context) {
        final firebaseBloc  = Provider.firebaseBloc(context);  
        
        firebaseBloc.cargandoStream.listen((a){
        isLoading=a;
        print ('isLoading: $isLoading');
         });

        firebaseBloc.materiaSelectedStream.listen((b){
        
       // setState(() {
        materiaSelected=b;
        print ('materia seleccionada:::::::::::::::::: $materiaSelected');  
       // });
         });
        
        firebaseBloc.cursoSelectedStream.listen((c){
        
        //setState(() {
        cursoSelected=c;
        print ('curso seleccionado:::::::::::::: $cursoSelected');  
        //});
         });
        
 

        return Scaffold(
          appBar: header(context, textoTitulo: 'perfil'),
          body: Column(
                children: <Widget>[


                
                   buildProfileHeaders(),
                   buildTogglePostOrientation(),
                   Expanded(child: Container(child: selectorPantalla(firebaseBloc,context)))
               
                   
                  
                   
                
               
               // pantallaCursos(),
               // SingleChildScrollView(child: botonesMaterias()),
                //botonesMaterias()
                //tituloMateria(),
                //Expanded(child: _crearPost(context, firebaseBloc)),
                         
              ],
          
          )          
        );
      }
          

  Widget selectorPantalla(FirebaseBloc firebaseBloc, BuildContext context){

     switch (contPantalla) {
         case 0 : {return pantallaCursos(firebaseBloc, context);}
            break;
         case 1 : {return pantallaMaterias( firebaseBloc, context);}
            break; 
         case 2 : {return pantallaTareas(firebaseBloc, context);}
         break;     
       }
       return Container();
      }

        
  Widget  pantallaTareas(FirebaseBloc firebaseBloc,BuildContext context){

  firebaseBloc.cargarTareas();

   return StreamBuilder<List<DocumentSnapshot>>(
    stream: firebaseBloc.tareasStream,
    builder: (context, snapshot){
      if(snapshot.hasData){
       //tareas.clear();
       tareas =snapshot.data;
        print(tareas);

        if(postOrientation=='grid'){
             return _dibujarCuadriculasReportes(context, tareas);
          }else if (postOrientation=='list'){
            return ListView.builder(
            shrinkWrap: true,
            itemCount:tareas.length ,
            itemBuilder: (context, i){
              return  imagen_list(context, tareas, i);
           });
          }
        //return Container();
        
      }else{
        return CircularProgressIndicator();
      }
    },
  ); 
  //return Container();
}       
  
  Widget  pantallaCursos(FirebaseBloc firebaseBloc,BuildContext context){

  
  firebaseBloc.cargarCursos();

  return StreamBuilder(
    stream: firebaseBloc.cursosStream,
    builder: (context, snapshot){
      if(snapshot.hasData){
        cursos=snapshot.data;
        print(snapshot.data);
        //return Container();
        return botones(cursos,context,firebaseBloc);
      }else{
        return CircularProgressIndicator();
      }
    },
  );

}
  
  Widget  pantallaMaterias(FirebaseBloc firebaseBloc,BuildContext context ){

  
  firebaseBloc.cargarMaterias();

  return StreamBuilder <Map<String,Object>>(
    stream: firebaseBloc.materiasStream,
    builder: (context, snapshot){
      print('---------------');
      if(snapshot.data!=null){
        print(snapshot.data);
        print('curso seleccionado:$cursoSelected');
        final materias=snapshot.data[cursoSelected];
        if(materias==null){return Container();}//Este docente aun no tiene esta materia asiganada a este curso
        print(materias);
        //cursoSelected
        return botones(materias, context,firebaseBloc);
      //return Container();
      }else{
        return CircularProgressIndicator();
      }
    },
  );

}

 
 botones(List boton, BuildContext context, FirebaseBloc firebaseBloc){
    

  return GridView.builder(
      itemCount: boton.length,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (BuildContext context, int i){
         return _crearBotonRedondeado(Colors.blue, Icons.border_all, boton[i],context,firebaseBloc);
        },
       );

  }

 Widget _crearBotonRedondeado(Color color, IconData icono, String texto,BuildContext context,FirebaseBloc firebaseBloc){
    return GestureDetector(
      onTap: (){
        if (contPantalla==0){   //pantalla cursos
          firebaseBloc.cursoSelectedController.sink.add(texto);
        }else if(contPantalla==1){
          firebaseBloc.materiaSelectedController.sink.add(texto);
        }
          
        setState(() {
          
        });  
        contPantalla++;
        firebaseBloc.contPantallaController.sink.add(contPantalla);
        print('Profesor prresionó el boton : $texto');
        print('ContPantalla : $contPantalla');
             
      },
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX:0.1,sigmaY: 0.0),
          child: Container(
          height: 150.0,
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            //color: Color.fromRGBO(62,66,107,0.7).withOpacity(0.2),
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0)
             ),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: <Widget>[
                CircleAvatar(
                  backgroundColor:color,
                  radius: 35.0,
                  child: Icon(icono, color: Colors.white, size: 30.0),
                ),
              Text(texto, style: TextStyle(color: Colors.black)),  
              
             ],
           ),  
        ),
      ),
    );
  }

                                
Widget _tablaDeMaterias(BuildContext context, final ds, int i){
   

  
  return Column(
    children: <Widget>[
     _dibujarCuadriculasReportes(context, ds),
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
                    
_dibujarCuadriculasReportes(BuildContext context, List<DocumentSnapshot> tareas){

  
  return GridView.builder(
      itemCount: tareas.length,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (BuildContext context, int i){
         return imagen(context, tareas, i);
          },);
       }

Widget imagen_list(BuildContext context, List<DocumentSnapshot> tareas, int i){
   return Container(
    height: 300.0,
    //width: 50.0,
    padding: EdgeInsets.all(10.0),
    child:Card(
                margin: EdgeInsets.symmetric(horizontal: 2.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
            //    child: Image.network(product.documents[i].data['mediaUrl'])
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FadeInImage(
                  image: NetworkImage(tareas[i].data['mediaUrl']),
                  placeholder: AssetImage('assets/cargando.gif'),
                  height: 300.0,
                  //width: 100.0,
                  fit: BoxFit.cover, 
          ),
         ),
        ), 
  );
}
       
            

 Widget imagen(BuildContext context, List<DocumentSnapshot> tareas, int i){
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
                  image: NetworkImage(tareas[i].data['mediaUrl']),
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




