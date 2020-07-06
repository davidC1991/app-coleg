

import 'dart:io';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart'; 
import 'package:app_red_social/bloc/provider.dart';
import 'package:app_red_social/pages/home_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';





class ComentariosPage extends StatefulWidget {
  DocumentSnapshot tarea;

  ComentariosPage({Key key, @required this.tarea}) : super(key: key);

  @override
  _ComentariosPageState createState() => _ComentariosPageState();
}

class _ComentariosPageState extends State<ComentariosPage> {
  File file1;
  String mediaUrl="";
  
  bool isUploading= false;
  String fotoId= Uuid().v4();
  TextEditingController commentController = TextEditingController();
  TextEditingController calificacionController = TextEditingController();
  ScrollController _scrollController = new ScrollController();
   String nombre,usuarioId,nombreAlumno,materia;
   String calificacion=''; 
   final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    iniciarNombre();
   
      
  }
  iniciarNombre()async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
     nombre= prefs.getString('keyUserName');
     SharedPreferences prefs1 = await SharedPreferences.getInstance();
     usuarioId= prefs1.getString('keyUsuarioId');
     materia=widget.tarea['materia'];
  }

handleTakePhoto() async {
    Navigator.pop(context);
      File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState((){
      this.file1 = file;
    });
        
  }  

  handleChooseFromGallery()async{
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    
     setState((){
      this.file1 = file;
    });
    
      
  }
 
   selectImage(parentContext){
    return showDialog(
      context: parentContext,
      builder: (context){
        return SimpleDialog(
          title: Text('Escoger Imagen'),
          children: <Widget>[
            SimpleDialogOption(
               child: Text('Foto de Camara'),
               onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
               child: Text('Imagen de Galeria'),
               onPressed: handleChooseFromGallery,
            ),
            SimpleDialogOption(
               child: Text('Cancelar'),
               onPressed: ()=> Navigator.pop(context),
            ),
          ],
        );
      }

    );
  }

  clearImage(){
    setState(() {
      file1= null;
    });
  }

