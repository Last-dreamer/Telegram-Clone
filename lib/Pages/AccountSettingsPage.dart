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
  bool isLoading = false;

  FocusNode nicknameFocus = FocusNode();
  FocusNode aboutMeFocus = FocusNode();

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

    aboutMeController = TextEditingController(text: aboutMe);
    nickNameController = TextEditingController(text: nickname);

    setState(() {});
  }

  getImage() async {
    XFile newImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (newImage != null) {
      setState(() {
        this.imageFileAvatar = File(newImage.path);
        isLoading = true;
      });
    }

    getImageUploadToFirebaseAndStorage();
  }

  getImageUploadToFirebaseAndStorage() async {
    String fileName = id;
    var storageRef = FirebaseStorage.instance
        .ref()
        .child(fileName)
        .putFile(imageFileAvatar)
        .then((value) {
      if (value != null) {
        value.ref.getDownloadURL().then((imageUrl) {
          photourl = imageUrl;

          FirebaseFirestore.instance.collection("users").doc(id).update({
            "photourl": photourl,
            "aboutMe": aboutMe,
            "nickname": nickname
          }).then((data) async {
            await _pref.setString("photourl", photourl);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
                msg: "user updated successfully.....",
                toastLength: Toast.LENGTH_LONG);
          });
        }).onError((error, stackTrace) {
          Fluttertoast.showToast(msg: "Error while downloading imageUrl");
          setState(() {
            isLoading = false;
          });
        });
      }
    }).onError((error, stackTrace) {
      Fluttertoast.showToast(msg: error.toString());
      setState(() {
        isLoading = false;
      });
    });
  }

  updateUser() async {

    nicknameFocus.unfocus();
    aboutMeFocus.unfocus();


    setState((){
      isLoading = false;
    });

    FirebaseFirestore.instance.collection("users").doc(id).update({
      "photourl": photourl,
      "aboutMe": aboutMe,
      "nickname": nickname
    }).then((data) async {
      await _pref.setString("photourl", photourl);
      await _pref.setString("aboutMe", aboutMe);
      await _pref.setString("nickname", nickname);
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "user updated successfully.....",
          toastLength: Toast.LENGTH_LONG);
    }).onError((error, stackTrace) {
      Fluttertoast.showToast(msg: "Error while downloading imageUrl");
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Center(
                  child: Stack(
                    children: [
                      (imageFileAvatar == null)
                          ? photourl != null
                              ? Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.lightBlue),
                                    ),
                                    imageUrl: photourl,
                                    fit: BoxFit.cover,
                                    width: 200,
                                    height: 200,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(125.0)),
                                  clipBehavior: Clip.hardEdge,
                                )
                              : Icon(
                                  Icons.account_circle,
                                  color: Colors.grey,
                                  size: 200,
                                )
                          : Material(
                              child: Image.file(
                                imageFileAvatar,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(125.0),
                              clipBehavior: Clip.hardEdge,
                            ),
                      IconButton(
                        onPressed: getImage,
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white54.withOpacity(0.4),
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.all(1.0),
                      child: isLoading ? circularProgress() : Container()),
                  Container(
                    child: Text(
                      "user Name:",
                      style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 10, top: 10, bottom: 5.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.lightBlue),
                      child: TextField(
                        controller: nickNameController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: "eg. Muhammad Asim"),
                        onChanged: (value) {
                          nickname = value;
                        },
                        focusNode: nicknameFocus,
                      ),
                    ),
                    padding: EdgeInsets.only(left: 30, right: 30),
                  ),
                  Container(
                    child: Text(
                      "About Me:",
                      style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 10, top: 10, bottom: 5.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.lightBlue),
                      child: TextField(
                        controller: aboutMeController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: "eg. Bio......"),
                        onChanged: (value) {
                          aboutMe = value;
                        },
                        focusNode: aboutMeFocus,
                      ),
                    ),
                    padding: EdgeInsets.only(left: 30, right: 30),
                  ),
                ],
              ),

              //   buttons
              Container(
                child: FlatButton(
                  child: Text(
                    "Update",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onPressed: updateUser,
                  color: Colors.lightBlueAccent,
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  highlightColor: Colors.grey,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 1.0),
              ),

              //  logout button
              Container(
                padding: EdgeInsets.only(left: 50, right: 50.0),
                child: RaisedButton(
                  onPressed: signOut,
                  child: Text(
                    "LogOut",
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                  color: Colors.red,
                ),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15, right: 15),
        ),
      ],
    );
  }

  var googleSignIn = GoogleSignIn();

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => MyApp()), (route) => false);
  }
}
