import 'dart:async';

import 'package:app_red_social/widgets/header.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _sacaffolddKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey <FormState>();
  String username;

  submit(){

    final form = _formKey.currentState;

    if (form.validate()){
       form.save();
       SnackBar snackbar =SnackBar(content: Text('Bienvenido $username'));
       _sacaffolddKey.currentState.showSnackBar(snackbar);
       Timer(Duration(seconds: 2), (){
         Navigator.pop(context, username);
       });
    }
  }
       
   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _sacaffolddKey,
      appBar: header(context, textoTitulo: 'establece tu perfil', removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0), 
                    child: Center(
                      child: Text('Crear un usuario', style: TextStyle(fontSize: 25.0)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(
                        validator: (val){
                          if(val.trim().length < 3 || val.isEmpty){
                            return 'Nombre de usuario muy corto';
                          }else if (val.trim().length > 12){
                            return 'Nombre de usuario muy largo';
                          }else {
                            return null;
                          }
                        },
                        onSaved: (val) => username=val ,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: 'Debe escribir por lo menos 3 caracteres', 
                        )
                      ) ,
                    )
                  ),
                ),
               GestureDetector(
                 onTap:submit ,
                 child: Container(
                   height: 50.0 ,
                   width: 350.0,
                   decoration: BoxDecoration(
                     color: Colors.blue,
                     borderRadius: BorderRadius.circular(7.0),
                   ),
                   child: Center(
                     child: Text('Submit', style: TextStyle(color: Colors.white,fontSize: 15.0,fontWeight: FontWeight.bold))),
                                 
                 ),
               )
                 
                    
              ],
            )),
        ],
      ),

    );
  }
}