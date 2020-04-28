import 'package:flutter/material.dart';

AppBar header(BuildContext context, {bool esTituloApp=false, String textoTitulo, removeBackButton= false} ){
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
     esTituloApp ? 'App College' : textoTitulo,
     style: TextStyle(
       color:Colors.white,
       fontFamily: esTituloApp ? 'Signatra' : '',
       fontSize: esTituloApp ? 40.0 : 22.0,
     ),
     overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
      
  );

}