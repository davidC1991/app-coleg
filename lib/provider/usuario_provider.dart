import 'dart:convert';
import 'package:app_red_social/preferencias/preferencias_usuario.dart';
import 'package:http/http.dart' as http;




class UsuarioProvider {
  

  final String _firebaseToken = 'AIzaSyBoTQntJf0RpEuILYKj-UFAO6DjaaGfr0E';
  final _prefs = new PreferenciasUsuario();

  Future <Map <String, dynamic>> login (String email, String password) async {
      final authData = {
      'email'             : email,
      'password'          : password,
      'returnSecureToken' : true,

    };

  final resp = await http.post(
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_firebaseToken',
    body: json.encode(authData)
  );

  Map<String, dynamic> decodeResp = json.decode(resp.body);

  print(decodeResp);

  if (decodeResp.containsKey('idToken')){
    
    _prefs.token = decodeResp['idToken'];
    //Todo: salvar el token en el storage
    return {'ok': true , 'token' : decodeResp['idToken'], 'email': decodeResp['email'],'id': decodeResp['localId'],'nombreCompleto': decodeResp['displayName']};
  }else {
    return {'ok' : false, 'mensaje' : decodeResp['error']['message']};
  }

  }
  //---------------------------------------------------------------
  Future <Map <String, dynamic>> nuevoUsuario(String email, String password) async {

    final authData = {
      'email'             : email,
      'password'          : password,
      'returnSecureToken' : true,

    };

  final resp = await http.post(
    'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_firebaseToken',
    body: json.encode(authData)
  );

  Map<String, dynamic> decodeResp = json.decode(resp.body);

  //print(decodeResp);

  if (decodeResp.containsKey('idToken')){
     _prefs.token = decodeResp['idToken'];
    //Todo: salvar el token en el storage
    return {'ok': true , 'token' : decodeResp['idToken']};
  }else {
    return {'ok' : false, 'mensaje' : decodeResp['error']['message']};
  }

  }

}