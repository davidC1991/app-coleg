import 'package:app_red_social/models/user.dart';
import 'package:app_red_social/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_page.dart';

class EditProfile extends StatefulWidget {
 final String currentUserId;
 final bool docenteb;
 EditProfile({this.currentUserId, this.docenteb});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffolldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController =TextEditingController();
  TextEditingController bioController =TextEditingController();
  bool isLoading= false;
  User user;
  bool _displayNameValid= true;
  bool _bioValid = true;

  @override
  void initState() {
  
    super.initState();
    getUser();
  }
      
  getUser()async {
    setState(() {
      isLoading=true;
    });
    if (widget.docenteb == true){ 
     DocumentSnapshot doc = await  docenteRef.document(currentUser.id)
    .get();
    user= User.fromDocument(doc);
    }else{
      DocumentSnapshot doc = await  usersRef.document(currentUser.id)
    .get();
    user= User.fromDocument(doc);
    }
    
    displayNameController.text= user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading=false;
    });
  } 

   Column buildBioField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top:12.0),
          child: Text('Bio Name',
          style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: 'Actualizar Bio', 
            errorText: _bioValid ? null : 'Bio demasiado corto',

          ),
        )
      ],
    );
  }
  
  Column buildDisplayNameField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top:12.0),
          child: Text('Display Name',
          style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: 'Actualizar Nombre de Usuario', 
            errorText: _displayNameValid ? null : 'Nombre demasiado corto',

          ),
        )
      ],
    );
  }

    updateProfileData(){
      setState(() {
        displayNameController.text.length < 3 || 
        displayNameController.text.isEmpty ? _displayNameValid = false :
        _displayNameValid = true;

        bioController.text.trim().length > 100 ? _bioValid = false: _bioValid =true;
      });

      if (_displayNameValid && _bioValid){
        usersRef.document(currentUser.id).updateData(
         {
           'displayName': displayNameController.text,
           'bio': bioController.text, 
         }
        );
        SnackBar snackBar = SnackBar(content: Text('Perfil Actualizado'));
        _scaffolldKey.currentState.showSnackBar(snackBar);
      }
    }

  logout() async {
    //await googleSignIn.signOut();
    //Navigator.push(context, MaterialPageRoute(builder: (context)=> HomePage()));
    Navigator.of(context).pushNamedAndRemoveUntil('home1', (Route<dynamic> route) => false);
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffolldKey,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              'Edit Perfil',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.done,size: 30.0, color: Colors.green),
                onPressed: ()=> Navigator.pop(context),
              )
            ],
          ),
          body:isLoading 
          ? circularProgress(context)
          : ListView(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                      ),
                    ),  
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          buildDisplayNameField(),
                          buildBioField(),  
                        ],
                      ),
                    ), 
                    RaisedButton(
                      onPressed: updateProfileData,
                      child: Text(
                        'Actualizar Perfil',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ), 
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: FlatButton.icon(
                        onPressed: logout,
                        icon: Icon(Icons.cancel, color: Colors.red),
                        label: Text('Logout',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20.0
                          ),
                        )
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
     );
     }
    
      
}