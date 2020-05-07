

import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:app_red_social/bloc/validators.dart';


class LoginBloc with Validators {

  final _emailController =    BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();

  
//recuperar los datos del stream   
  Stream<String>get emailStream => _emailController.stream.transform(validarEmail);
  Stream<String>get passwordStream => _passwordController.stream.transform(validarPassword);

  Stream<bool> get formValidStream =>
     CombineLatestStream.combine2(emailStream, passwordStream, (e, p) => true);


// insertar valores al stream
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

//obtener el ultimo valor ingresado a los stream

  String get email => _emailController.value;
  String get password => _passwordController.value;
  
dispose(){
  _emailController?.close();
  _passwordController?.close();
}

}