import 'dart:ui';

import 'package:app_red_social/bloc/firebase_bloc.dart';
import 'package:flutter/material.dart';



Widget botonesMaterias(){
   


    return Table(
      children: [
        TableRow(
          children: [
            _crearBotonRedondeado(Colors.blue, Icons.border_all, 'General'),
            _crearBotonRedondeado(Colors.purpleAccent, Icons.directions_bus,'Bus'),
          ]
        ),
        TableRow(
          children: [
            _crearBotonRedondeado(Colors.green, Icons.directions_car, 'Carro'),
            _crearBotonRedondeado(Colors.brown, Icons.directions_railway,'Rail'),
          ]
        ),
        TableRow(
          children: [
            _crearBotonRedondeado(Colors.yellow, Icons.directions_subway, 'Subway'),
            _crearBotonRedondeado(Colors.greenAccent, Icons.do_not_disturb,'Disturb'),
          ]
        ),
        TableRow(
          children: [
            _crearBotonRedondeado(Colors.lime, Icons.donut_small, 'Donut'),
            _crearBotonRedondeado(Colors.orange, Icons.edit_location,'Edit'),

          ]
        ),
      ],
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
            Text(texto, style: TextStyle(color: Colors.pinkAccent)),  
            
           ],
         ),  
      ),
    );
  }