compressImage()async{
       
    
   // 
    final tempDir=   await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file1.readAsBytesSync());
    final compressedImageFile= File('$path/img_$fotoId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile,quality: 85));
    setState(() {
      file1=compressedImageFile;
    });
    
  }


 handleSubmit() async{
    await compressImage();
    mediaUrl = await uploadImage(file1);
    if (mediaUrl.isNotEmpty){
      setState(() { 
      isUploading=false;
      });
    }
    
    
    }

   Future<String> uploadImage(imageFile) async{

         StorageUploadTask uploadTask = storageRef.child('foto_$fotoId.jpg').putFile(imageFile);
         StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
         String downloadUrl = await storageSnap.ref.getDownloadURL();
         return downloadUrl;
 }


  @override
  Widget build(BuildContext context) {
    final firebaseBloc  = Provider.firebaseBloc(context);  
    firebaseBloc.cargarComentarios();


      firebaseBloc.alumnoSelectedStream.listen((b){     
        nombreAlumno=b;
        print ('stream nombre alumno: $nombreAlumno');  
      });

       
     return GestureDetector(
       onTap: (){
         FocusScope.of(context).requestFocus(new FocusNode());
       },
       child: Scaffold(
        key: _scaffoldKey,
        appBar:AppBar(
          backgroundColor: Theme.of(context).accentColor,
          centerTitle: true,
          title: Text(
      'Comentarios',
      style: TextStyle(
       color:Colors.white,
       fontFamily: 'Signatra',
       fontSize: 22.0,
        ),
        ),
        actions: <Widget>[
           IconButton(
             icon: Icon(Icons.check_circle_outline),
             onPressed: (){
               calificarEstudiante(context);
             }
         )
        ],
        
        ),
        body: Column(

          children: <Widget>[
            Expanded(child:comentarios(firebaseBloc)),
             ListTile(
              title: file1 == null ? TextFormField(
                     controller: commentController,
                     decoration: InputDecoration(labelText: 'Escribe tu Respuesta...'),
                     ): AspectRatio(
                aspectRatio:0.7,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file1),
                    )
                  )
                ), 
              ),
               
            
              trailing:
                 Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      
                      IconButton(
                        onPressed:(){
                          isUploading= true;
                         
                          selectImage(context);}, 
                        //addComment,
                        icon: Icon(Icons.add_photo_alternate),
                        iconSize: 32.0,
                      ),
                      IconButton(
                        onPressed:() async {
                          if(isUploading){
                              await handleSubmit();
                            }
                            enviarComentario(firebaseBloc);
                            
                          }, 
                        //addComment,
                        icon: Icon(Icons.send),
                        iconSize: 32.0,
                      ),
                    ],
                ),
               
              
            ),
            
          ],
        ),
    ),
     );
  }
    
  calificarEstudiante(BuildContext context)async{
    return showDialog(
      context:context,
      builder: (context)=>AlertDialog(
        //contentPadding:EdgeInsets.all(50) ,
        //clipBehavior: ,
        //title: Text('ggpp'),
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        content: TextField(
          controller: calificacionController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            icon: Icon(Icons.check_circle_outline),
            labelText: 'Ingrese la calificación',
            border: OutlineInputBorder(
              borderRadius:BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
          onChanged: (val){
            print('val:$val');
            calificacion=val;
          },
        ),

        actions: <Widget>[
          FlatButton(
            child: Text('Cancelar'),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('Guardar'),
            onPressed: (){
              print('calificacion:$calificacion');
               if(calificacion.isNotEmpty){  
               enviarCaliificacion();
              calificacionController.clear();
              Navigator.pop(context);
               setState(() {
      
              });
              }else{
                print('ñññññññ');
                _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content:Text('Debe digitar una nota del 0 al 5'),
                  duration: Duration(milliseconds: 500),
                ),
               );
              }
            },
          )
        ],

        )
      );
  }
    
  enviarCaliificacion()async{
      
         calificacionesRef
         .document(nombreAlumno)
         .collection('materias')
         .document(widget.tarea['postId'])
         .setData({
          'materia':materia,
          'nombreAlumno': nombreAlumno,
          'IdProfesor' :usuarioId,
          'nombreDocente':nombre,
          'calificacion': calificacion,
          'tema' : widget.tarea['tituloTema'],
          'fechaLimite': widget.tarea['fechaLimite'],
          'idTarea': widget.tarea['postId']
        });

      postsRef
    .document(usuarioId)
    .collection('userPosts')
    .document(widget.tarea['postId'])
    .updateData({
      'calificacion':true,
    });

      calificacion='';
    }  
       
  comentarios(FirebaseBloc firebaseBloc){
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: firebaseBloc.comentariosStream,
      builder: (context, snapshot){
        if (snapshot.hasData){
          //print(snapshot.data);
          List<DocumentSnapshot> comentario=snapshot.data;
          //print('alumnoId--->: ${comentario[0].data['username']}');
          //firebaseBloc.alumnoIdController.sink.add(event);
          print('cantidad de comentarios--->: ${comentario.length}');
          return ListView.builder(
            controller: _scrollController,
            itemCount: comentario.length,
            itemBuilder: (context, i){
              return listaComentarios(context, comentario[i],firebaseBloc);
            }
          ); 
          
          //return Container();
        }else{
          return Center(child: CircularProgressIndicator(),);
        }
      }
    );
  }

  listaComentarios(BuildContext context, DocumentSnapshot comentario, FirebaseBloc firebaseBloc){
    //print('${comentario['comment']}');
    if(comentario['docente']){
      
    // nombreAlumno=comentario.data['alumno'];
     //firebaseBloc.alumnoIdController.sink.add(event);
      return comentarioDocente(context, comentario, firebaseBloc);
    }else{ 
      return comentarioAlumno(context, comentario, firebaseBloc);
      }
  }
 comentarioDocente(BuildContext context, DocumentSnapshot comentario, FirebaseBloc firebaseBloc){
   return Column(
      children: <Widget>[
        SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.only(right:20.0, left: 20.0),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(comentario['avatarUrl']),),
          subtitle:Column(
             mainAxisSize: MainAxisSize.max,
             crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                //height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.0)
                 ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(comentario['username'], style: TextStyle(fontSize:15.0, fontWeight: FontWeight.bold)),
                    SizedBox(height:5.0),
                    comentario['comment']==""? ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: FadeInImage(
                      image: NetworkImage(comentario['foto']),
                      placeholder: AssetImage('assets/cargando.gif'),
                      height: 170.0,
                      width: 200.0,
                      fit: BoxFit.cover, 
                      ),
                    )
                    :Text(comentario['comment']),

                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 8),
                child: Text(timeago.format(comentario['timestamp'].toDate(),locale: 'es'))
              )
            ],
          ),
          // Text(timeago.format(comentario['timestamp'].toDate())),
        ),
        //Divider(),
      ],
    );
 }

 comentarioAlumno(BuildContext context, DocumentSnapshot comentario, FirebaseBloc firebaseBloc){
   return Column(
      children: <Widget>[
        SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.only(right:20.0, left: 20.0),
          trailing: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(comentario['avatarUrl']),),
          subtitle:Column(
             mainAxisSize: MainAxisSize.max,
             crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                //height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.0)
                 ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(comentario['username'], style: TextStyle(fontSize:15.0, fontWeight: FontWeight.bold)),
                    SizedBox(height:5.0),
                    Text(comentario['comment']),

                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 8),
                child: Text(timeago.format(comentario['timestamp'].toDate(),locale: 'es'))
              )
            ],
          ),
          // Text(timeago.format(comentario['timestamp'].toDate())),
        ),
        //Divider(),
      ],
    );

 }
  enviarComentario(FirebaseBloc firebaseBloc){
    print("mediaUrl::::::::::::::::::::::::::$mediaUrl");
   

    final DateTime timestamp1= DateTime.now();   
    commentsRef
        .document(widget.tarea['postId'])
        .collection('comments')
        .add({
          'username':nombre,
          'comment': commentController.text,
          'timestamp': timestamp1,
          'avatarUrl': currentUser.photoUrl,
          'userId': currentUser.id,
          'docente': docente,
          'alumno' : docente?nombreAlumno:'',
          'foto'   : mediaUrl 
        });

    FocusScope.of(context).requestFocus(new FocusNode());    
    commentController.clear();   
    _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
    mediaUrl="";
    file1=null;
    isUploading=false;
    fotoId= Uuid().v4();
      
    setState(() {
      
    });
  }
}