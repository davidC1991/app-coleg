import 'package:app_red_social/bloc/provider.dart';
import 'package:app_red_social/pages/comentarios_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_red_social/widgets/header.dart';



class TareaPage extends StatefulWidget {
  DocumentSnapshot tarea;
  List<DocumentSnapshot>tareas;
  bool vistaTareaElegida;
  
  TareaPage({Key key, @required this.tareas, @required this.tarea, @required this.vistaTareaElegida}) : super(key: key);

  @override
  _TareaPageState createState() => _TareaPageState();
}

class _TareaPageState extends State<TareaPage> {
 // bool  vistaTareaElegida;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: header(context, textoTitulo: 'Tarea de ${widget.tarea.data['materia']}'),
      body: widget.vistaTareaElegida?tareaUnica(context, widget.tarea):tareaVarias()
      // tareaVarias(),
      //
    );
  }

tareaVarias(){
  return ListView.builder(
            shrinkWrap: true,
            itemCount:widget.tareas.length ,
            itemBuilder: (context, i){
              //return Container();
              return  tareaUnica(context, widget.tareas[i]);
           });
}

Column tareaUnica(BuildContext context, DocumentSnapshot tarea) {
      return Column(
          children: <Widget>[
            descripcionTarea(context, tarea),
            widget.vistaTareaElegida?Expanded(child: fotoTarea(context, tarea)):fotoTarea(context, tarea),  
            respuestaMensaje(context, tarea),
            Divider(height: 40.0),         
        ],
      );       
  }

  descripcionTarea(BuildContext context, DocumentSnapshot tarea){
    return Container(
             alignment: Alignment.centerLeft,
             //color: Colors.blue.withOpacity(0.5),
             padding: EdgeInsets.all(5.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
                 ListTile(
                   contentPadding: EdgeInsets.all(1.0),
                   trailing: Icon(Icons.more_vert),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text('D')
                  ),
                  title: Text('Materia: ${tarea.data['materia']}'), 
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Tema: ${tarea.data['tituloTema']}'),
                      Text('Fecha de entrega: ${tarea.data['fechaLimite']}'),
                    ],
                  ),
                  ),
                  SizedBox(height: 5.0,),
                  Text(tarea.data['descripcion']) 
               ],
             ),
           );
  }

 Container fotoTarea(BuildContext context, DocumentSnapshot tarea){
   return Container(
              child: Container(
                //height: 200.0,
                width: double.infinity,
                padding: EdgeInsets.all(0.0),
                //color: Colors.red,
                child: CachedNetworkImage(
                imageUrl: tarea.data['mediaUrl'],
                fit: BoxFit.cover,
                placeholder: (context, url) => Padding(
                  child: CircularProgressIndicator(),
                  padding: EdgeInsets.all(10.0),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          );
  }

 Container respuestaMensaje(BuildContext context, DocumentSnapshot tarea){
    return Container(
            //color: Colors.grey,
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.message, color: Colors.teal),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ComentariosPage(tarea:tarea)));
                   }
                  ),
                Text('Responder en los comentarios',style: TextStyle(color: Colors.grey))
              ],
            ),
          );
  }
}