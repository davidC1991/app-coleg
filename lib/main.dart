
import 'package:app_red_social/bloc/provider.dart';
import 'package:app_red_social/pages/subir_tarea.dart';
import 'package:app_red_social/pages/tarea_page.dart';
import 'package:app_red_social/pages/upLoad_page.dart';
import 'package:flutter/material.dart';
import 'package:app_red_social/pages/home_page.dart';


void main() {
  /* Firestore.instance.settings().then(
    (_){
   
    }); */
runApp(MyApp());
}
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      child: MaterialApp(
        title: 'Material App',
        theme: ThemeData(
          primaryColor: Colors.blue[900],
          accentColor: Colors.teal,
        ),
        initialRoute: 'home',
        routes: {
          'home' : (BuildContext context) => HomePage(),
          'subirTarea' : (BuildContext context) => SubirTareaPage(),
          'foto' : (BuildContext context) => UpLoadPage(),
         // 'tareaPage' : (BuildContext context) => TareaPage(),
        },
      ),
    );
      
  }
}
    