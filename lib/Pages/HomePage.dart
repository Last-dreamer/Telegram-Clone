import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telegramchatapp/Pages/ChattingPage.dart';

import 'package:telegramchatapp/Pages/AccountSettingsPage.dart';
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

  GoogleSignIn googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MaterialButton(
          onPressed: signOut,
          child: Text("LogOut"),
        ),
      ),
    );
  }

  void signOut() async {

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MyApp()), (route) => false);

  }
}

class UserResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {}
}
