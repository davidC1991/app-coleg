import 'dart:ui';

import 'package:app_red_social/bloc/firebase_bloc.dart';
import 'package:flutter/material.dart';



Widget  pantallaCursos(){

  final firebaseBloc  = FirebaseBloc();
  firebaseBloc.cargarMaterias();

  return StreamBuilder(
    stream: firebaseBloc.materiasStream,
    builder: (context, snapshot){
      if(snapshot.hasData){
        final materias=snapshot.data;
        print(snapshot.data);
        //return Container();
        return botones(materias);
      }else{
        return CircularProgressIndicator();
      }
    },
  );

}


 botones(List materias){
    

  return GridView.builder(
      itemCount: materias.length,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (BuildContext context, int i){
         return _crearBotonRedondeado(Colors.blue, Icons.border_all, materias[i]);
        },
       );

  }

 Widget _crearBotonRedondeado(Color color, IconData icono, String texto){
    return BackdropFilter(
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
    );
  }