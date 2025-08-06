import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/home.dart';
import 'package:mobile_app/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Profile',
      home: const MyEditProfile(title: 'Edit Profile'),
    );
  }
}

class MyEditProfile extends StatefulWidget {
  const MyEditProfile({super.key, required this.title});

  final String title;

  @override
  State<MyEditProfile> createState() => _MyEditProfileState();
}

var user = FirebaseAuth.instance.currentUser!.email;

class _MyEditProfileState extends State<MyEditProfile> {
  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController foodController = TextEditingController(text: '');
  TextEditingController vacController = TextEditingController(text: '');
  TextEditingController phoneController = TextEditingController(text: '');
  TextEditingController emailController = TextEditingController(text: '');

  var userFire = FirebaseAuth.instance.currentUser;

  //retrieves data from Firebase regarding profile info
  Future<List<Object?>> func() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userFire!.email)
        .get();
    final allData = snap.docs.map((doc) => doc.data()).toList();
    phoneController.text = (allData.elementAt(0) as Map)['phone'];
    vacController.text = (allData.elementAt(0) as Map)['vacation'];
    foodController.text = (allData.elementAt(0) as Map)['food'];
    return allData;
  }

  //Displays the edit profile page
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Edit Profile',
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.lightGreen.shade200,
              title: Center(
                child: const Text('Edit Profile'),
              ),
            ),
            body: SafeArea(
              child: FutureBuilder(
                future: func(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If we got an error
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '${snapshot.error} occurred',
                          style: TextStyle(fontSize: 18),
                        ),
                      );

                      // if we got our data
                    } else if (snapshot.hasData) {
                      return ListView(
                        children: <Widget>[
                          Container(
                            height: 250,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.indigo.shade300,
                                  Colors.indigo.shade300
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: [0.5, 0.9],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                        Icons.check,
                                        size: 30.0,
                                      ),
                                      onPressed: () async {
                                        phoneController.text != ''
                                            ? await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user)
                                                .update({
                                                'phone': phoneController.text
                                              })
                                            : '';
                                        foodController.text != ''
                                            ? await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user)
                                                .update({
                                                'food': foodController.text
                                              })
                                            : '';
                                        vacController.text != ''
                                            ? await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user)
                                                .update({
                                                'vacation': vacController.text
                                              })
                                            : '';
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Profile()),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  user!,
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    color: Colors.deepOrange.shade300,
                                    child: ListTile(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    'Phone Number',
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: TextField(
                                    controller: phoneController,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Divider(),
                                ListTile(
                                  title: Text(
                                    'Favorite Food',
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: TextField(
                                    controller: foodController,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Divider(), //cut here for more colums
                                ListTile(
                                  title: Text(
                                    'Dream Vacation',
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: TextField(
                                    controller: vacController,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      );
                    }
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            )));
  }
}
