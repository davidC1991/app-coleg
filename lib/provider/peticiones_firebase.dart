
import 'dart:convert';

import 'package:app_red_social/bloc/firebase_bloc.dart';
import 'package:app_red_social/bloc/provider.dart';
import 'package:app_red_social/models/post_model.dart';
import 'package:app_red_social/pages/profile_page.dart';
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

    
    getCursos() async {
       List<String> materias= new List();
      //conseguir los Id de todos los profesores disponibles
      SharedPreferences prefs = await SharedPreferences.getInstance();
      usuarioId= prefs.getString('keyUsuarioId');

       QuerySnapshot snapshot_d= await docenteRef
      .document(usuarioId)
      .get().then((b){
        if(b.exists){
          //print(b.data['materias'][1]);
          for (var i = 0; i < b.data.length; i++) {
            materias.add(b.data['cursoInd'][i]);
          }
        }else{
          print('no hay documento');
        }
      }).catchError((error){
        //print(error);
      });
      
      //print('materias:$materias'); 
      return materias;
    }

     getCursosMaterias() async {
       List<String> cursos= new List();
       Map<String, Object> materiasYcursos= new Map();
       List r = new List();
       //final materiasYcursos= new Map();
      
       SharedPreferences prefs = await SharedPreferences.getInstance();
       usuarioId= prefs.getString('keyUsuarioId');
      //------------------------------------------------------
       QuerySnapshot snapshot_f= await docenteRef
      .document(usuarioId)
      .get().then((b){
        if(b.exists){
          //print(b.data['curso']);
          //print(b.data['curso'][b.data['cursoInd'][0]]);
          //r.add(b.data['curso'][b.data['cursoInd'][0]]);
          //print(b.data['cursoInd'][0]);
         // materiasYcursos[b.data['cursoInd'][0]]=b.data['curso'][b.data['cursoInd'][0]];
               
          for (var i = 0; i < b.data['cursoInd'].length; i++) {
            if(b.data['cursoInd'][i]!=null && b.data['curso'][b.data['cursoInd'][i]]!=null){
               materiasYcursos[b.data['cursoInd'][i]]=b.data['curso'][b.data['cursoInd'][i]];
            }
          }
          print('--|--');
          
        }else{
          print('no hay documento');
        }
      }).catchError((error){
        //print(error);
      }); 
      //--------------------------------------------------------------------------
      //print(materiasYcursos);
      if(materiasYcursos==null){
        print('No hay datos en esta peticion --------------------->');
      }
      return materiasYcursos;
    }

    getTareas() async{
     
  
      SharedPreferences prefs = await SharedPreferences.getInstance();
      usuarioId= prefs.getString('keyUsuarioId');
     
     
      QuerySnapshot snapshot = await postsRef
        .document(usuarioId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        
        .getDocuments();
        //print(snapshot.documents.length);
        /* print('==================');
        print(snapshot.documents[0].data);
        print('=========|=========');
        print(snapshot.documents[0].data.containsKey('curso'));
        print('=================='); */
        
        if (snapshot.documents.isEmpty){
          return [];
        } 
        
        return snapshot;         
    }

    getComentarios()async{
     /*  commentsRef.document(postId).collection('comments')
      .orderBy('timestamp', descending: false).snapshots(), */
      //print(idTarea);
     
       
       QuerySnapshot snapshot = await commentsRef
        .document(idTarea)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .getDocuments();

      
        //print(snapshot.documents);
        return snapshot.documents;
    }

    getMateriasAlumnos()async{
      List<String> materias= new List();
        QuerySnapshot snapshot = await usersRef
        .document(currentUser.id)
        .get().then((a){
          if(a.exists){
            //print(a.data['materias'][0]);
            //print(a.data['materias'].length);

            for (var i = 0; i < a.data['materias'].length; i++) {
              materias.add(a.data['materias'][i]);
            }
          }  
        }); 

       //print(materias);
       return materias; 

    }

    getTareasAlumnos()async{
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String curso= prefs.getString('keyCurso');
      //print('materia seleccionada:$materiaSelected');
      //print('curso seleccionado:$curso');
      List<Map> mapaCursos= new List<Map>();
      Map<String, Object> materiasYcursos= new Map();
      String docenteIdSelected;
      QuerySnapshot snapshot = await docenteRef
      .getDocuments();
      
      print(materiasYcursos=snapshot.documents[0].data['curso']);
      //print(materiasYcursos['primero'].toString().contains('matematicas'));  

      for (var i = 0; i < snapshot.documents.length; i++) {
        materiasYcursos=snapshot.documents[i].data['curso'];
        // print('....');
        //print(materiasYcursos);
       // print(materiasYcursos[0]);
        
       if(materiasYcursos.containsKey(curso)){
        
          //print('este es un profesor del curso de $curso');
         if(materiasYcursos[curso].toString().contains(materiaSelected)){
          //print('este es un profesor da $materiaSelected en el curso de $curso');
          docenteIdSelected=snapshot.documents[i].data['id'];
        }  
          
      } 
      }
      //print(docenteIdSelected);
      if(docenteIdSelected!=null){
      //print('----------------------------');
       DocumentSnapshot docenteIdPost = await postsRef
        .document(docenteIdSelected)
        
        .get();
       // print(docenteIdPost.documentID);
        if(docenteIdPost.documentID==docenteIdSelected){
          //print('El docente si tiene tareas subidas');
          List<DocumentSnapshot> tareasElegidas= new List<DocumentSnapshot>();
          QuerySnapshot snapshot1 = await postsRef
          .document(docenteIdSelected)
          .collection('userPosts')
          .orderBy('timestamp', descending: true)
          .getDocuments();
         // print('==================');
         // print(snapshot1.documents[0].data['materia']);
         // print(snapshot1.documents[0].data['curso']);
        //print('=========|=========');
        //print(snapshot.documents[0].data.containsKey('curso'));
        //print('=================='); 
        for (var i = 0; i < snapshot1.documents.length; i++) {
          if(snapshot1.documents[i].data['materia']==materiaSelected && snapshot1.documents[i].data['curso']==curso){
            tareasElegidas.add(snapshot1.documents[i]);
            //print(snapshot1.documents[i].documentID);
          }
        }

        /* if (snapshot1.documents.isEmpty){
          return [];
        } */ 
        

         String nombre;
         SharedPreferences prefs = await SharedPreferences.getInstance();
         nombre= prefs.getString('keyUserName');
         //print(nombre);
         Map<DocumentSnapshot,String> tareasConCalificacion= Map();
         QuerySnapshot snapshot12 = await calificacionesRef
         .document(nombre)
         .collection('materias')
         .getDocuments();
          
          print(tareasElegidas.length);
          print(snapshot12.documents.length);
          
         for (var i = 0; i < tareasElegidas.length; i++) {
           for (var n = 0; n < snapshot12.documents.length; n++) {
              if(tareasElegidas[i].documentID.toString()==snapshot12.documents[n].documentID.toString()){
              
               tareasConCalificacion[tareasElegidas[i]]=snapshot12.documents[n].data['calificacion'];
             } 
           }
         }
          tareasConCalificacion.forEach((key, value) { 
            print(key.documentID);
          });
        //  print(tareasConCalificacion[tareasElegidas[0]]);
         // print(tareasElegidas);
          print('--');
              
        bool aux=false;
         if(tareasConCalificacion.length!=tareasElegidas.length){
           for (var y = 0; y < tareasElegidas.length; y++) {
            print(y);
             
           tareasConCalificacion.keys.forEach((key) { 
            print('--${tareasElegidas[y].documentID}--${key.documentID}');
            if(tareasElegidas[y].documentID==key.documentID){
             //tareasConCalificacion[tareasElegidas[y]]='';
             aux=true;
            
             //print('igual');
            }
            print(aux); 
            });
             if(!aux){
              tareasConCalificacion[tareasElegidas[y]]='';
            }else{aux=false;} 
           }
            
            

            
           
              
               
          
             
           
            
         }
          
          print(tareasConCalificacion);
          return tareasConCalificacion;
        }else{
          print('El docente no ha subido tareas');
          //return [];
        } 
       }
    }

        
    getAlumnosPropios()async{
          
          QuerySnapshot snapshot1 = await usersRef
          .getDocuments();
          //print('------------|-------------');
          //print(snapshot1.documents[0].data['displayName']);

          return snapshot1.documents;
          


        } 
   getCalificaciones()async{
     String nombre;
     SharedPreferences prefs = await SharedPreferences.getInstance();
     nombre= prefs.getString('keyUserName');
     SharedPreferences prefs1 = await SharedPreferences.getInstance();
     usuarioId= prefs1.getString('keyUsuarioId');
     //print(nombre);
  
     QuerySnapshot snapshot1 = await calificacionesRef
     .document(nombre)
     .collection('materias')
     .getDocuments();
     
    // print('-------------------2------------'); 
    // print(snapshot1.documents);

     return snapshot1.documents;
   }  
 
        
}
       
    




