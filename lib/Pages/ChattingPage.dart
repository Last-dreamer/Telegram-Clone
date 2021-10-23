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

  const Chat({Key key, this.recieverId, this.recieverPhoto, this.recieverName}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: [
          Hero(
            tag: "avatar",
            child: CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(recieverPhoto),
            ),
          ),
        ],
        backgroundColor: Colors.lightBlueAccent,
        title: Text(recieverName, style: TextStyle(color: Colors.white, fontSize: 16),),
      ),
    );

  }
}

class ChatScreen extends StatefulWidget {

  @override
  State createState() => ChatScreenState();
}




class ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {

  }

}
