import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:app_red_social/provider/peticiones_firebase.dart';
export 'package:app_red_social/provider/peticiones_firebase.dart';

class FirebaseBloc{

  final _tareasController = new BehaviorSubject<List<DocumentSnapshot>>();
  final _materiasController = new BehaviorSubject<Map<String,Object>>();
  final _cursosController = new BehaviorSubject();
  //final _articulosCarritoController = new BehaviorSubject();
  final _cargandoController   = new BehaviorSubject<bool>();
  final contPantallaController   = new BehaviorSubject<int>();
  final materiaSelectedController   = new BehaviorSubject<String>();
  final cursoSelectedController   = new BehaviorSubject<String>();
  String materiaSelected;
  String cursoSelected;
   List<DocumentSnapshot> todasTareas = new List();
  final _datosProvider   = new DatosProvider();


  Stream<List<DocumentSnapshot>> get tareasStream => _tareasController;
  Stream <Map<String,Object>>get materiasStream => _materiasController;
  Stream get cursosStream => _cursosController;
  Stream<bool> get cargandoStream => _cargandoController;
  Stream<int> get contPantallaStream => contPantallaController;
  Stream<String> get materiaSelectedStream => materiaSelectedController;
  Stream<String> get cursoSelectedStream => cursoSelectedController;

cargarTareas()async {
        print('trayendo lo que el docente anteriormente presionó');
       //---------------Escuchando lo que el docente presiona-----------------------------------------
       materiaSelectedStream.listen((b){
        
        
        materiaSelected=b;
        print ('materia seleccionada: $materiaSelected');  
       
         });
        
        cursoSelectedStream.listen((c){
        
        
        cursoSelected=c;
        print ('curso seleccionado: $cursoSelected');  
        
         }); 

         
      //---------------------------------------------------------------------------------------------
     
      _cargandoController.sink.add(true);
      final tareas= await _datosProvider.getTareas();
      todasTareas.clear();
      //print(cursoSelected);
      //print(materiaSelected);
      //print(tareas.documents[1].data.containsValue(cursoSelected));
      //print(tareas.documents[1].data.containsValue(materiaSelected));
      for (var i = 0; i < tareas.documents.length; i++) {
          if (tareas.documents[i].data.containsValue(cursoSelected)&&tareas.documents[i].data.containsValue(materiaSelected)){
          todasTareas.add(tareas.documents[i]);
          }
        }
        //print('estos son los id de las publicaciones del docente en el curso $cursoSelected y la materia $materiaSelected');
        for (var i = 0; i < todasTareas.length; i++) {
         // print(todasTareas[i].documentID);  
        }
     //-----------------------------------------------------------------------------------------------
     _tareasController.sink.add(todasTareas);
     _cargandoController.sink.add(false);
  }
        
      
     
     
     
     




 cargarMaterias()async {
    //_cargandoController.sink.add(true);
     final materias= await _datosProvider.getCursosMaterias();
     //print(materias);
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
    _tareasController?.close();
    _cargandoController?.close();
    _materiasController?.close();
    _cursosController?.close();
     materiaSelectedController?.close();
     cursoSelectedController?.close();
     contPantallaController?.close();
    //_articulosCarritoController?.close();
  }


}