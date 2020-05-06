import 'package:app_red_social/bloc/provider.dart';
import 'package:app_red_social/pages/home_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_red_social/widgets/header.dart';
import 'package:app_red_social/pages/profile_page.dart';
import 'package:timeago/timeago.dart' as timeago;


class ComentariosPage extends StatefulWidget {
  DocumentSnapshot tarea;

  ComentariosPage({Key key, @required this.tarea}) : super(key: key);

  @override
  _ComentariosPageState createState() => _ComentariosPageState();
}

class _ComentariosPageState extends State<ComentariosPage> {
  
  TextEditingController commentController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final firebaseBloc  = Provider.firebaseBloc(context);  
    firebaseBloc.cargarComentarios();

     return GestureDetector(
       onTap: (){
         FocusScope.of(context).requestFocus(new FocusNode());
       },
       child: Scaffold(
        appBar:header(context, textoTitulo: 'Comentarios'),
        body: Column(
          children: <Widget>[
            Expanded(child:comentarios(firebaseBloc)),
             ListTile(
              title: TextFormField(
                controller: commentController,
                decoration: InputDecoration(labelText: 'write a comment...'),
              ),
              trailing: OutlineButton(
                onPressed:enviarComentario, 
                //addComment,
                borderSide: BorderSide.none,
                child: Text('Enviar'),
              ),
            ),
            
          ],
        ),
    ),
     );
  }

  comentarios(FirebaseBloc firebaseBloc){
    
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: firebaseBloc.comentariosStream,
      builder: (context, snapshot){
        if (snapshot.hasData){
          print(snapshot.data);
          List<DocumentSnapshot> comentario=snapshot.data;
          return ListView.builder(
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
   
    if(comentario['docente']){
      return comentarioDocente(context, comentario, firebaseBloc);
    }else return comentarioAlumno(context, comentario, firebaseBloc);
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
  enviarComentario(){
 
    final DateTime timestamp1= DateTime.now();   
    commentsRef
        .document(widget.tarea['postId'])
        .collection('comments')
        .add({
          'username': widget.tarea['nombreDoc'],
          'comment': commentController.text,
          'timestamp': timestamp1,
          'avatarUrl': currentUser.photoUrl,
          'userId': currentUser.id,
          'docente': docente
        });
    FocusScope.of(context).requestFocus(new FocusNode());    
    commentController.clear();   
    setState(() {
      
    });
  }
}