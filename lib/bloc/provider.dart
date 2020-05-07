import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_red_social/bloc/login_bloc.dart';
import 'package:app_red_social/bloc/firebase_bloc.dart';
export 'package:app_red_social/bloc/firebase_bloc.dart';


class Provider extends InheritedWidget{

  static Provider _instancia;
  final _firebaseBloc = new FirebaseBloc();
  final loginBloc = new LoginBloc();

  factory Provider({Key key, Widget child}){
    if (_instancia==null){
      _instancia = new Provider._internal(key:key, child: child);
    }
    return _instancia;
  }

  Provider._internal({Key key, Widget child })
  : super(key:key, child:child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static LoginBloc of (BuildContext context){
     return context.dependOnInheritedWidgetOfExactType<Provider>().loginBloc;
  }

  static FirebaseBloc firebaseBloc (BuildContext context){
    return (context.dependOnInheritedWidgetOfExactType<Provider>()._firebaseBloc);
  
  }

  }

  
