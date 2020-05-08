import 'package:app_red_social/Clases%20Auxiliares/crear_Nuevo_Docente.dart';
import 'package:app_red_social/bloc/firebase_bloc.dart';
import 'package:app_red_social/bloc/login_bloc.dart';
import 'package:app_red_social/bloc/provider.dart';
import 'package:app_red_social/pages/edit_profile.dart';
import 'package:app_red_social/pages/home_page.dart';
import 'package:app_red_social/pages/tarea_page.dart';
import 'package:app_red_social/provider/usuario_provider.dart';
import 'package:app_red_social/utils/utils.dart';
//import 'package:app_red_social/widgets/botones_cursos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_red_social/widgets/progress.dart';
import 'package:app_red_social/widgets/header.dart';
import 'package:app_red_social/models/user.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui';


import 'package:flutter_swiper/flutter_swiper.dart';


String materiaSelected;
String idTarea;
int contPantalla=0;

class ProfilePage extends StatefulWidget {
  String profileId ;
  bool docenteb ;
  bool admin;
  String username;
  
  ProfilePage ({ this.profileId, this.docenteb, this.admin, this.username});
 
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController cursoController = TextEditingController();
  TextEditingController materiaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  
  TextEditingController contrasenhaController = TextEditingController();
  String emailDocente;
  bool isFollowing = false;
  final String currentUserId= currentUser?.id;
  String postOrientation= 'grid';
  bool vistaTareaElegida=false;
  bool isLoading= false;
  
  String cursoSelected;
  String a='-';
  List<String> cursos= List();
  List<Widget> lista= List();
  List<DocumentSnapshot> tareas = new List();
  bool checkBoxPrimero=false;
  bool checkBoxSegundo=false;
 bool checkBoxTercero=false;
 bool checkBoxCuarto=false;
 bool checkBoxQuinto=false;
 bool checkBoxKinder=false;
 bool checkBoxPrekinder=false;
 bool checkBoxTransicion=false;
 bool checkBox=false;
 
  bool checkBoxMatematicas=false;
  bool checkBoxCastellano=false;
  bool checkBoxNaturales=false;
  bool checkBoxEscritura=false;
  bool checkBoxIngles=false;
  bool checkBoxLectura=false;
  bool checkBoxGeografia=false;
  bool checkBoxHistoria=false;
  var kontan1 = StringBuffer();

  List cursoss= ['prekinder','kinder','Transicion','primero','segundo','tercero','cuarto','quinto'];
  List materiass= ['matematicas','castellano','naturales','escritura','ingles','lectura','geografia','historia'];
  Map<String,List<String>> materiasYcursosSelected= new Map();
  List<String>materiasSelected=new List();
  String cursosSelected;
  String miembroId= Uuid().v4();
   String mensajeRegistroDocente;
  NuevoDocente nuevoDocente = NuevoDocente();
  bool visibilidadC1=true;

  bool visibilidadC2=true;
  @override
  void initState() { 
    super.initState();
    //pantallaCursos();
    /* getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing(); */
    getAlumnoId();
        //firebaseBloc.cargarPosts();
         
  }

    getAlumnoId(){
     if(widget.docenteb==false && widget.admin==false){
      print('eres un alumno');
      contPantalla=3;
    }else if (widget.docenteb==false && widget.admin==true){
      print('eres un administrador');
      contPantalla=5;
    }   
    }
   
