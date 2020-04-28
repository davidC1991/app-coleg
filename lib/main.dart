import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_red_social/pages/home_page.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  /* Firestore.instance.settings().then(
    (_){
   
    }); */
runApp(MyApp());
}
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      theme: ThemeData(
        primaryColor: Colors.blue[900],
        accentColor: Colors.teal,
      ),
      initialRoute: 'home',
      routes: {
        'home' : (BuildContext context) => HomePage(),
      },
    );
      
  }
}
    