import 'package:rxdart/rxdart.dart';
import 'package:app_red_social/provider/peticiones_firebase.dart';

class FirebaseBloc{

  final _postController = new BehaviorSubject();
  //final _articulosCarritoController = new BehaviorSubject();
  final _cargandoController   = new BehaviorSubject<bool>();

  final _datosProvider   = new DatosProvider();


  Stream get firebaseStream => _postController;
  //Stream get articulosCarritoStream => _articulosCarritoController;
  Stream<bool> get cargandoStream => _cargandoController;

cargarPosts()async {
  _cargandoController.sink.add(true);
  final posts= await _datosProvider.getProfilePosts();
     _postController.sink.add(posts);
     _cargandoController.sink.add(false);
     
  }





 dispose(){
    _postController?.close();
    _cargandoController?.close();
    //_articulosCarritoController?.close();
  }


}