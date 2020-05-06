
import 'dart:io';
import 'package:app_red_social/bloc/firebase_bloc.dart';
import 'package:app_red_social/bloc/provider.dart';
import 'package:app_red_social/pages/home_page.dart';
import 'package:app_red_social/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:app_red_social/models/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';


class UpLoadPage extends StatefulWidget {
  final User currentUser;

  const UpLoadPage({this.currentUser});

  //UploadPage({this.currentUser});
  
  @override
  _UpLoadPageState createState() => _UpLoadPageState();
}

//class _UpLoadPageState extends State<UpLoadPage> with AutomaticKeepAliveClientMixin<UpLoadPage> {
 class _UpLoadPageState extends State<UpLoadPage>  {
 TextEditingController locationController= TextEditingController(); 
 TextEditingController captionController= TextEditingController(); 
 TextEditingController tituloTemaController= TextEditingController(); 
 TextEditingController fechaLimiteController= TextEditingController(); 
 TextEditingController actividadController= TextEditingController(); 
 //FirebaseBloc firebaseBloc = FirebaseBloc();

 File file ;
 bool isUploading= false;
 String postId= Uuid().v4();
 bool isLoading;
 String cursoSelected;
 String materiaSelected;
 String usuarioId;
 String userName;
 bool tareaCargada=false;
 
 @override
 void initState() { 
   super.initState();
  getUserId();  
 }

 getUserId()async{

   SharedPreferences prefs = await SharedPreferences.getInstance();
   usuarioId= prefs.getString('keyUsuarioId'); 

   SharedPreferences prefs1 = await SharedPreferences.getInstance();
   userName= prefs1.getString('keyUserName'); 
 }

 handleTakePhoto() async {
    Navigator.pop(context);
      File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState((){
      this.file = file;
    });
        
  }  

  handleChooseFromGallery()async{
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
     setState((){
      this.file = file;
    });
        
  }
  
  selectImage(parentContext){
    return showDialog(
      context: parentContext,
      builder: (context){
        return SimpleDialog(
          title: Text('Crear Post'),
          children: <Widget>[
            SimpleDialogOption(
               child: Text('Foto de Camara'),
               onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
               child: Text('Imagen de Galeria'),
               onPressed: handleChooseFromGallery,
            ),
            SimpleDialogOption(
               child: Text('Cancelar'),
               onPressed: ()=> Navigator.pop(context),
            ),
          ],
        );
      }

    );
  }
  
  Container buildSplashScreen(){
    return Container(
      //color: Colors.red,
      color: Theme.of(context).accentColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left:45.0),
            child: SvgPicture.asset('assets/subir.svg', height: 250.0),
          ),
          //Card(child: Image.asset('assets/subir.png')),
          
          Padding(
            padding: EdgeInsets.only(top:10.0 ),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text("Subir Imagen", style: TextStyle(color: Colors.white, fontSize: 22.0 ),
              ),
              color: Colors.deepOrange,
              onPressed: ()=> selectImage(context),
            ),
          )
        ],
      ),
    ); 
  }

  clearImage(){
    setState(() {
      file= null;
    });
  }

  compressImage()async{
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile= File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile,quality: 85));
    setState(() {
      file=compressedImageFile;
    });
    
  }

 Future<String> uploadImage(imageFile) async{
   StorageUploadTask uploadTask = storageRef.child('post_$postId.jpg').putFile(imageFile);
   StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
   String downloadUrl = await storageSnap.ref.getDownloadURL();
   return downloadUrl;
 }

 createPostInFirestore({mediaUrl,tituloTema,fecha, description}){
   
       
    postsRef
    .document(usuarioId)
    .collection('userPosts')
    .document(postId)
    .setData({

        'postId'      : postId,
        'nombreDoc'   : userName,
        'materia'     : materiaSelected,
        'curso'       : cursoSelected, 
        'tituloTema'  : tituloTema,
        'mediaUrl'    : mediaUrl,
        'descripcion' : description,
        'calificacion': '5.0',
        'revisado'    : true,
        'fechaLimite' : fecha,
        'timestamp'   : timestamp,
        'likes'       : {},
        
         
    }
    );
    tituloTemaController.clear();
    fechaLimiteController.clear();
    actividadController.clear();
    locationController.clear();

    setState(() {
      file=null;
      isUploading=false;
      postId= Uuid().v4();
      Navigator.pop(context);
    });
 }

  handleSubmit() async{
    setState(() {
      isUploading= true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      tituloTema: tituloTemaController.text,
      fecha: fechaLimiteController.text,
      description: actividadController.text,
    );
    }

 buildUploadForm(){
  
   return Scaffold(
     appBar: AppBar(
       backgroundColor:Colors.white70,
       leading: IconButton(
         icon: Icon(Icons.arrow_back, color: Colors.black),
         onPressed: clearImage
       ),
       title: Text('Caption Post', style: TextStyle(color: Colors.black)),
       actions: <Widget>[
         FlatButton(
           child: Text('Post', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 20.0 )),
           onPressed: isUploading ? null : () => handleSubmit() , 
         ),
       ],
     ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress(context) : Text(''),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width*0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file),
                    )
                  )
                ), 
              ),
            ),
          ),
          Padding(padding:EdgeInsets.only(top:10.0)),
          ListTile(
            //leading: botonTextoTarea('Curso'),
            title: Container(
              color: Colors.grey.withOpacity(0.2),
              height: 30.0,
              width: 250.0,
              child: TextField(
                //controller: locationController,
                decoration: inputD(cursoSelected),
              ),
            ),
          ),
          //Divider(),
          ListTile(
            //contentPadding: EdgeInsets.only(bottom:3.0),
            //leading: botonTextoTarea('Materia'),
            title: Container(
              color: Colors.grey.withOpacity(0.2),
              height: 30.0,
              width: 250.0,
              child: FocusScope(
              node: FocusScopeNode(),  
              child: TextFormField(
                //controller: locationController,
                //textCapitalization: TextCapitalization.sentences,
                decoration:inputD(materiaSelected),
              ),
             ),
            ),
          ),
          //Divider(),
          ListTile(
            //leading: botonTextoTarea('Tema'),
            title: Container(
              height: 30.0,
              width: 250.0,
              child: TextField(
                controller: tituloTemaController,
                decoration:inputD('Escriba el titulo del tema')
              ),
            ),
          ),
          
          //Divider(),
          ListTile(
            //leading: botonTextoTarea('Fecha'),
            title: Container(
              height: 30.0,
              width: 250.0,
              child: TextField(
                controller: fechaLimiteController,
                decoration:inputD('Escriba la fecha limite de entrega')
                
              ),
            ),
          ),
           ListTile(
           /*  leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ), */
            title: Container(
              width: 100.0,
              child: TextFormField(
                maxLines: 3,
                controller: actividadController,
                decoration: inputD('Describa su Actividad')
              ),
            ),
          ),
          Divider(),
          Container(
            width:  200.0,
            height:  100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text(
                'Usar actual localización',
                 style: TextStyle(color: Colors.white)
              ),
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(30.0),
             ), 
             color: Colors.blue,
             onPressed: getUserLocation,
             icon: Icon(Icons.my_location, color: Colors.white,), 
            ), 

          ),
        ],
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

