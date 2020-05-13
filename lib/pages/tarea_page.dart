import 'package:app_red_social/bloc/provider.dart';
import 'package:app_red_social/pages/comentarios_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:app_red_social/widgets/header.dart';


String nombreAlumno;
class TareaPage extends StatefulWidget {
  DocumentSnapshot tarea;
  List<DocumentSnapshot>tareas;
  bool vistaTareaElegida;
  bool docenteb;
  
  TareaPage({Key key, @required this.tareas, @required this.tarea, @required this.vistaTareaElegida, @required this.docenteb}) : super(key: key);

  @override
  _TareaPageState createState() => _TareaPageState();
}

class _TareaPageState extends State<TareaPage> {
  bool  expandedList=false;
  int contBox=0;
  List<bool> checkBox= new List();
  bool alumnoSelected=false;
 //List<bool> checkBox= new List();

  @override
  Widget build(BuildContext context) {
    final firebaseBloc  = Provider.firebaseBloc(context);  
    firebaseBloc.boxController.sink.add(false);
    print('es un docente:${widget.docenteb}');
    return Scaffold(
      appBar: header(context, textoTitulo: 'Tarea de ${widget.tarea.data['materia']}'),
      body: tareaUnica(context, widget.tarea,firebaseBloc)
      //widget.vistaTareaElegida?tareaUnica(context, widget.tarea):tareaVarias()
      // tareaVarias(),
      //
    );
  }

/* tareaVarias(){
  return ListView.builder(
            shrinkWrap: true,
            itemCount:widget.tareas.length ,
            itemBuilder: (context, i){
              //return Container();
              return  tareaUnica(context, widget.tareas[i]);
           });
}
 */
Column tareaUnica(BuildContext context, DocumentSnapshot tarea, FirebaseBloc firebaseBloc) {
      return Column(
          children: <Widget>[
            descripcionTarea(context, tarea),
            widget.vistaTareaElegida?Expanded(child: fotoTarea(context, tarea)):fotoTarea(context, tarea),  
            widget.docenteb==false?Text(''):escogerAlumno(firebaseBloc),
            alumnoSelected?respuestaMensaje(context, tarea):widget.docenteb==false?respuestaMensaje(context, tarea):Text(''),
            Divider(height: 40.0),         
        ],
      );       
  }

  escogerAlumno(FirebaseBloc firebaseBloc){
    print('expandedList--->:$expandedList');
    return ExpansionTileCard(
                //leading: CircleAvatar(child: Text('Materias')),
                
                onExpansionChanged: (value){
                 // print('value tile: $value');
                // expandedList=value;
                 print('value tile: $value');
                },
                duration: Duration(milliseconds: 500),
                initiallyExpanded: firebaseBloc.boxController.value,
                title: Text('Seleccione el alumno con el que desea interacturar'),
                subtitle: Text('presione para ver mas'),
                children: <Widget>[
                  traerAlumnos(firebaseBloc),
                ]
    );
  }

  traerAlumnos(FirebaseBloc firebaseBloc){
    firebaseBloc.cargarAlumnosPropios();
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: firebaseBloc.alumnosPropiosStream,
      builder: (context, snapshot){
        if(snapshot.hasData){
          //print(snapshot.data[0]['displayName']);
          List<String> alumnos= new List();
          
          alumnos.clear();
          print('contBox:$contBox');
          for (var i = 0; i < snapshot.data.length; i++) {
            alumnos.add(snapshot.data[i]['displayName']);
            print('---------------------');
            if(contBox==0){
              print('1111');
            checkBox.add(false);
           
            }
            //print(checkBox);
            //print(alumnos[i]);
          }
          
            return ListView.builder(
            shrinkWrap: true,
            itemCount: alumnos.length,
            itemBuilder: (BuildContext context, int i){
              return ListTile(
                 leading: CircleAvatar(child: Text(alumnos[i][0].toUpperCase()),backgroundColor: Colors.red.withOpacity(0.5),),
                  title: Text(alumnos[i]),
                  trailing:Checkbox(
                  onChanged:(bool value) {
                    /* List<bool> checkBox= new List(snapshot.data.length);
                    for (var i = 0; i < snapshot.data.length; i++) {
                      checkBox.add(value);
                    } */
                   /*  switch (i) {
                             case 0 : { */
                             //print(value);
                             //checkBoxAlumnos=value;

                             checkBox[i]=value;
                             //print(checkBox[i]);
                               
                            /*  }
                             break;
                             case 1 :{

                             }
                             break;
                    } */
                     contBox=1;          
                    for (var k = 0; k < alumnos.length; k++) {
                      print('k:$k');
                      print('i:$i');
                      
                       if(k==i){
                          if (checkBox[k]==true){
                          alumnoSelected=true;
                          }else{alumnoSelected=false;}
                          print(checkBox[i]);
                          print('esta en la linea');
                         }  else{
                            checkBox[k]=false;
                            print(checkBox[k]);
                           }   
                    }
                           
                            
                    firebaseBloc.alumnoSelectedController.sink.add(alumnos[i]);
                    print('alumnoSelected:$alumnoSelected');
                    firebaseBloc.boxController.sink.add(false);
                    //expandedList=false;
                    // FocusScope.of(context).requestFocus(new FocusNode()); 
                    setState(() {
                      
                    });   
                  },
                  value:checkBox[i]
                  //,
                 ),

              );
            }
            );  
          //return Container();
        }else{
          return CircularProgressIndicator();
        }
      },
     
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