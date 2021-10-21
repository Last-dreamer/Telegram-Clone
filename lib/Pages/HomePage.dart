import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telegramchatapp/Pages/AccountSettingsPage.dart';
import 'package:telegramchatapp/Pages/ChattingPage.dart';

import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {

  final String currentUserId;

  const HomeScreen({Key key, this.currentUserId}) : super(key: key);

  @override
  State createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  TextEditingController searchController = TextEditingController();

  homeAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
      actions: [
        IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => settings()));
        }, icon: Icon(Icons.settings)),
      ],
      backgroundColor: Colors.lightBlue,
      title: Container(
        padding:EdgeInsets.all(8.0),
        child: TextFormField(
          style: TextStyle(color: Colors.white, fontSize: 18),
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search here....",
            hintStyle: TextStyle(color: Colors.white,),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
          ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            filled: true,
            prefixIcon: Icon(Icons.person_pin, color: Colors.white, size: 30.0,),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white,),
              onPressed: empty,
            )
          ),
        ),
      ),
    );
  }


  empty(){
    searchController.clear();
  }


  GoogleSignIn googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:homeAppBar(),
      body: Center(
        child: MaterialButton(
          onPressed: (){},
          child: Text("LogOut"),
        ),
      ),
    );
  }


}

class UserResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {}
}
