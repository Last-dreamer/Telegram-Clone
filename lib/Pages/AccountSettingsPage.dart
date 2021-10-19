import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:telegramchatapp/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightBlue,
        title: Text(
          "Account Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController nickNameController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();

  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photourl = "";

  SharedPreferences _pref;
  File imageFileAvatar;
  bool isLoading;

  @override
  void initState() {
    readDataFromLocal();
    super.initState();
  }

  void readDataFromLocal() async {

    _pref = await SharedPreferences.getInstance();
    id = _pref.getString("id");
    nickname = _pref.getString("nickname");
    aboutMe = _pref.getString("aboutMe");
    photourl = _pref.getString("photourl");

    print("photo url $photourl");

    setState(() {

    });

  }

  getImage() async {

    XFile newImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (newImage != null) {
      setState(() {
        this.imageFileAvatar = File(newImage.path);
        isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              child: Center(
                child: Stack(
                  children: [
                    (imageFileAvatar == null)
                        ? photourl != null
                        ? Material(
                      child: CachedNetworkImage(
                        imageUrl: photourl,
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                      ),
                      borderRadius:
                      BorderRadius.all(Radius.circular(125.0)),
                      clipBehavior: Clip.hardEdge,
                    )
                        : Icon(Icons.account_circle,
                        color: Colors.grey, size: 200)
                        : Material(
                      child: Image.file(
                        imageFileAvatar,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    IconButton(
                      onPressed: getImage,
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white54.withOpacity(0.3),
                        size: 100,
                      ),
                      padding: EdgeInsets.all(0.0),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.grey,
                      iconSize: 200.0,
                    ),
                  ],
                ),
              ),
              width: double.infinity,
              margin: EdgeInsets.all(20.0),
            ),
          ],
        )
      ],
    );
  }
}
