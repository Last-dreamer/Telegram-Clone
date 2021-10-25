import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telegramchatapp/Models/user.dart' as mUser;
import 'package:telegramchatapp/Pages/AccountSettingsPage.dart';
import 'package:telegramchatapp/Pages/ChattingPage.dart';

import 'package:telegramchatapp/Widgets/ProgressWidget.dart';
import 'package:google_sign_in/google_sign_in.dart';


class HomeScreen extends StatefulWidget {
  final String currentUserId;

  const HomeScreen({Key key, this.currentUserId}) : super(key: key);

  @override
  State createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> allFoundUser;




  homeAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => settings()));
            },
            icon: Icon(Icons.settings)),
      ],
      backgroundColor: Colors.lightBlue,
      title: Container(
        padding: EdgeInsets.all(8.0),
        child: TextFormField(
          style: TextStyle(color: Colors.white, fontSize: 18),
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search here....",
            hintStyle: TextStyle(
              color: Colors.white,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            filled: true,
            prefixIcon: Icon(
              Icons.person_pin,
              color: Colors.white,
              size: 30.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: empty,
            ),
          ),
          onFieldSubmitted: (username){
            print("user name ${username}");
            controlSearching(username);
          },
        ),
      ),
    );
  }

 controlSearching(String username)  {
    Future<QuerySnapshot> querySnapshot =  FirebaseFirestore.instance
        .collection("users")
        .where("nickname", isGreaterThanOrEqualTo: username)
        .get();

    print("my query ${querySnapshot.then((v) => v.docs.map((e) => e.data.call())) }");
    setState(() {
      allFoundUser = querySnapshot;
    });
  }

  empty() {
    searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: homeAppBar(),
        body: allFoundUser == null ? displayNoSuchUser() : displayUserFound());
  }

  displayUserFound(){
    return FutureBuilder<QuerySnapshot>(
        future: allFoundUser,
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return circularProgress();
          }
          List<UserResult> allUser = [];

          snapshot.data.docs.forEach((data) {
            print("some ${data.get("nickname")}");
            final userdata = new Map<String, dynamic>.from(data.data());
            print("userdata ${userdata}");
            mUser.User user  =  mUser.User.fromDocument(userdata);
            print("some 2 ${user.createdAt}");
            UserResult res = UserResult(user);

            print("some 3 ${user.nickname}");
            if(widget.currentUserId != data.id){
              allUser.add(res);
              print("some 4 ${data.get("nickname")}");
            }
          });
         return  Column(
           children: allUser,
         );
        });
  }

  displayNoSuchUser() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(
              Icons.group,
              color: Colors.lightBlueAccent,
              size: 200.0,
            ),
            Text(
              "Search User",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30,
                  color: Colors.lightBlueAccent,fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}

class UserResult extends StatelessWidget {

  final mUser.User eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        child: Column(
          children: [
            GestureDetector(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder:  (_) => Chat(
                  recieverId: eachUser.id,
                  recieverPhoto:eachUser.photoUrl,
                  recieverName:eachUser.nickname
                )));
              },
              child: ListTile(
                leading: Hero(
                  tag: "avatar",
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage: CachedNetworkImageProvider(eachUser.photoUrl),
                  ),
                ),
                title: Text(eachUser.nickname, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),),
                subtitle: Text("Joind" +
                    DateFormat("dd, MMMM, yyyy - hh:mm:aa")
                        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(eachUser.createdAt))), style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),),
              ),
            )
          ]
        ),
      ),
    );

  }


}
