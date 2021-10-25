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

  final listScrollController = ScrollController();

  bool isLoading;
  bool isDisplaySticker;

  File imageFile;
  String imageUrl;

  String chatId;
  String id;
  SharedPreferences storedData;
  var listMessages;

  @override
  void initState() {
    isLoading = false;
    isDisplaySticker = false;

    focusNode.addListener(onFocuseChange);
    chatId = "";

    readLocal();
    super.initState();
  }

  readLocal() async {
    storedData = await SharedPreferences.getInstance();
    id = storedData.getString("id");
    if (id.hashCode <= widget.receiverId.hashCode) {
      chatId = '$id-${widget.receiverId}';
    } else {
      chatId = '${widget.receiverId}-$id';
    }
    FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"chattingWith": widget.receiverId});
  }

  onFocuseChange() {
    if (focusNode.hasFocus) {
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
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                onPressed: onSendMessage("mimi1", 2),
                child: Image.asset(
                  "images/mimi1.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: onSendMessage("mimi2", 2),
                child: Image.asset(
                  "images/mimi2.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                onPressed: onSendMessage("mimi3", 2),
                child: Image.asset(
                  "images/mimi3.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: onSendMessage("mimi4", 2),
                child: Image.asset(
                  "images/mimi4.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
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
                onPressed: getImage,
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
                  setState(() {
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
              style: TextStyle(color: Colors.black, fontSize: 16.0),
              decoration: InputDecoration.collapsed(
                hintText: "write here ....",
                hintStyle: TextStyle(color: Colors.grey),
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1)),
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
                onPressed: onSendMessage(messageController.text, 0),
              ),
            ),
          ),
        ],
      ),
      width: double.infinity,
      height: 60.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

  createListMessage() {
    return Flexible(
        child: chatId == ""
            ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                ),
              )
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("messages")
                    .doc(chatId)
                    .collection(chatId)
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
          builder: (context, snapshot){
                  if(!snapshot.hasData){
                    return  Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                      ),
                    );
                  }else{
                    listMessages = snapshot.data.doc;
                    return ListView.builder(
                      // itemBuilder: (context, index) => createItem(index, snapshot.data.doc[index]),
                      itemCount: snapshot.data.doc.length,
                      padding: EdgeInsets.all(4.0),
                      controller: listScrollController,
                      reverse: true,
                    );
                  }
          },
              ));
  }

  Future<bool> onBackPress() {
    if (isDisplaySticker) {
      setState(() {
        isDisplaySticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  createProgress() {
    return Positioned(child: isLoading ? circularProgress() : Container());
  }

  getImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    imageFile = File(image.path);

    if (imageFile != null) {
      isLoading = true;
    }

    uploadImage();
  }

  uploadImage() {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    var ref = FirebaseStorage.instance
        .ref()
        .child("chat_images")
        .child(fileName)
        .putFile(imageFile)
        .then((image) {
      image.ref.getDownloadURL().then((value) {
        // storing image String  in imageUrl
        imageUrl = value;
        setState(() {
          isLoading = false;
          onSendMessage(imageUrl, 1);
        });
      }).onError((error, stackTrace) {
        setState(() {
          isLoading = false;
          Fluttertoast.showToast(msg: "Error" + error);
        });
      });
    });
  }

  onSendMessage(String text, int type) {
    if (text != "") {
      messageController.clear();

      var docRef = FirebaseFirestore.instance
          .collection("messages")
          .doc(chatId)
          .collection(chatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(docRef, {
          "idFrom": id,
          "idTo": widget.receiverId,
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "content": text,
          "type": type
        });
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 700), curve: Curves.bounceInOut);
    } else {
      Fluttertoast.showToast(msg: "Empty msg can't be send ...");
    }
  }
}
