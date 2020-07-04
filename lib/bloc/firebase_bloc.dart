import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:app_red_social/provider/peticiones_firebase.dart';
export 'package:app_red_social/provider/peticiones_firebase.dart';

class FirebaseBloc{
 
  final _tareasController = new BehaviorSubject<List<DocumentSnapshot>>();
  final _tareasAlumnoController = new BehaviorSubject<Map<DocumentSnapshot,String>>();
  final _comentariosController = new BehaviorSubject<List<DocumentSnapshot>>();
  final _materiasController = new BehaviorSubject<Map<String,Object>>();
  final _cursosController = new BehaviorSubject();
  final listaTareaElegidaController = new BehaviorSubject<bool>();
  final _cargandoController   = new BehaviorSubject<bool>();
  final contPantallaController   = new BehaviorSubject<int>();
  final materiaSelectedController   = new BehaviorSubject<String>();
  final cursoSelectedController   = new BehaviorSubject<String>();
  final _materiasAlumonsController   = new BehaviorSubject<List<String>>();
  final actorSelectedController   = new BehaviorSubject<String>();
   final _alumnosPropiosController = new BehaviorSubject<List<DocumentSnapshot>>();
   final boxController   = new BehaviorSubject<bool>();
   final alumnoSelectedController   = new BehaviorSubject<String>();
   final docenteUserNameController   = new BehaviorSubject<String>();
   final alumnoIdController   = new BehaviorSubject<String>();
   final _calificacionesController = new BehaviorSubject<List<DocumentSnapshot>>();
   


  String materiaSelected;
  String cursoSelected;
   String alumno_1;
   String docente_1;
  List<DocumentSnapshot> todasTareas = new List();
  final _datosProvider   = new DatosProvider();
 
  Stream<bool> get boxStream => boxController;
  Stream<String> get alumnoSelectedStream => alumnoSelectedController;
  Stream<String> get alumnoIdStream => alumnoIdController;
  Stream<String> get docenteUserNameStream => docenteUserNameController;
  Stream<String> get actorSelectedStream => actorSelectedController;
  Stream<List<DocumentSnapshot>> get comentariosStream => _comentariosController;
  Stream<List<DocumentSnapshot>> get alumnosPropiosStream => _alumnosPropiosController;
  Stream<List<DocumentSnapshot>> get tareasStream => _tareasController;
  Stream<Map<DocumentSnapshot,String>> get tareasAlumnoStream => _tareasAlumnoController;
  Stream <Map<String,Object>>get materiasStream => _materiasController;
  Stream get cursosStream => _cursosController;
  Stream<bool> get cargandoStream => _cargandoController;
  Stream<bool> get listaTareaElegidaStream => listaTareaElegidaController;
  Stream<int> get contPantallaStream => contPantallaController;
  Stream<String> get materiaSelectedStream => materiaSelectedController;
  Stream<String> get cursoSelectedStream => cursoSelectedController;
  Stream<List<String>> get materiasAlumnosStream => _materiasAlumonsController;
  Stream<List<DocumentSnapshot>> get calificacionesStream => _calificacionesController;
  


cargarCalificaciones()async{
  final calificaciones= await _datosProvider.getCalificaciones();
  //
  //print(calificaciones);
  _calificacionesController.sink.add(calificaciones);
  print('!!!!!!!!');
}


cargarAlumnosPropios()async{
  List<DocumentSnapshot> listaEstudiantes= new List();
  final alumnos= await _datosProvider.getAlumnosPropios();
  //print('elegir alumnos del curso asignado al docente');
  //print(alumnos[0].data['curso']);
 // print(cursoSelectedController.value);
  
  for (var i = 0; i < alumnos.length; i++) {
    if(alumnos[i].data['curso']==cursoSelectedController.value){
      listaEstudiantes.add(alumnos[i]);
    }
  }
  
  _alumnosPropiosController.sink.add(listaEstudiantes);

}

cargarTareaAlumno()async{
   _cargandoController.sink.add(true);
  final tareaAlumno= await _datosProvider.getTareasAlumnos();
     //print(tareaAlumno);
     _tareasAlumnoController.sink.add(tareaAlumno);
     _cargandoController.sink.add(false);
}

cargarMateriasAlumons()async{
  final materiasAlumnos= await _datosProvider.getMateriasAlumnos(); 
  _materiasAlumonsController.sink.add(materiasAlumnos);
}
cargarComentarios()async {
 
  
   List<DocumentSnapshot> listaComentarios= new List();
  
   alumnoSelectedStream.listen((b){     
        alumno_1=b;
         
      });
      
    docenteUserNameStream.listen((c) {
      docente_1=c;
     });    
      
       
   print('alumnos escogido:$alumno_1');
   print('docente de la materia:$docente_1');

  final comentarios= await _datosProvider.getComentarios();
  //print(comentarios[0].data['username']);

   for (var i = 0; i < comentarios.length; i++) {

     if(comentarios[i].data['docente']){
      if(comentarios[i].data['alumno']==alumno_1){
        listaComentarios.add(comentarios[i]);
      }
     }
    if(comentarios[i].data['username']==alumno_1){
       
        listaComentarios.add(comentarios[i]);
      }
   } 
  _comentariosController.sink.add(listaComentarios);
  
}
      
      

          


cargarTareas()async {
       // print('trayendo lo que el docente anteriormente presionó');
       //---------------Escuchando lo que el docente presiona-----------------------------------------
       materiaSelectedStream.listen((b){
        
        
        materiaSelected=b;
        //print ('materia seleccionada: $materiaSelected');  
       
         });
        
        cursoSelectedStream.listen((c){
        
        
        cursoSelected=c;
        //print ('curso seleccionado>>>>>>>>>>>>>>>>>>>>>>>>: $cursoSelected');  
        
         }); 

         
      //---------------------------------------------------------------------------------------------
     
      _cargandoController.sink.add(true);
      final tareas= await _datosProvider.getTareas();
      todasTareas.clear();
      //print('tareas--|--$tareas');
      //print(materiaSelected);
      
      //print(tareas.documents.length);
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
     //print(todasTareas);
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
    actorSelectedController?.close();
    _comentariosController?.close();
    listaTareaElegidaController?.close();
    _tareasController?.close();
    _cargandoController?.close();
    _materiasController?.close();
    _cursosController?.close();
     materiaSelectedController?.close();
     cursoSelectedController?.close();
     contPantallaController?.close();
    _materiasAlumonsController?.close();
    _tareasAlumnoController?.close();
    _alumnosPropiosController?.close();
    boxController?.close();
    alumnoSelectedController?.close();
    docenteUserNameController?.close();
    alumnoIdController?.close();
    _calificacionesController?.close();
    //_articulosCarritoController?.close();
  }


}