      Column buildCountColumn(String label, int count){
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              count.toString(),
              style: TextStyle(fontSize:22.0, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: EdgeInsets.only(top:4.0),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400
                )
              ),
            ),  
          ],
        );
      }
    
      editProfile(){
        Navigator.push(context, MaterialPageRoute(builder: 
        (context)=> EditProfile(currentUserId : currentUserId, docenteb: widget.docenteb)));
      }
    
      Container buildButton({String text, Function function}){
        return Container(
          height: 35.0,
          //color: Colors.pink.withOpacity(0.3),
          padding: EdgeInsets.only(top:1.0, left:77.0 ),
          child: FlatButton(
          onPressed: function,
          child: Container(
            width: 200.0,
            height: 27.0,
            child: Text(
              text,
              style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFollowing ? Colors.white : Colors.blue,
              border: Border.all(
                color: isFollowing ? Colors.grey : Colors.blue,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          ),
        );
      }
     
      FlatButton tareaButton(){
        return FlatButton(
          onPressed: ()=>  Navigator.pushNamed(context, 'foto'),
          child: Container(
            width: 200.0,
            height: 27.0,
            child: Text(
              'Crear Tarea',
              style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFollowing ? Colors.white : Colors.blue,
              border: Border.all(
                color: isFollowing ? Colors.grey : Colors.blue,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
         
        );
      }
    
      buildProfileButton(){
        //para ver tu perfil y poder editarlo
        bool isProfileOwner = currentUserId == widget.profileId;
        if (isProfileOwner){
          return buildButton(
            text: 'Editar Perfil',
             function: editProfile);
        }else if(isFollowing){
          return buildButton(
            text: 'Unfollow',
            function: handleUnfollowUser
          );
        }else if(!isFollowing){
          return buildButton(
            text: 'Follow',
            function: handleFllowUser
          );
        }

      }

      handleUnfollowUser(){
        setState(() {
          isFollowing =false;
        });
        //remove followers
        followersRef
          .document(widget.profileId)
          .collection('userFollowers')
          .document(currentUserId)
          .get().then((doc){
            if(doc.exists){
              doc.reference.delete();
            }
          });
        //remove following
        followingRef
          .document(currentUserId)
          .collection('userFollowing')
          .document(widget.profileId)
          .get().then((doc){
            if(doc.exists){
              doc.reference.delete();
            }
          });
        //delete activity feed
        activityFeedRef
          .document(widget.profileId)
          .collection('feedItems')
          .document(currentUserId)
          .get().then((doc){
            if(doc.exists){
              doc.reference.delete();
            }
          });   
      }

      handleFllowUser(){
        setState(() {
          isFollowing =true;
        });
        // make auth user follower of that user (update their followers colletions)
        followersRef
          .document(widget.profileId)
          .collection('userFollowers')
          .document(currentUserId)
          .setData({});
        //put that user on your following collection (update your following collection)
        followingRef
          .document(currentUserId)
          .collection('userFollowing')
          .document(widget.profileId)
          .setData({});
        activityFeedRef
          .document(widget.profileId)
          .collection('feedItems')
          .document(currentUserId)
          .setData({
            'type' : 'follow',
            'ownerId' : widget.profileId,
            'username': currentUser.username,
            'userId' : currentUserId,
            'userProfileImg': currentUser.photoUrl,
            'timestamp': timestamp
          });  
      }
    
      buildProfileHeaders(){
        return FutureBuilder(
          future: widget.docenteb?docenteRef.document(widget.profileId).get():widget.admin?adminRef.document(widget.profileId).get():usersRef.document(widget.profileId).get(),
          builder: (context, snapshot){
             if(!snapshot.hasData){
               return circularProgress(context);
             } 
             User user = User.fromDocument(snapshot.data);
             return Padding(
               padding: EdgeInsets.only(left:15.0,right:15.0, top: 10.0, bottom: 0.0),
               child: Column(
                 children: <Widget>[
                   Row(
                     children: <Widget>[
                       CircleAvatar(
                         radius: 40.0,
                         backgroundColor: Colors.grey,
                         child: Text(widget.username[0].toUpperCase()),
                         //backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                       ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                 /* buildCountColumn('posts', postCount),
                                 buildCountColumn('followers', followerCount),
                                 buildCountColumn('following', followingCount), */
                                 buildCountColumn('posts', 2),
                                 buildCountColumn('followers', 2),
                                 buildCountColumn('following', 2), 
                              ],
                            )
                              
                          ],
                        )
                      ),
                         
                     ],
                   ),
                 
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: <Widget>[
                         buildProfileButton(),
                         
                       ],
                     ),
                    
                    
                   Container(
                     //color: Colors.blue.withOpacity(0.3),
                     alignment: Alignment.centerLeft,
                     padding: EdgeInsets.only(top: 0.0),
                     height: 27.0,
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.start,
                       mainAxisSize: MainAxisSize.max,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: <Widget>[
                         Text(
                           user.username,
                           style: TextStyle(
                             fontWeight: FontWeight.bold,
                             fontSize: 16.0
                           ),
                         ),
                         SizedBox(width: 24.0,),
                         
                         contPantalla==2?tareaButton():Container(),
                       ],
                     ),
                   ),
                   Container(
                     //color: Colors.yellow.withOpacity(0.3),
                     alignment:  Alignment.centerLeft,
                     padding: EdgeInsets.only(top:.0),
                     child: Text(
                       user.displayName,
                       style: TextStyle(
                         fontWeight: FontWeight.bold,
                         //fontSize: 16.0
                       ),
                     ),
                   ),
                   Container(
                     //color: Colors.red.withOpacity(0.3),
                     alignment: Alignment.centerLeft,
                     padding: EdgeInsets.only(top: 20),
                     child: Text(
                       user.bio,
                     )
                   ),
                 ],
               ),
             );          
          },
        );
      }
            
 
    setPostOrientation(String postOrientation){
      print('orientacion: $postOrientation');
      setState(() {
        this.postOrientation= postOrientation;
      });
    } 

    buildTogglePostOrientation(){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            onPressed:() { 
              setPostOrientation('grid');
             
              //setState(() {});
              },
            icon: Icon(Icons.grid_on),
            color: postOrientation == 'grid' ? Theme.of(context).accentColor :
            Colors.grey,
          ),
          IconButton(
            onPressed:() { 
              setPostOrientation('list');
              //setState(() {});
              },
            icon: Icon(Icons.list),
            color: postOrientation == 'list' ? Theme.of(context).accentColor :
            Colors.grey,
          )
        ],
      );
    }

