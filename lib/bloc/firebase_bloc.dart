import 'package:rxdart/rxdart.dart';
import 'package:app_red_social/provider/peticiones_firebase.dart';
export 'package:app_red_social/provider/peticiones_firebase.dart';

class FirebaseBloc{

  final _postController = new BehaviorSubject();
  final _materiasController = new BehaviorSubject();
  final _cursosController = new BehaviorSubject();
  //final _articulosCarritoController = new BehaviorSubject();
  final _cargandoController   = new BehaviorSubject<bool>();
  final contPantallaController   = new BehaviorSubject<int>();
  final materiaSelectedController   = new BehaviorSubject<String>();
  final cursoSelectedController   = new BehaviorSubject<String>();
  

  final _datosProvider   = new DatosProvider();


  Stream get firebaseStream => _postController;
  Stream get materiasStream => _materiasController;
  Stream get cursosStream => _cursosController;
  Stream<bool> get cargandoStream => _cargandoController;
  Stream<int> get contPantallaStream => contPantallaController;
  Stream<String> get materiaSelectedStream => materiaSelectedController;
  Stream<String> get cursoSelectedStream => materiaSelectedController;

cargarPosts()async {
  _cargandoController.sink.add(true);
  final posts= await _datosProvider.getProfilePosts();
     _postController.sink.add(posts);
     _cargandoController.sink.add(false);
     
  }

 cargarMaterias()async {
    //_cargandoController.sink.add(true);
     final materias= await _datosProvider.getMaterias();
     _materiasController.sink.add(materias);
     //_cargandoController.sink.add(false);
     
  }

 cargarCursos()async {
    //_cargandoController.sink.add(true);
     final cursos= await _datosProvider.getCursos();
     _cursosController.sink.add(cursos);
     //_cargandoController.sink.add(false);
     
  }


 dispose(){
    _postController?.close();
    _cargandoController?.close();
    _materiasController?.close();
    _cursosController?.close();
     materiaSelectedController?.close();
     cursoSelectedController?.close();
     contPantallaController?.close();
    //_articulosCarritoController?.close();
  }


}