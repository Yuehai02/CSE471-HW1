import 'dart:math';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_app/home.dart';
import 'package:mobile_app/main.dart';
import 'package:image_picker/image_picker.dart';

class Journal extends StatelessWidget {
  const Journal({super.key});

  // This widget is the root of your application.
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
  File? galleryFile;
  final picker = ImagePicker();

  void _showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img);
    XFile? xfilePick = pickedFile;
    setState(
      () {
        if (xfilePick != null) {
          setState(() {
            galleryFile = File(pickedFile!.path);
            imgFlag = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
  }

  TextEditingController cmntController = TextEditingController();
  List<String> _journalList = [];
  List<File?> _ImgList = [];
  List<bool> _imgBoolList = [];
  bool imgFlag = false;

  DateTime now = DateTime.now();
  final location = Geolocator.getCurrentPosition();

  Widget _buildPopupDialog(BuildContext context, data) {
    return AlertDialog(
      title: const Text('Journal Entry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(data['value'].toString(),
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12))
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

  Future<Object> getLocation() async {
    final location = await Geolocator.getCurrentPosition();
    return location;
  }

  var userFire = FirebaseAuth.instance.currentUser;

  Future<List<Object?>> func() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('journals')
        .where('user', isEqualTo: userFire!.email)
        .get();
    final allData = snap.docs.map((doc) => doc.data()).toList();
    return allData;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Location",
        home: Scaffold(
            backgroundColor: Colors.lightGreen[100],
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/assets/mountain.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
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
                        return Center(
                            child: Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.lightGreen.shade300,
                                              minimumSize: Size(64, 64),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0),
                                                  side: BorderSide(
                                                      color: Colors.lightGreen
                                                          .shade300)),
                                            ),
                                            child: Icon(
                                              Icons.home,
                                              size: 30.0,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Home()),
                                              );
                                            },
                                          ),
                                          SizedBox(width: 60),
                                          Text(
                                            "~ My Journal ~",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 20,
                                                color: Colors.indigo.shade300),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            "Date: " +
                                                now.month.toString() +
                                                "/" +
                                                now.day.toString() +
                                                "/" +
                                                now.year.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      TextField(
                                        controller: cmntController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Journal Entry',
                                        ),
                                      ),
                                      /*ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.indigo.shade300),
                                        child: const Text('Select Image'),
                                        onPressed: () {
                                          _showPicker(context: context);
                                        },
                                      ),*/
                                      SizedBox(
                                        height:
                                            galleryFile == null ? 0.0 : 200.0,
                                        width:
                                            galleryFile == null ? 0.0 : 300.0,
                                        child: galleryFile == null
                                            ? const Center(child: Text(''))
                                            : Center(
                                                child:
                                                    Image.file(galleryFile!)),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.indigo.shade300),
                                        onPressed: () {
                                          setState(() {
                                            FirebaseFirestore.instance
                                                .collection("journals")
                                                .add({
                                              'user':
                                                  userFire?.email.toString(),
                                              'value': cmntController.text
                                                  .toString(),
                                              'date': now
                                            });
                                            _journalList
                                                .add(cmntController.text);
                                            if (imgFlag) {
                                              _ImgList.add(galleryFile!);
                                              _imgBoolList.add(true);
                                              imgFlag = false;
                                            } else {
                                              _ImgList.add(null);
                                              _imgBoolList.add(false);
                                            }
                                            galleryFile = null;
                                            cmntController.clear();
                                          });
                                        },
                                        child: const Text('Add Entry'),
                                      ),
                                      Divider(color: Colors.black),
                                      Expanded(
                                          child: SizedBox(
                                        height: 200.0,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: snapshot.data!.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Container(
                                                      height: 50,
                                                      width: 250,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                    (snapshot.data!.elementAt(index) as Map)['date'].toDate().month.toString() +
                                                                        "/" +
                                                                        (snapshot.data!.elementAt(index) as Map)['date']
                                                                            .toDate()
                                                                            .day
                                                                            .toString() +
                                                                        "/" +
                                                                        (snapshot.data!.elementAt(index) as Map)['date']
                                                                            .toDate()
                                                                            .year
                                                                            .toString(),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            12)),
                                                              ],
                                                            ),
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .indigo
                                                                          .shade300),
                                                              child: Text(
                                                                  'Show Message',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          12)),
                                                              onPressed: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      _buildPopupDialog(
                                                                          context,
                                                                          snapshot
                                                                              .data!
                                                                              .elementAt(index)),
                                                                );
                                                              },
                                                            ),
                                                          ])),
                                                ]);
                                          },
                                        ),
                                      ))
                                    ])));
                      }
                      ;
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            )));
  }
}
