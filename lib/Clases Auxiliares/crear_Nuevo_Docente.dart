import 'package:app_red_social/pages/home_page.dart';
import 'package:app_red_social/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_red_social/bloc/login_bloc.dart';
import 'package:app_red_social/provider/usuario_provider.dart';
import 'package:uuid/uuid.dart';
class NuevoDocente{
 final usuarioProvider = new UsuarioProvider();

 Future enviarRegistro(BuildContext context, LoginBloc bloc,Map<String,List<String>> materiasYcursosSelected,String cursosSelected,List<String>materiasSelected, String email, String password,String nombre)async{
  String dato;
   print('creando datos de docente');
  
  

  //QuerySnapshot doc = await docenteRef.getDocuments();
  //bool validadorDocente= doc.documents[0].data.toString().contains(emailController.text); 

       //print('doc: ${account}');
        //if(validadorDocente){
 
         dato=await registrarCorreo(context, bloc,email,password);
         //print('......');
         print('---->$dato'); 
    if(dato!='EMAIL_EXISTS'){    
          print('documento existe');
          
          docenteRef.document(Uuid().v4()).setData({
          'id': Uuid().v4(),
          'email': email,
          'displayName': nombre,
          'timestamp': DateTime.now(),
          'docente': true,
          'cursoInd': [cursosSelected],
          'curso': materiasYcursosSelected,
          'admin'  : false,
          'contrasena': password

        }); 
      
     
    
     }else{
       mostrarAlerta(context, 'Este correo ya esta agregado a un usuario');
      }

    return dato;
}

    
Future registrarCorreo(BuildContext context, LoginBloc bloc, String email, String password)async{
   String dato;
   final info = await usuarioProvider.nuevoUsuario(email, password);
      
         if (info['ok']){
          print('correo registrado correctamente');
           }else{
           //mostrarAlerta(context, info['mensaje']);
            
             return info['mensaje'];
              //print(dato);
            }
          
            }

 Future actualizarRegistroDocente(BuildContext context, LoginBloc bloc,Map<String,List<String>> materiasYcursosSelected,String cursosSelected,List<String>materiasSelected, String email)async{
    print('actualizando datos de docente');
    String idDocente;
  

  QuerySnapshot doc = await docenteRef.getDocuments();
  print(doc.documents);
  print(email);
  
  for (var i = 0; i < doc.documents.length; i++) {
    //print(doc.documents[i].data['email']);
     if(doc.documents[i].data['email']==email){
      print(doc.documents[i].documentID);
      idDocente=doc.documents[i].documentID;
    } 
  }
    Map<String,dynamic> cursos = new Map();
    List<dynamic> cursosInd = new List();

    DocumentSnapshot doc1 = await docenteRef.
                             document(idDocente)
                             .get().then((a){
                               cursos=a.data['curso'];
                               cursosInd=a.data['cursoInd'];
                             });
    print(cursos); 
    print(cursosInd);                           
    print('-------');
    print(cursosSelected);
    print(materiasSelected);
    print(materiasYcursosSelected);
   
    cursosInd.add(cursosSelected); 
    cursos.addAll(materiasYcursosSelected);
   
    print('<------->');
    print(cursosInd);
    print(cursos);

         
   docenteRef.document(idDocente).updateData({
   'cursoInd': cursosInd,
   'curso': cursos,
   });  
      
     
    
/*      }else{
       mostrarAlerta(context, 'Este correo ya esta agregado a un usuario');
      }

    return dato; */
}           
    
}


