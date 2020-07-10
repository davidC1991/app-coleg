import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

// ignore: must_be_immutable
class ImagenTarea extends StatelessWidget {
  String foto;
  ImagenTarea({Key key, @required this.foto}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
     height: 100, 
     width: 100,
     color: Colors.red,
     child: PhotoView(
      imageProvider: NetworkImage(foto),
    )
    );
  }
}