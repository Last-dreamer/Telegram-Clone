import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telegramchatapp/Pages/HomePage.dart';
import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final googleSignIn = GoogleSignIn();
  final _auth = FirebaseAuth.instance;
  SharedPreferences _pref;

  bool isLoggedIn = false;
  bool isLoading = false;
  User _user;

  @override
  void initState() {
    isSignIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.lightBlueAccent, Colors.purpleAccent]),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Dreamer Chat's",
              style: TextStyle(
                  fontFamily: "Signatra", fontSize: 62, color: Colors.white),
            ),
            InkWell(
              onTap: controlSignIn,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  height: MediaQuery.of(context).size.height * 0.09,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              "assets/images/google_signin_button.png"),
                        fit: BoxFit.cover
                      )),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(1.0),
              child: isLoading ? circularProgress() : Container(),
            )
          ],
        ),
      ),
    );
  }

  Future<Null> controlSignIn() async {
    setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credentials = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

    User user = (await _auth.signInWithCredential(credentials)).user;

    if (user != null) {
      // if user exists..
      final QuerySnapshot resultQuery = await FirebaseFirestore.instance
          .collection("users")
          .where("id", isEqualTo: user.uid)
          .get();

      final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;

      if (documentSnapshots.length == 0) {
        FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "id": user.uid,
          "nickname": user.displayName,
          "photourl": user.photoURL,
          "createAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "aboutMe": "i'm dreamer and it's telegram clone...",
          "chattingWith": null
        });

        //  to local
        _user = user;
        await _pref.setString("id", _user.uid);
        await _pref.setString("nickname", _user.displayName);
        await _pref.setString("photourl", _user.photoURL);
      } else {
        // if user is already loggedin.....
        _user = user;
        await _pref.setString("id", documentSnapshots[0]['id']);
        await _pref.setString("nickname", documentSnapshots[0]['nickname']);
        await _pref.setString("photourl", documentSnapshots[0]['photourl']);
        await _pref.setString("aboutMe", documentSnapshots[0]['aboutMe']);
      }

      Fluttertoast.showToast(
          msg: "yup ... ${_user.displayName}", toastLength: Toast.LENGTH_LONG);

      setState(() {
        isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => HomeScreen(
                    currentUserId: _pref.getString("id"),
                  ),), (_) => false);
    } else {
      Fluttertoast.showToast(
          msg: "Sign-in failed ...", toastLength: Toast.LENGTH_LONG);
      setState(() {
        isLoading = false;
      });
    }
  }

  void isSignIn() async {
    setState(() {
      isLoading = true;
    });

    _pref = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();

    if (isLoggedIn) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => HomeScreen(
                    currentUserId: _pref.getString("id"),
                  )), (_)=> false);
    }

    setState(() {
      isLoading = false;
    });
  }
}
