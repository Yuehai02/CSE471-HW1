import 'dart:math';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_app/home.dart';
import 'package:mobile_app/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/profile.dart';

class Users extends StatelessWidget {
  const Users({super.key});

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
  var collection = FirebaseFirestore.instance.collection("users");

  late List<Map<String, dynamic>> items;
  late List<bool> friends;

  bool isLoaded = false;
  bool load = false;
  _incrementCounter() async {
    List<String> friend = [];
    List<bool> temp = [];
    var fdata = await FirebaseFirestore.instance
        .collection("users")
        .doc("nbDNJV5x1dWMlwNTWjPl")
        .collection("friends")
        .get();
    fdata.docs.forEach((element) {
      friend.add(element.data()["email"]);
    });
    List<Map<String, dynamic>> tempList = [];
    var data = await collection.get();
    data.docs.forEach((element) {
      tempList.add(element.data());
      if (friend.contains(element.data()["email"].toString())) {
        temp.add(true);
      } else {
        temp.add(false);
      }
    });
    setState(
      () {
        items = tempList;
        friends = temp;
        isLoaded = true;
        load = true;
      },
    );
  }

  _addFriend(name) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc("nbDNJV5x1dWMlwNTWjPl")
        .collection("friends")
        .add({"email": name});
    setState(() {
      load = true;
    });
  }

  Widget _buildJournalDialog(BuildContext context, String email, String phone,
      String food, String vacation) {
    return AlertDialog(
      backgroundColor: Colors.indigo.shade100,
      title: Text(email,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.indigo.shade400)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              "Phone:  " +
                  phone +
                  "\n\nFavorite Food:  " +
                  food +
                  "\n\nDream Vacation:  " +
                  vacation,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
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

  @override
  Widget build(BuildContext context) {
    isLoaded ? print("done") : _incrementCounter();
    return MaterialApp(
        title: "Other Users",
        home: Scaffold(
            backgroundColor: Colors.lightGreen[100],
            body: Container(
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreen.shade300,
                              minimumSize: Size(64, 64),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                  side: BorderSide(
                                      color: Colors.lightGreen.shade300)),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              size: 30.0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Profile()),
                              );
                            },
                          ),
                          SizedBox(width: 50),
                          Text(
                            "Friends/Other Users",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.indigo.shade300),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      isLoaded
                          ? load
                              ? ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: items.length,
                                  itemBuilder: ((context, index) {
                                    return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          shape: RoundedRectangleBorder(
                                              side: const BorderSide(width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          leading: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.lightGreen.shade300,
                                              minimumSize: Size(30, 30),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  side: BorderSide(
                                                      color: Colors.lightGreen
                                                          .shade300)),
                                            ),
                                            child: Icon(
                                              Icons.person,
                                              size: 20.0,
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        _buildJournalDialog(
                                                            context,
                                                            items[index]
                                                                ["email"],
                                                            items[index]
                                                                ["phone"],
                                                            items[index]
                                                                ["food"],
                                                            items[index]
                                                                ["vacation"]),
                                              );
                                            },
                                          ),
                                          title: Row(children: [
                                            Text(items[index]["email"]
                                                .toString()),
                                          ]),
                                          subtitle: Text("Points:  " +
                                              items[index]["points"]
                                                  .toString()),
                                          trailing: friends[index]
                                              ? Icon(Icons.check)
                                              : ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .lightGreen.shade300,
                                                    minimumSize: Size(5, 5),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50.0),
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .lightGreen
                                                                    .shade300)),
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                  ),
                                                  onPressed: () async {
                                                    load = false;
                                                    await _addFriend(
                                                        items[index]["email"]
                                                            .toString());
                                                  },
                                                ),
                                        ));
                                  }))
                              : Text("no data")
                          : Text("no data"),
                      SizedBox(height: 20),
                    ],
                  ),
                )))));
  }
}