Widget botonTextoTarea(String text){
  return Container(
    height: 30.0,
    width: 70.0,
    alignment: Alignment.center,
    decoration: BoxDecoration(
            //color: Color.fromRGBO(62,66,107,0.7).withOpacity(0.2),
            color: Colors.blue.withOpacity(1),
            borderRadius: BorderRadius.circular(5.0)
             ),
    child: Text(text, style: TextStyle(color: Colors.white)),         
  );
}

 getUserLocation() async{
  Position position = await Geolocator().getCurrentPosition(
   desiredAccuracy: LocationAccuracy.high);
  List<Placemark> placemarks = await Geolocator()
  .placemarkFromCoordinates(position.latitude, position.longitude);

  Placemark placemark = placemarks[0]; 
  String completeAddress= '${placemark.subThoroughfare} ${placemark.thoroughfare},${placemark.subLocality}${placemark.locality},${placemark.subAdministrativeArea} ${placemark.administrativeArea}, ${placemark.postalCode} ${placemark.postalCode}, ${placemark.country}';

  print(completeAddress);
  String formattedAddress= '${placemark.locality},${placemark.country}';
  locationController.text= formattedAddress;
 }

  //bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
     final firebaseBloc  = Provider.firebaseBloc(context); 
    firebaseBloc.materiaSelectedStream.listen((b){
        print('====================================');
        //setState(() {
        materiaSelected=b;
        print ('materia seleccionada---------------->: $materiaSelected');  
        //});
         });
        
        firebaseBloc.cursoSelectedStream.listen((c){
        
        //setState(() {
        cursoSelected=c;
        print ('curso seleccionado--------------------->: $cursoSelected');  
        //});
         });
    //super.build(context);
     return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
  

   
 
  