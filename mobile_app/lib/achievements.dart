import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_app/dailies.dart';
import 'package:mobile_app/home.dart';
import 'package:mobile_app/main.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app/profile.dart';

class Achievements extends StatelessWidget {
  const Achievements({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  IconData icon = Icons.timer;
  bool claimed = false;

  //collects firebase data regarding user's last daily login claim
  func() async {
    var time = DateTime.now().day;
    var last = 0;
    await FirebaseFirestore.instance
        .collection('users')
        .doc("nbDNJV5x1dWMlwNTWjPl")
        .get()
        .then((snapshot) {
      last = snapshot.data()?["day"];
      if (time > last) {
        claimed = false;
        icon = Icons.timer;
      } else {
        claimed = true;
        icon = Icons.check;
      }
    });
  }

  //displays an achievement goal
  Widget _buildExerciseDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Exercise Quest"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Complete an exercise activity!\n\nReward 100 points",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14))
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  //displays an achievement goal
  Widget _buildLocationDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Location Quest"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Discover and comment on a new location!\n\nReward 200 points",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14))
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  //displays an achievement goal
  Widget _buildJournalDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Journal Quest"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              "Write a new entry in your journal for the day\n\nReward 100 points",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14))
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  //displays an achievement goal
  Widget _buildMeditateDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Mindfulness Quest"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Complete a mindfulness activity!\n\nReward 100 points",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14))
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  //displays the achievements page
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Achievements'),
            ),
            body: FutureBuilder(
                future: func(),
                builder: (context, snapshot) {
                  return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("lib/assets/mountain.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      SizedBox(width: 20),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.lightGreen.shade300,
                                          minimumSize: Size(64, 64),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              side: BorderSide(
                                                  color: Colors
                                                      .lightGreen.shade300)),
                                        ),
                                        child: Icon(
                                          Icons.arrow_back,
                                          size: 30.0,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Profile()),
                                          );
                                        },
                                      ),
                                    ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.lightGreen.shade300,
                                          minimumSize: Size(64, 64),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              side: BorderSide(
                                                  color: Colors
                                                      .lightGreen.shade300)),
                                        ),
                                        child: Icon(
                                          icon,
                                          size: 30.0,
                                        ),
                                        onPressed: () async {
                                          if (!claimed) {
                                            var val;
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc("nbDNJV5x1dWMlwNTWjPl")
                                                .get()
                                                .then((snapshot) => val =
                                                    snapshot.data()?["points"]);
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc("nbDNJV5x1dWMlwNTWjPl")
                                                .update({"points": val + 10});
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc("nbDNJV5x1dWMlwNTWjPl")
                                                .update({
                                              "day": DateTime.now().day
                                            });
                                            Fluttertoast.showToast(
                                              msg:
                                                  "Claimed your daily 10 points!",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity
                                                  .BOTTOM, // Also possible "TOP" and "CENTER"
                                            );
                                            setState(() {});
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: "Come back tomorrow!",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity
                                                  .BOTTOM, // Also possible "TOP" and "CENTER"
                                            );
                                          }
                                        },
                                      ),
                                      SizedBox(width: 20),
                                    ]),
                              ],
                            ),
                            SizedBox(height: 100),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade300,
                                          minimumSize: Size(128, 64),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              side: BorderSide(
                                                  color:
                                                      Colors.indigo.shade300)),
                                        ),
                                        child: Icon(
                                          Icons.accessibility_new_rounded,
                                          size: 30.0,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                _buildExerciseDialog(context),
                                          );
                                        },
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade300,
                                          minimumSize: Size(128, 64),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              side: BorderSide(
                                                  color:
                                                      Colors.indigo.shade300)),
                                        ),
                                        child: Icon(
                                          Icons.add_business_outlined,
                                          size: 30.0,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                _buildLocationDialog(context),
                                          );
                                        },
                                      ),
                                    ]),
                                SizedBox(height: 20),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade300,
                                          minimumSize: Size(128, 64),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              side: BorderSide(
                                                  color:
                                                      Colors.indigo.shade300)),
                                        ),
                                        child: Icon(
                                          Icons.add_comment_rounded,
                                          size: 30.0,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                _buildJournalDialog(context),
                                          );
                                        },
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade300,
                                          minimumSize: Size(128, 64),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              side: BorderSide(
                                                  color:
                                                      Colors.indigo.shade300)),
                                        ),
                                        child: Icon(
                                          Icons.battery_charging_full_rounded,
                                          size: 30.0,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                _buildMeditateDialog(context),
                                          );
                                        },
                                      ),
                                    ]),
                              ],
                            ),
                          ],
                        ),
                      )));
                })));
  }
}
