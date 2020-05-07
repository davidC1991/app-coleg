import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app_red_social/pages/profile_page.dart';

import 'package:app_red_social/pages/create_account.dart';
import 'package:app_red_social/pages/search_page.dart';
import 'package:app_red_social/pages/timeLine_Page.dart';
import 'package:app_red_social/pages/upLoad_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_red_social/models/user.dart';
import 'Notifications_page.dart';
 
final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef=Firestore.instance.collection('users');
final adminRef=Firestore.instance.collection('admin');
final docenteRef=Firestore.instance.collection('docente');
final postsRef=Firestore.instance.collection('posts');
final followersRef=Firestore.instance.collection('followers');
final followingRef=Firestore.instance.collection('following');
final timelineRef=Firestore.instance.collection('timeline');

final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');

final DateTime timestamp= DateTime.now();
User currentUser;
String username;
int cont_auth=0;
bool docente=false;
String curso='primero';

class HomePage extends StatefulWidget {
  String email;
  String id;
  String nombre;

  HomePage({this.email,this.id,this.nombre});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isAuth= false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() { 
    super.initState();
    
    pageController = PageController(
      //initialPage: 2
    );
   /*  googleSignIn.isSignedIn().then((onValue){
      print('onvalue=$onValue');
      if (onValue==true){
        cont_auth++;
        }else{
          cont_auth=0;
        }
    });
    print(cont_auth);
    print('------------>>>username:$username');
    // autentica o escucha cuando un usuario hace login
    
    googleSignIn.onCurrentUserChanged.listen((account){
      controladorSignIn(account);
      //print('entro en  1 no autth');
     },onError: (err){
       // print('Error al ingresar: $err');
      });
      
      // reautenticar cuando la app es abierta otra vez, despues de haber iniciado sesion
      googleSignIn.signInSilently(suppressErrors: false).then((account){
        controladorSignIn(account);
        print('entro en  2 si autth');
        }).catchError((err){
        print('Error al ingresar: $err');
      });
 */
    validarUsuario();
  }
  validarUsuario()async{
    
      print('usuario ingresó con la cuentas: ${widget.email}');
      if (widget.email == 'david.callejasc@hotmail.es'){
        print('Usted es un profesor ---------');
        docente=true;
        await createUser_docente();
      }else if(widget.email == 'test@test.com'){
        print('Usted es un administrador');
        docente=false;
        createUser_admin();
      }
      else {
      docente=false;
      print('===============||===============');
      print('cont_aut:$cont_auth');
      
      createUserInFirestore();
      
      }
      setState(() {
          isAuth= true;
        });
     
  }

createUserInFirestore() async{
       //chequear que el la coleccion de usuario existe en db
       
       //final GoogleSignInAccount user = googleSignIn.currentUser;
       DocumentSnapshot doc = await usersRef.document(widget.id).get();
       //print('doc: ${user.}');
       if(!doc.exists){
       //si el usuario no exite crear un a cuenta
      print('cont_aut:$cont_auth');
      print('==========================');
      //if (cont_auth<2){
        cont_auth=2;
        print(':::::::::::::::::::');
          username = await Navigator.push(context, MaterialPageRoute(
          builder: (context)=> CreateAccount()));
     //     print('ya ingreso el dato---------------------->');
      //} 

        
          print('username:-------------->! $username');
       //conseguir el username para crear un nuevo docuemento de usuario en db
        usersRef.document(widget.id).setData({
          'id': widget.id,
          'username': username,
          'photoUrl': '',
          'email': widget.email,
          'displayName': widget.nombre,
          'bio': '',
          'timestamp': timestamp,
          'docente': false,
          'curso'  : curso,
          'admin'  : false

        });
        //'[matematicas, geografia, naturales, castellano]'
       //make new user their own follower (to include their posts in their timeline)
         /* await followersRef  
          .document(u.id)
          .collection('userFollowers')
          .document(user.id).
          setData({}); */ 
        //volvemos a solicitar los datos de este usuario para almacenarlos y actualizarlos en 
        //las otras paginas

        doc = await usersRef.document(widget.id).get();
       }
       
       currentUser = User.fromDocument(doc);
       print(currentUser);
       print(currentUser.username);
       print('administrador: ${currentUser.docente}');
        
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('keyUsuarioId', currentUser.id);
      SharedPreferences prefs1 = await SharedPreferences.getInstance();
      await prefs1.setString('keyUserName', currentUser.displayName);
     }

