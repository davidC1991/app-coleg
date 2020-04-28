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

import 'package:app_red_social/models/user.dart';
import 'Notifications_page.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef=Firestore.instance.collection('users');
final postsRef=Firestore.instance.collection('posts');
final followersRef=Firestore.instance.collection('followers');
final followingRef=Firestore.instance.collection('following');
final timelineRef=Firestore.instance.collection('timeline');

final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');

final DateTime timestamp= DateTime.now();
User currentUser;

class HomePage extends StatefulWidget {
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
    // autentica o escucha cuando un usuario hace login
    googleSignIn.onCurrentUserChanged.listen((account){
      controladorSignIn(account);
      
    },
      onError: (err){
        print('Error al ingresar: $err');
      });
      // reautenticar cuando la app es abierta otra vez, despues de haber iniciado sesion
      googleSignIn.signInSilently(suppressErrors: false).then((account){
        controladorSignIn(account);
      }).catchError((err){
        print('Error al ingresar: $err');
      });

  }
 @override
  void dispose(){
    pageController.dispose();
    super.dispose();
  }

  controladorSignIn(GoogleSignInAccount account)async{
      if(account != null){
       // print('usuario ingresó con la cuentas: $account');
      await createUserInFirestore();
      setState(() {
          isAuth= true;
        });
      }else{
        setState(() {
          isAuth=false;
        });
      }
  }

     createUserInFirestore() async{
       //chequear que el la coleccion de usuario existe en db
       final GoogleSignInAccount user = googleSignIn.currentUser;
       DocumentSnapshot doc = await usersRef.document(user.id).get();
       
       if(!doc.exists){
       //si el usuario no exite crear un a cuenta
        final username = await Navigator.push(context, MaterialPageRoute(
          builder: (context)=> CreateAccount()));
       //conseguir el username para crear un nuevo docuemento de usuario en db
        usersRef.document(user.id).setData({
          'id': user.id,
          'username': username,
          'photoUrl': user.photoUrl,
          'email': user.email,
          'displayName': user.displayName,
          'bio': '',
          'timestamp': timestamp

        });
       //make new user their own follower (to include their posts in their timeline)
        await followersRef  
          .document(user.id)
          .collection('userFollowers')
          .document(user.id).
          setData({});
        //volvemos a solicitar los datos de este usuario para almacenarlos y actualizarlos en 
        //las otras paginas

        doc = await usersRef.document(user.id).get();
       }
       
       currentUser = User.fromDocument(doc);
       print(currentUser);
       print(currentUser.username);
     }


  logout(){
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
        children: <Widget>[
         TimeLinePage(currentUser:currentUser),
         //RaisedButton(onPressed: logout,child: Text('exit ')),
         NotificatiosPage(),
         UpLoadPage(currentUser:currentUser),
         SearchPage(),
         ProfilePage(profileId: currentUser?.id),
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
        BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
        BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size:37.0)),
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
    return isAuth ? crearPantallaAutenticado() : crearPantallaInicioSesion();
  }
}


