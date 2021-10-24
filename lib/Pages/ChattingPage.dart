import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Widgets/FullImageWidget.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String recieverId;
  final String recieverPhoto;
  final String recieverName;

  const Chat({Key key, this.recieverId, this.recieverPhoto, this.recieverName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Hero(
              tag: "avatar",
              child: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: CachedNetworkImageProvider(recieverPhoto),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.lightBlueAccent,
        title: Text(
          recieverName,
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(receiverId: recieverId, receiverPhoto: recieverPhoto),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverPhoto;

  const ChatScreen({Key key, this.receiverId, this.receiverPhoto})
      : super(key: key);

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {

  TextEditingController messageController = TextEditingController();
  FocusNode focusNode = FocusNode();

  bool isLoading;
  bool isDisplaySticker;

  @override
  void initState() {

    isLoading = false;
    isDisplaySticker = false;

    focusNode.addListener(onFocuseChange);
    super.initState();
  }


  onFocuseChange(){
    if(focusNode.hasFocus){
      setState(() {
        isDisplaySticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Stack(
        children: [
          Column(
            children: [

              createListMessage(),
              isDisplaySticker ? createSticker() : Container(),
              createInput(),
            ],
          ),
          createProgress(),
        ],
      ),
    );
  }


  createSticker() {
    return Container(
      width: double.infinity,
      height: 150.0,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(onPressed: (){}, child: Image.asset("images/mimi1.gif", width: 50.0, height: 50.0, fit: BoxFit.cover,), ),
              FlatButton(onPressed: (){}, child: Image.asset("images/mimi2.gif", width: 50.0, height: 50.0, fit: BoxFit.cover,), ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(onPressed: (){}, child: Image.asset("images/mimi3.gif", width: 50.0, height: 50.0, fit: BoxFit.cover,), ),
              FlatButton(onPressed: (){}, child: Image.asset("images/mimi4.gif", width: 50.0, height: 50.0, fit: BoxFit.cover,), ),
            ],
          ),
        ],
      ),
    );
  }

  createInput() {
    return Container(
      child: Row(
        children: [
          // pick image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.0),
              child: IconButton(
                icon: Icon(Icons.image),
                color: Colors.lightBlueAccent,
                onPressed: () {},
              ),
            ),
            color: Colors.white,
          ),

          //  emoji
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.0),
              child: IconButton(
                icon: Icon(Icons.face),
                color: Colors.lightBlueAccent,
                onPressed: () {
                  focusNode.unfocus();
                  setState((){
                    isDisplaySticker = !isDisplaySticker;
                  });
                },
              ),
            ),
            color: Colors.white,
          ),

          Flexible(
              child: Container(
            child: TextField(
              style: TextStyle(
                color: Colors.black, fontSize: 16.0
              ),
              decoration: InputDecoration.collapsed(
                  hintText: "write here ....",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1)
                  ),
              ),
              controller: messageController,
              focusNode: focusNode,
            ),
          )),

        //  send btn
          Material(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                color: Colors.lightBlueAccent,
                onPressed: (){},
              ),
            ),
          ),

        ],
      ),
      width: double.infinity,
      height: 60.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5
          )
        ),
        color: Colors.white
      ),
    );
  }

  createListMessage() {
    return Flexible(
      child: Center(
        child: CircularProgressIndicator( valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),),
      ),
    );
  }

  Future<bool> onBackPress() {

    if(isDisplaySticker){
      setState(() {
        isDisplaySticker = false;
      });
    }else{
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  createProgress() {
    return Positioned(child: isLoading ? circularProgress() : Container());
  }
}