    createUser_docente() async{
       //chequear que el la coleccion de usuario existe en db
       
       //final GoogleSignInAccount user = googleSignIn.currentUser;
       DocumentSnapshot doc = await docenteRef.document(widget.id).get();
       //print('doc: ${user.}');
       if(!doc.exists){
       //si el usuario no exite crear un a cuenta
      print('cont_aut:$cont_auth');
      print('==========================');
      //if (cont_auth<2){
        //cont_auth=2;
        print(':::::::::::::::::::');
        username = await Navigator.push(context, MaterialPageRoute(
        builder: (context)=> CreateAccount()));
     //     print('ya ingreso el dato---------------------->');
      //} 

        
          print('username:-------------->! $username');
       //conseguir el username para crear un nuevo docuemento de usuario en db
        docenteRef.document(widget.id).setData({
          'id': widget.id,
          'username': username,
          'photoUrl': '',
          'email': widget.email,
          'displayName': widget.nombre,
          'bio': '',
          'timestamp': timestamp,
          'docente': false,
          'materias': ['matematicas','sociales'],
          'admin'  : false

        });
        //'[matematicas, geografia, naturales, castellano]'
       //make new user their own follower (to include their posts in their timeline)
        /*  await followersRef  
          .document(user.id)
          .collection('userFollowers')
          .document(user.id).
          setData({}); 
         *///volvemos a solicitar los datos de este usuario para almacenarlos y actualizarlos en 
        //las otras paginas

        doc = await docenteRef.document(widget.id).get();
       }
       
       currentUser = User.fromDocument(doc);
       print(currentUser);
       print(currentUser.username);
        print('docente: ${currentUser.docente}');
        
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('keyUsuarioId', currentUser.id);
      SharedPreferences prefs1 = await SharedPreferences.getInstance();
      await prefs1.setString('keyUserName', currentUser.displayName);
     }


    createUser_admin() async {
          //chequear que el la coleccion de usuario existe en db
       //final GoogleSignInAccount user = googleSignIn.currentUser;
       DocumentSnapshot doc = await adminRef.document(widget.id).get();
       //print('doc: ${account}');
       if(!doc.exists){
       //si el usuario no exite crear un a cuenta
      //if (cont_auth<2){
       // cont_auth=2;
         username = await Navigator.push(context, MaterialPageRoute(
          builder: (context)=> CreateAccount()));
          print('username:--------------! $username');
      //}
       //conseguir el username para crear un nuevo docuemento de usuario en db
        adminRef.document(widget.id).setData({
          'id': widget.id,
          'username': username,
          'photoUrl': '',
          'email': widget.email,
          'displayName': widget.nombre,
          'bio': '',
          'timestamp': timestamp,
          'docente': false,
          'admin'  : true

        });
       //make new user their own follower (to include their posts in their timeline)
       // await followersRef  
       //   .document(user.id)
       //   .collection('userFollowers')
       //   .document(user.id).
       //   setData({});
        //volvemos a solicitar los datos de este usuario para almacenarlos y actualizarlos en 
        //las otras paginas

        doc = await adminRef.document(widget.id).get();
       }
       
       currentUser = User.fromDocument(doc);
       print(currentUser);
       print(currentUser.username);
       print('docente: ${currentUser.docente}');
       SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('keyUsuarioId', currentUser.id);

      SharedPreferences prefs1 = await SharedPreferences.getInstance();
      await prefs1.setString('keyUserName', currentUser.displayName);
     }

 @override
  void dispose(){
    pageController.dispose();
    super.dispose();
  }

  logout(){
   cont_auth=0;
    googleSignIn.signOut();
  }

  login(){
    googleSignIn.signIn();
  }
  cuandoPaginaCambie(int pageIndex){
    setState(() {
      this.pageIndex =pageIndex;
    });
   // print('pagina actual: $pageIndex');
  }
  
  onTapChangePage (int pageIndex){
    //pageController.jumpToPage(pageIndex); 
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 400),
      curve: Curves.bounceInOut
    );
  }
  
    
  Widget crearPantallaAutenticado() {
    return Scaffold(
      body: PageView(
        //pageSnapping: false,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
         
         //TimeLinePage(currentUser:currentUser),
         NotificatiosPage(),
         //RaisedButton(onPressed: logout,child: Text('exit ')),
         
         //UpLoadPage(currentUser:currentUser),
         SearchPage(),
         ProfilePage(profileId: currentUser?.id, docenteb: currentUser?.docente, admin: currentUser?.admin, username:currentUser?.username),
        ],
        controller: pageController,
        onPageChanged: cuandoPaginaCambie,
      ),
      bottomNavigationBar: CupertinoTabBar(
       currentIndex: pageIndex,
       onTap: onTapChangePage,
       //backgroundColor: Theme.of(context).accentColor,
       //activeColor: Colors.white,
       //inactiveColor: Colors.blueGrey,
       items: [
        //BottomNavigationBarItem(icon: Icon(Icons.close)),
        //BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
        //BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size:37.0)),
        BottomNavigationBarItem(icon: Icon(Icons.search)),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
       ],
      ),
    );
    //return RaisedButton(onPressed: logout,child: Text('exit '),);
  }
         
         

  Widget crearPantallaInicioSesion(){
     return Scaffold(
      
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor.withOpacity(0.5),
              Theme.of(context).primaryColor.withOpacity(1),
            ]
          ),
        ),
        alignment: Alignment.center,
        //Divider(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
              Text('App College', style: TextStyle(fontSize: 50.0,color: Colors.white, fontFamily: "Signatra")),
              Divider(),
              GestureDetector(
              onTap: login,
              child: Container(
                width: 290.0,
                height: 65.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: AssetImage('assets/googleSingin.png'),
                    fit: BoxFit.cover
                  ),
                ),
              ),
             ), 
          ],
        )
      )
     ); 
                  
                    

  }

  @override
  Widget build(BuildContext context) {
    return crearPantallaAutenticado();
  }
}