//------------------------Scaffold---------------------------------------------

      @override
      Widget build(BuildContext context) {
        final firebaseBloc  = Provider.firebaseBloc(context);  
        final bloc = Provider.of(context); 

        firebaseBloc.cargandoStream.listen((a){isLoading=a;});

        firebaseBloc.materiaSelectedStream.listen((b){materiaSelected=b;});
        
        firebaseBloc.cursoSelectedStream.listen((c){cursoSelected=c;});

        print('contPantalla: $contPantalla');
       
        return Scaffold(
          appBar: header(context, textoTitulo: 'perfil'),
          body: Column(
                children: <Widget>[
                buildProfileHeaders(),
                buildTogglePostOrientation(),
                Expanded(child: Container(child: selectorPantalla(firebaseBloc,context, bloc)))
              ],
          ),
            floatingActionButton:  contPantalla==1||contPantalla==2||contPantalla==4?FloatingActionButton(
                      onPressed:(){
                         switch (contPantalla) {
                           case 0 : {}
                              break;
                           case 1 : {contPantalla=0; setState(() {});}
                              break; 
                           case 2 : {contPantalla=1; setState(() {});}
                            break;
                           case 4 : {contPantalla=3; setState(() {});}
                            break;  
                        }
                      },
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.arrow_back), 
                    ):null         
        );
      }
          

  Widget selectorPantalla(FirebaseBloc firebaseBloc, BuildContext context,LoginBloc bloc){

     switch (contPantalla) {
         case 0 : {return pantallaCursos(firebaseBloc, context);}
            break;
         case 1 : {return pantallaMaterias( firebaseBloc, context);}
            break; 
         case 2 : {return pantallaTareas(firebaseBloc, context);}
            break;
         case 3 : {return pantallaMaterias(firebaseBloc, context);}
            break; 
         case 4 : {return pantallaTareas(firebaseBloc, context);}
            break;
         case 5 : {return pantallaAdmin(firebaseBloc, context);}
            break;
         case 6 : {return firebaseBloc.actorSelectedController.value=='Crear Docente'?pantallaAgregarDocente(firebaseBloc, context,bloc)
                         :firebaseBloc.actorSelectedController.value=='Crear Alumno'?pantallaAgregarAlumno(firebaseBloc, context,bloc)
                         :firebaseBloc.actorSelectedController.value=='Actualizar Docente'?pantallaActualizarDocente(firebaseBloc, context,bloc):null;
                        // firebaseBloc.actorSelectedController.value=='Actualizar Alumno'?pantallaActualizarAlumno(firebaseBloc, context,bloc)

                  }
            break;               
       }
       return Container();
      }

  validarCorreoDocente(BuildContext context,LoginBloc bloc)async{
     String dato;
     emailDocente=emailController.text;
     print('-->$emailDocente');
     dato=await nuevoDocente.registrarCorreo(context, bloc, emailController.text, '123456');
     print(dato);

     if(dato!='EMAIL_EXISTS'){
       mostrarAlerta(context, 'Este correo no esta asociado a ningun docente');
     }else{
       //visibilidadC1=false;
       visibilidadC2=false;
       setState(() {
         
       });
     }

    }
                  
                  
            
   pantallaActualizarDocente(FirebaseBloc firebaseBloc, BuildContext context,LoginBloc bloc){
     print('visibilidadC2:$visibilidadC2');
     return visibilidadC2?Container(
         //alignment: Alignment.center,
         
         //color: Colors.red,
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
             //------------primer widget visible validacion de correo docente------------------
            
               Container(child: 
               Column(
                 children: <Widget>[
                   Text('Ingrese el correo del docente'),
                    SizedBox(height: 10),
                    Container(
                          height: 40,
                          width: 300,
                          child: TextField(
                          controller: emailController,
                          decoration:inputD('Email docente')
                        ),
                      ),
                    FlatButton(
                         onPressed: (){
                        validarCorreoDocente(context, bloc);
                           },
                     
            child: Container(
                width: 200.0,
                height: 27.0,
                child: Text(
                  'Validar',
                  style: TextStyle(
                    color: isFollowing ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isFollowing ? Colors.white : Colors.blue,
                  border: Border.all(
                    color: isFollowing ? Colors.grey : Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                   ),
                  ),
                 ),  
                ],
               )
              ),
           //-----------------------------------------------------------------------------------------------
            
           ],
         ),
       //---------------------formulario de actualizacion docente despues de validacion -----------------
        
     ):Container(
          child: ListView(
            children: <Widget>[
              pantallaAgregarDocente(firebaseBloc, context, bloc),
            ],
          ),
        );
              

            //------------------------------------------------------------------------------------------------ 
   }
  
  pantallaAgregarDocente(FirebaseBloc firebaseBloc, BuildContext context,LoginBloc bloc){
    
    
    return SingleChildScrollView(
      child: Column(
            children: <Widget>[

               ExpansionTileCard(
                leading: CircleAvatar(child: Text('curso')),
                title: Text('Eliga el curso que desea asignar'),
                subtitle: Text('presione para ver mas'),
                children: <Widget>[
                   /* Divider(
                    thickness: 1.0,
                    height: 1.0,
                  ), */
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child:Container(
                        child: Column(
                          children: <Widget>[
                            seleccionCurso(cursoss,context),
                            
                          ],
                        ),
                      ),
                      )),
                ],

                ),   
              ExpansionTileCard(
                leading: CircleAvatar(child: Text('Materias')),
                title: Text('Eliga la materia que desea asignar'),
                subtitle: Text('presione para ver mas'),
                children: <Widget>[
                   
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child:Container(
                        child: Column(
                          children: <Widget>[
                            seleccionMateria(materiass,context),
                            
                          ],
                        ),
                      ),
                      )),
                ],

                ),
              firebaseBloc.actorSelectedController.value=='Crear Docente'?ListTile(
                //leading: botonTextoTarea('Tema'),
                title: Container(
                  height: 30.0,
                  width: 250.0,
                  child: TextField(
                    controller: nombreController,
                    decoration:inputD('Escriba el nombre completo del docente')
                  ),
                ),
              ):Container(),
              
              ListTile(
                //leading: botonTextoTarea('Tema'),
                title: Container(
                  height: 30.0,
                  width: 250.0,
                  child: TextField(
                    controller: cursoController,
                    decoration:inputD('Cursos asignados')
                  ),
                ),
              ),
              ListTile(
                //leading: botonTextoTarea('Tema'),
                title: Container(
                  height: 30.0,
                  width: 250.0,
                  child: TextField(
                    controller: materiaController,
                    decoration:inputD('Materias asignadas')
                  ),
                ),
              ),
              firebaseBloc.actorSelectedController.value=='Crear Docente'?ListTile(
                //leading: botonTextoTarea('Tema'),
                title: Container(
                  height: 30.0,
                  width: 250.0,
                  child: TextField(
                    controller: emailController,
                    decoration:inputD('Escriba el email de ingreso')
                  ),
                ),
              ):Container(),

              firebaseBloc.actorSelectedController.value=='Crear Docente'?ListTile(
                //leading: botonTextoTarea('Tema'),
                title: Container(
                  height: 30.0,
                  width: 250.0,
                  child: TextField(
                    controller: contrasenhaController,
                    decoration:inputD('Escriba la contraseña de ingreso')
                  ),
                ),
              ):Container(),
              botonEnviar(firebaseBloc,context,bloc),
            ],
          
      ),
    );
  }

  validarRegistro(FirebaseBloc firebaseBloc, LoginBloc bloc)async{
     
       materiasYcursosSelected.addAll({cursosSelected:materiasSelected});
            print('materiasYcursosSelected:$materiasYcursosSelected');
            print('cursosSelected:$cursosSelected');
            print('emailController.text:${emailController.text}');
            print('emailDocente:$emailDocente');
            print('contrasenhaController.text:${contrasenhaController.text}');
            
            if((firebaseBloc.actorSelectedController.value=='Crear Docente'
              &&materiasYcursosSelected.isNotEmpty==true
              &&cursosSelected.isNotEmpty==true
              &&emailController.text.isNotEmpty==true
              &&contrasenhaController.text.isNotEmpty==true)
              ||(firebaseBloc.actorSelectedController.value=='Actualizar Docente'
              &&materiasYcursosSelected.isNotEmpty==true
              &&cursosSelected.isNotEmpty==true)){
              
              print('campos llenos');
              firebaseBloc.actorSelectedController.value=='Crear Docente'?mensajeRegistroDocente=await nuevoDocente.enviarRegistro(context,
                                                                                                                                   bloc,
                                                                                                                                   materiasYcursosSelected,
                                                                                                                                   cursosSelected,
                                                                                                                                   materiasSelected,
                                                                                                                                   emailController.text.toLowerCase(),
                                                                                                                                   contrasenhaController.text,
                                                                                                                                   nombreController.text.toLowerCase())
                                                                         :mensajeRegistroDocente=await nuevoDocente.actualizarRegistroDocente(context,
                                                                                                                                   bloc,
                                                                                                                                   materiasYcursosSelected,
                                                                                                                                   cursosSelected,
                                                                                                                                   materiasSelected,
                                                                                                                                   emailController.text.toLowerCase());
              print(mensajeRegistroDocente);
              emailController.clear();
              nombreController.clear();
              cursoController.clear();
              materiaController.clear(); 
              contrasenhaController.clear();

               checkBoxPrekinder=false;
               checkBoxKinder=false;
               checkBoxTransicion=false;
               checkBoxPrimero=false;
               checkBoxSegundo=false;
               checkBoxTercero=false;
               checkBoxCuarto=false;
               checkBoxQuinto =false;
               checkBoxMatematicas=false;
               checkBoxCastellano=false;
               checkBoxNaturales=false;
               checkBoxEscritura=false;
               checkBoxIngles=false;
               checkBoxLectura=false;
               checkBoxGeografia=false;
               checkBoxHistoria=false;
               materiasYcursosSelected.clear();
               cursosSelected='';  
               materiasSelected.clear();   
               mostrarAlerta(context, 'Registro exitoso');                    
               visibilidadC2=true;
               setState(() {});
            }else{
              print('algun campo vacio');
               mostrarAlerta(context, 'Llene todos los campos');
            }
           
  }
 
  botonEnviar(FirebaseBloc firebaseBloc,BuildContext context, LoginBloc bloc){
    
    return FlatButton(
          onPressed: (){
            validarRegistro(firebaseBloc,bloc);
             },
          child: Container(
            width: 200.0,
            height: 27.0,
            child: Text(
              'Guardar',
              style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFollowing ? Colors.white : Colors.blue,
              border: Border.all(
                color: isFollowing ? Colors.grey : Colors.blue,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
         
        );
  }

 Widget seleccionCurso(List cursos, BuildContext context){
   
    return SingleChildScrollView(
     // physics: ScrollPhysics(),
      child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cursos.length,
            itemBuilder: (BuildContext context, int i){
              
              return SingleChildScrollView(
                child: ListTile(
                  leading: CircleAvatar(child: Text(cursos[i].toString()[0].toUpperCase()),backgroundColor: Colors.red.withOpacity(0.5),),
                  title: Text(cursos[i]),
                  trailing: Checkbox(
                  onChanged:(bool value) {
                        print(value);
                           switch (i) {
                             case 0 : {
                               checkBoxPrekinder=value;
                               if (value){
                                 cursosSelected= cursos[i];
                               }else{cursosSelected='';}
                                
                               }
                                break;
                             case 1 : {
                               checkBoxKinder=value;
                               if (value){
                                 cursosSelected= cursos[i];
                               }else{cursosSelected='';}
                                
                               }
                                break; 
                             case 2 : {
                               checkBoxTransicion=value;
                               if (value){
                                 cursosSelected= cursos[i];
                               }else{cursosSelected='';}
                               }
                                break;
                             case 3 : {
                               checkBoxPrimero=value;
                               if (value){
                                 cursosSelected= cursos[i];
                               }else{cursosSelected='';}
                               }
                                break; 
                             case 4 : {
                               checkBoxSegundo=value;
                              if (value){
                                 cursosSelected= cursos[i];
                               }else{cursosSelected='';}
                               }
                                break;
                             case 5 : {
                               checkBoxTercero=value;
                               if (value){
                                 cursosSelected= cursos[i];
                               }else{cursosSelected='';}
                               }
                                break;
                             case 6 : {
                               checkBoxCuarto =value;
                               if (value){
                                 cursosSelected= cursos[i];
                               }else{cursosSelected='';}
                               }
                                break;               
                             case 7 : {
                               checkBoxQuinto =value;
                               if (value){
                                 cursosSelected= cursos[i];
                               }else{cursosSelected='';}
                               }
                                break;   
                            }
                       
                           
                         cursoController.text=cursosSelected;
                         print(cursosSelected);
                         setState((){ });
                       //
                      },

                      value: i==0?checkBoxPrekinder
                            :i==1?checkBoxKinder
                            :i==2?checkBoxTransicion
                            :i==3?checkBoxPrimero
                            :i==4?checkBoxSegundo
                            :i==5?checkBoxTercero
                            :i==6?checkBoxCuarto
                            :i==7?checkBoxQuinto
                            :null,
                    ),
                  ),
                );
               }
             ),
           ); 
          }
              
        
   
 Widget seleccionMateria(List materias, BuildContext context){
   
    return SingleChildScrollView(
     // physics: ScrollPhysics(),
      child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: materias.length,
            itemBuilder: (BuildContext context, int i){
              
              return SingleChildScrollView(
                child: ListTile(
                  leading: CircleAvatar(child: Text(materias[i].toString()[0].toUpperCase()),backgroundColor: Colors.red.withOpacity(0.5),),
                  title: Text(materias[i]),
                  trailing: Checkbox(
                  onChanged:(bool value) {
                  
                        print(value);
                           switch (i) {
                             case 0 : {
                               checkBoxMatematicas=value;
                               if(value){
                                   materiasSelected.add(materias[i]);
                                   //print(cursosSelected);
                                    }else{materiasSelected.remove(materias[i]);}
                               }
                                break;
                             case 1 : {
                               checkBoxCastellano=value;
                                if(value){
                                   materiasSelected.add(materias[i]);
                                   //print(cursosSelected);
                                    }else{materiasSelected.remove(materias[i]);}
                               }
                                break; 
                             case 2 : {
                               checkBoxNaturales=value;
                                if(value){
                                   materiasSelected.add(materias[i]);
                                   //print(cursosSelected);
                                    }else{materiasSelected.remove(materias[i]);}
                               }
                                break;
                             case 3 : {
                               checkBoxEscritura=value;
                                if(value){
                                   materiasSelected.add(materias[i]);
                                   //print(cursosSelected);
                                    }else{materiasSelected.remove(materias[i]);}
                               }
                                break; 
                             case 4 : {
                               checkBoxIngles=value;
                                if(value){
                                   materiasSelected.add(materias[i]);
                                   //print(cursosSelected);
                                    }else{materiasSelected.remove(materias[i]);}
                               }
                                break;
                             case 5 : {
                               checkBoxLectura=value;
                                if(value){
                                   materiasSelected.add(materias[i]);
                                   //print(cursosSelected);
                                    }else{materiasSelected.remove(materias[i]);}
                               }
                                break;
                             case 6 : {
                               checkBoxGeografia=value;
                                if(value){
                                   materiasSelected.add(materias[i]);
                                   //print(cursosSelected);
                                    }else{materiasSelected.remove(materias[i]);}
                               }
                                break;               
                             case 7 : {
                               checkBoxHistoria =value;
                                if(value){
                                   materiasSelected.add(materias[i]);
                                   //print(cursosSelected);
                                    }else{materiasSelected.remove(materias[i]);}
                               }
                                break;   
                            }
                       
                      
                           materiasSelected.forEach((item){
                           kontan1.write('$item-');   
                         });
                         materiaController.text=kontan1.toString();
                         kontan1.clear();
                         
                         
                         print('materias seleccionadas:${materiaController.text}');           
                       setState((){ });
                      },

                      value: i==0?checkBoxMatematicas
                            :i==1?checkBoxCastellano
                            :i==2?checkBoxNaturales
                            :i==3?checkBoxEscritura
                            :i==4?checkBoxIngles
                            :i==5?checkBoxLectura
                            :i==6?checkBoxGeografia
                            :i==7?checkBoxHistoria
                            :null,
                    ),
                  ),
                );
               }
              ),
            ); 
           }
                 
        
    
                
    
    
  InputDecoration inputD(String texto){
  return InputDecoration(
    border: OutlineInputBorder(),
    labelText: texto[0].toUpperCase()+texto.substring(1),
    //hintText: texto,
    hoverColor: Colors.red, 
  );
}

   pantallaAgregarAlumno(FirebaseBloc firebaseBloc, BuildContext context,LoginBloc bloc){
    return Container(child: Text(firebaseBloc.actorSelectedController.value));
  }

  Widget pantallaAdmin(FirebaseBloc firebaseBloc, BuildContext context){
    List actores= ['Crear Docente','Crear Alumno','Actualizar Alumno','Actualizar Docente','Eliminar Alumno','Eliminar Docente'];
    List colores=[Colors.brown.shade300, Colors.red.shade300,Colors.brown.shade300, Colors.red.shade300,Colors.brown.shade300, Colors.red.shade300];
    return Container(
      height: 200.0,
      width: double.infinity,
      child: Swiper(
        layout: SwiperLayout.STACK,
        itemWidth: 250.0,
        itemHeight: 350.0,
        itemBuilder: (BuildContext context , int i){
          return _crearBotonRedondeado(colores[i], Icons.border_all, actores[i], context, firebaseBloc); 
        },
        itemCount: 6,
        pagination: new SwiperPagination(),
        //control: new SwiperControl(),
      ),
    );
  }      

  Widget  pantallaTareas(FirebaseBloc firebaseBloc,BuildContext context){
    
    if(contPantalla==2){
      firebaseBloc.cargarTareas();
      return streamBuilderTareasDocente(firebaseBloc, context);
    }else if(contPantalla==4){
      firebaseBloc.cargarTareaAlumno();
      return streamBuilderTareasDocente(firebaseBloc, context);
      //return streamBuilderTareasAlumnos(firebaseBloc, context);
    }
      
    
  return Container();
} 

streamBuilderTareasDocente(FirebaseBloc firebaseBloc,BuildContext context){
  
   return StreamBuilder<List<DocumentSnapshot>>(
    stream: firebaseBloc.tareasStream,
    builder: (context, snapshot){
      if(snapshot.hasData){
       //tareas.clear();
       tareas =snapshot.data;
       //print(tareas[0].data['mediaUrl']);

         if(postOrientation=='grid'){
         
             return _dibujarCuadriculasReportes(context, tareas, firebaseBloc);
          }else if (postOrientation=='list'){
            
            return ListView.builder(
            shrinkWrap: true,
            itemCount:tareas.length ,
            itemBuilder: (context, i){
              return  imagen_list(context, tareas, i, firebaseBloc);
           });
          } 
        //return Container();
        
      }else{
        return CircularProgressIndicator();
      }
    },
  ); 
}

streamBuilderTareasAlumnos(FirebaseBloc firebaseBloc,BuildContext context){
  
   return StreamBuilder<List<DocumentSnapshot>>(
    stream: firebaseBloc.tareasStream,
    builder: (context, snapshot){
      if(snapshot.hasData){
       //tareas.clear();
       tareas =snapshot.data;
       // print(tareas);

        if(postOrientation=='grid'){
         
             return _dibujarCuadriculasReportes(context, tareas, firebaseBloc);
          }else if (postOrientation=='list'){
            
            return ListView.builder(
            shrinkWrap: true,
            itemCount:tareas.length ,
            itemBuilder: (context, i){
              return  imagen_list(context, tareas, i, firebaseBloc);
           });
          }
        //return Container();
        
      }else{
        return CircularProgressIndicator();
      }
    },
  ); 
}
  
  Widget  pantallaCursos(FirebaseBloc firebaseBloc,BuildContext context){

  
  firebaseBloc.cargarCursos();

  return StreamBuilder(
    stream: firebaseBloc.cursosStream,
    builder: (context, snapshot){
      if(snapshot.hasData){
        cursos=snapshot.data;
        print(snapshot.data);
        //return Container();
        return botones(cursos,context,firebaseBloc);
      }else{
        return CircularProgressIndicator();
      }
    },
  );

}
  
  Widget  pantallaMaterias(FirebaseBloc firebaseBloc,BuildContext context ){
 
  if (contPantalla==1){
      firebaseBloc.cargarMaterias();
      return streamBuilderDocentesMaterias(firebaseBloc, context);
    }else if(contPantalla==3){
      print('----');
      firebaseBloc.cargarMateriasAlumons();
      return streamBuilderAlumnosMaterias(firebaseBloc, context);
    }
  }

 streamBuilderDocentesMaterias(FirebaseBloc firebaseBloc,BuildContext context){
   return StreamBuilder<Map<String,Object>>(
    stream: firebaseBloc.materiasStream,
    builder: (context, snapshot){
      print('---------------');
      if(snapshot.data!=null){
        print(snapshot.data);
        print('curso seleccionado:$cursoSelected');
        final materias=snapshot.data[cursoSelected];
        if(materias==null){return Container();}//Este docente aun no tiene esta materia asiganada a este curso
        print(materias);
        //cursoSelected
        return botones(materias, context,firebaseBloc);
      //return Container();
      }else{
        return CircularProgressIndicator();
      }
    },
  );
 }

 streamBuilderAlumnosMaterias(FirebaseBloc firebaseBloc,BuildContext context){
   return StreamBuilder<List<String>>(
    stream: firebaseBloc.materiasAlumnosStream,
    builder: (context, snapshot){
      print('---------------');
      if(snapshot.data!=null){
      
        //print(snapshot.data);
        final materias=snapshot.data;
        if(materias==null){return Container();}//Este alumno aun no tiene esta materia 
        print(materias);
        //return Container();
        return botones(materias, context,firebaseBloc);
      //return Container();
      }else{
        return CircularProgressIndicator();
      }
    },
  );
 }
 
  botones(List boton, BuildContext context, FirebaseBloc firebaseBloc){
    

  return GridView.builder(
      itemCount: boton.length,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (BuildContext context, int i){
         return _crearBotonRedondeado(Colors.blue, Icons.border_all, boton[i],context,firebaseBloc);
        },
       );

  }

  Widget _crearBotonRedondeado(Color color, IconData icono, String texto,BuildContext context,FirebaseBloc firebaseBloc){
    return GestureDetector(
      onTap: (){
        if (contPantalla==0){   //pantalla cursos
          firebaseBloc.cursoSelectedController.sink.add(texto);
        }else if(contPantalla==1){
          firebaseBloc.materiaSelectedController.sink.add(texto);
        }else if(contPantalla==3){
          firebaseBloc.materiaSelectedController.sink.add(texto);
        }else if(contPantalla==5){
          firebaseBloc.actorSelectedController.sink.add(texto);
        }
          
        setState(() {
          
        });  
        contPantalla++;
        firebaseBloc.contPantallaController.sink.add(contPantalla);
        //print('Profesor prresionó el boton : $texto');
        print('ContPantalla : $contPantalla');
             
      },
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX:0.1,sigmaY: 0.0),
          child: Container(
          height: 150.0,
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            //color: Color.fromRGBO(62,66,107,0.7).withOpacity(0.2),
            color: contPantalla==5?Colors.teal.shade600:Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0)
             ),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: <Widget>[
                CircleAvatar(
                  backgroundColor:color,
                  radius: 35.0,
                  child: Icon(icono, color: Colors.white, size: 50.0),
                ),
              Text(texto, style: TextStyle(color: Colors.white,fontSize:15.0, fontWeight: FontWeight.bold)),  
          
             ],
           ),  
        ),
      ),
    );
  }

                                
  Widget _tablaDeMaterias(BuildContext context, final ds, int i, FirebaseBloc firebaseBloc){
   return Column(
    children: <Widget>[
     _dibujarCuadriculasReportes(context, ds, firebaseBloc),
   ],
  );
}                      
                       
  tituloMateria(){
                       
   return Container(
     height: 30.0,
     width: 300.0,
     color: Colors.blue,
     child: Text('Castellano'),
   );
 }                       
                    
  _dibujarCuadriculasReportes(BuildContext context, List<DocumentSnapshot> tareas, FirebaseBloc firebaseBloc){

  
  return GridView.builder(
      itemCount: tareas.length,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (BuildContext context, int i){
         return imagen(context, tareas, i, firebaseBloc);
          },);
       }

  Widget imagen_list(BuildContext context, List<DocumentSnapshot> tareas, int i, FirebaseBloc firebaseBloc){
   
   return Container(
    height: 300.0,
    //width: 50.0,
    padding: EdgeInsets.all(10.0),
    child: GestureDetector(
      onTap: (){
          //firebaseBloc.listaTareaElegidaController.sink.add(false);
          vistaTareaElegida=false;
          idTarea=tareas[i].data['postId'];
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TareaPage(tareas: tareas, tarea: tareas[i],vistaTareaElegida:vistaTareaElegida)));
          },
      child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
              //    child: Image.network(product.documents[i].data['mediaUrl'])
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FadeInImage(
                    image: NetworkImage(tareas[i].data['mediaUrl']),
                    placeholder: AssetImage('assets/cargando.gif'),
                    height: 300.0,
                    //width: 100.0,
                    fit: BoxFit.cover, 
            ),
           ),
          ),
    ), 
  );
}
       
            

  Widget imagen(BuildContext context, List<DocumentSnapshot> tareas, int i, FirebaseBloc firebaseBloc){
   
      return Padding(
        padding: const EdgeInsets.all(1.0),
        child: GestureDetector(
          onTap: (){
          //firebaseBloc.listaTareaElegidaController.sink.add(true);
          idTarea=tareas[i].data['postId'];
          vistaTareaElegida=true;
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TareaPage(tareas: tareas, tarea: tareas[i],vistaTareaElegida:vistaTareaElegida)));
          },
          //Navigator.pushNamed(context, 'tareaPage', tarea: tareas[i]),
          child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
              //    child: Image.network(product.documents[i].data['mediaUrl'])
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FadeInImage(
                    image: NetworkImage(tareas[i].data['mediaUrl']),
                    placeholder: AssetImage('assets/cargando.gif'),
                    height: 70.0,
                    width: 100.0,
                    fit: BoxFit.cover, 
            ),
           ),
          ),
        ),
      );
    }
              
            


}




