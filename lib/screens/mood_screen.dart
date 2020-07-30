import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MoodScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _MoodScreenState createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String messageText;
  String email;
  String datetime;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
        email = loggedInUser.email;
      }
    } catch (e) {
      print(e);
    }
  }

//  void getMoodDetails() async {
//    final moods = await _firestore.collection('MoodDetails').getDocuments();
//    for (var mood in moods.documents) {
//      print(mood.data);
//    }
//  }

//  void moodsStream() async {
//    await for (var snapshot
//        in _firestore.collection('MoodDetails').snapshots()) {
//      for (var mood in snapshot.documents) {
//        print(mood.data);
//      }
//    }
//  }

  createDialog(BuildContext, context) {
    TextEditingController customcontroller = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white70,
            title: Text(
              'How are you Feeling?',
              style: TextStyle(color: Colors.black),
            ),
            content: TextField(
              decoration: InputDecoration(
//                  border: InputBorder.none,
//
                  hintText: 'Type your text here',
                  hintStyle: TextStyle(color: Colors.blueGrey)),
              style:
                  TextStyle(color: Colors.black, decorationColor: Colors.black),
              cursorColor: Colors.black,
              controller: customcontroller,
              onChanged: (value) {
                messageText = value;
              },
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  var now = DateTime.now();
                  datetime =
                      DateFormat('yyyy-MM-dd hh:mm:ss').format(now).toString();
                  _firestore.collection('MoodDetails').add({
                    'text': messageText,
                    'sender': email,
                    'date': datetime,
                  });
                  Navigator.of(context).pop(customcontroller.text.toString());
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
//                moodsStream();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('Moods List'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('MoodDetails').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final moods = snapshot.data.documents;
                List<Detailsbubble> detailsbubbles = [];
                for (var mood in moods) {
                  final messageText = mood.data['text'];
                  final messageSender = mood.data['sender'];
                  final messageDate = mood.data['date'];
                  if (messageSender == email) {
                    final detailsbubble = Detailsbubble(
                      sender: messageSender,
                      text: messageText,
                      date: messageDate,
                    );
                    detailsbubbles.add(detailsbubble);
                  }
                }
                return Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: detailsbubbles,
                  ),
                );
              },
            ),
            Container(
//              decoration: kMessageContainerDecoration,
              margin: EdgeInsets.only(right: 10, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
//                  Expanded(
//                    child: TextField(
//                      onChanged: (value) {
//                        messageText = value;
//                      },
//                      decoration: kMessageTextFieldDecoration,
//                    ),
//                  ),
                  FloatingActionButton(
                    onPressed: () {
                      createDialog(BuildContext, context);
//                      _firestore.collection('MoodDetails').add({
//                        'text': messageText,
//                        'sender': email,
//                      });
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Detailsbubble extends StatelessWidget {
  Detailsbubble({this.sender, this.text, this.date});
  final String sender;
  final String text;
  String date;
//  String finaldate = date.toString();
//  final String formatted = formatter.format(now);
//  String date = DateTime.parse(now).toString();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            date,
            style: TextStyle(color: Colors.black54),
          ),
          SizedBox(
            height: 5,
          ),
          Material(
//        borderRadius: BorderRadius.circular(10),
            elevation: 5.0,
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
