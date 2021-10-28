import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhoto extends StatelessWidget {

  final String url;

  const FullPhoto({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Full Image"), backgroundColor: Colors.lightBlueAccent, centerTitle: true,),
      body: Container(
        child: PhotoView(imageProvider: NetworkImage(url),),
      ),
    );
  }
}
