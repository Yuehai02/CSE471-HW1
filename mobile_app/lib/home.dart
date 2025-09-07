import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_app/dailies.dart';
import 'package:mobile_app/exercise.dart';
import 'package:mobile_app/home.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/help.dart';
import 'package:mobile_app/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:path_provider/path_provider.dart';

import 'groups.dart';
import 'journal.dart';

class LocationRepo {
  static Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    return !(p == LocationPermission.denied ||
        p == LocationPermission.deniedForever);
  }

  // get present loaction
  static Future<Position?> getCurrent() async {
    if (!await _ensurePermission()) return null;
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // write in users/{uid}
  static Future<void> writeUserLocation(Position pos) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'lastLocation': GeoPoint(pos.latitude, pos.longitude),
      'lastLocatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

List<String> collegeList = [];
String dropdownValue = '';
//trying to fetch all the colleges names first and store in an array
Future<List<String>> fetchCollegeList() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await firestore.collection('locations').get();

  for (var doc in querySnapshot.docs) {
    String college = doc['college'];
    if (!collegeList.contains(college)) {
      collegeList.add(college);
    }
  }
  dropdownValue = collegeList.isNotEmpty ? collegeList.first : '';
  return collegeList;
}

class Home extends StatelessWidget {
  const Home({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

num _lindermanFeel = -1;
num _fmlFeel = -1;
num _storeFeel = -1;
List<File?> _lindermanImgList = [];
List<File?> _fmlImgList = [];
List<File?> _storeImgList = [];
List<bool> _lindermanImgBoolList = [];
List<bool> _fmlImgBoolList = [];
List<bool> _storeImgBoolList = [];
DateTime _lindermanTime = DateTime.parse("2000-01-01");
DateTime _fmlTime = DateTime.parse("2000-01-01");
DateTime _storeTime = DateTime.parse("2000-01-01");
bool imgFlag = false;
var auth = FirebaseAuth.instance.currentUser;

class _MyHomePageState extends State<MyHomePage> {
  File? galleryFile;
  final picker = ImagePicker();
  //calls each time the app is opened
  @override
  void initState() {
    super.initState();
    fetchCollegeList().then((college) {
      setState(() {
        collegeList = college;
      });
    });
    _displayCurrentLocation();
  }

  Widget _buildDisplayDialog(BuildContext context, data) {
    return AlertDialog(
      title: Text(data['user'].toString() + '\'s comment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(data['data'],
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

  Future<List<Object?>> getComments(locValue) async {
    CollectionReference collectionRef = FirebaseFirestore.instance
        .collection('comments')
        .doc(locValue)
        .collection("comments");

    QuerySnapshot querySnapshot = await collectionRef.get();

    DateTime now = DateTime.now();
    final allData = querySnapshot.docs
        .map((doc) {
          var data = doc.data();
          if (data != null) {
            // Explicitly cast data to Map<String, dynamic>
            Map<String, dynamic> dataMap = data as Map<String, dynamic>;
            DateTime? visibleTime =
                (dataMap['visibleTime'] as Timestamp?)?.toDate();
            if (visibleTime != null && now.isAfter(visibleTime)) {
              if (dataMap['feel'] == 'g') {
                return dataMap;
              }
            }
          }
          return null;
        })
        .where((data) => data != null)
        .toList();

    return allData;
  }

  bool _isNSFW = false;

  Widget _buildPopupDialog(BuildContext context, locValue) {
    return AlertDialog(
      title: Text(locValue + " Comments"),
      scrollable: true,
      contentPadding: EdgeInsets.all(1),
      content: Container(
          height: 400,
          width: 150,
          child: FutureBuilder(
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            List<bool> _likes =
                                List.filled(snapshot.data!.length, false);
                            return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: (snapshot.data!
                                                            .elementAt(index)
                                                        as Map)['feel'] ==
                                                    "b"
                                                ? Colors.red
                                                : (snapshot.data!.elementAt(
                                                                index)
                                                            as Map)['feel'] ==
                                                        "n"
                                                    ? Colors.yellow
                                                    : Colors.green,
                                            minimumSize: Size(10, 10),
                                            shape: CircleBorder(
                                                side: BorderSide(
                                                    color: Colors.white54)),
                                          ),
                                          child: Text(""),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: _likes[index]
                                              ? Icon(Icons.thumb_up_alt,
                                                  size: 16)
                                              : Icon(Icons.thumb_up_alt,
                                                  color: Colors.blue, size: 16),
                                          onPressed: () {
                                            _likes[index] = !_likes[index];
                                            setState(() {
                                              _likes[index];
                                            });
                                            print(_likes[index]);
                                          },
                                        ),
                                        Text(""),
                                        Container(
                                          child: Text(
                                            (snapshot.data!.elementAt(index)
                                                as Map)['user'],
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          width: 90,
                                        ),
                                        SizedBox(width: 5),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.indigo.shade300),
                                          child: Text('Show Message',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12)),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  _buildDisplayDialog(
                                                      context,
                                                      snapshot.data!
                                                          .elementAt(index)),
                                            );
                                          },
                                        ),
                                      ]),
                                ]);
                          },
                        ),
                      ],
                    );
                  }
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
              future: getComments(locValue))),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (BuildContext context) =>
                    _buildCommentDialog(context, locValue));
          },
          child: const Text('Add Comment'),
        ),
      ],
    );
  }

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

  String? _imagePath;

  Future<void> _onButtonPressed(XFile image) async {
    setState(() {
      _imagePath = image.path;
    });
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img, imageQuality: 100);
    XFile? xfilePick = pickedFile;
    if (xfilePick != null) {
      await _onButtonPressed(xfilePick);
      Fluttertoast.showToast(
        msg: "Picture selected",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      galleryFile = File(xfilePick.path);
      imgFlag = true;
      setState(() {});
    } else {}
  }

  TextEditingController cmntController = TextEditingController();
  String? selectedTone;

  Widget _buildCommentDialog(BuildContext context, locValue) {
    // To store the selected tone

    return AlertDialog(
      title: const Text('Add a Comment'),
      content: Container(
          height: 370, // Adjusted the height to fit the new widget
          width: 150,
          child: Column(
            children: <Widget>[
              TextField(
                controller: cmntController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Comment Entry',
                ),
              ),
              SizedBox(height: 10), // Spacing
              DropdownButtonFormField<String>(
                value: selectedTone,
                hint: Text('Select Comment Tone'),
                items: <String>[
                  'Positive',
                  'Negative',
                  'Neutral', // Added Neutral option
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedTone = newValue;
                  setState(() {
                    selectedTone;
                  });
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade300),
                child: const Text('Select Image'),
                onPressed: () {
                  _showPicker(context: context);
                },
              ),
              _imagePath == null
                  ? const Text('No image has been selected')
                  : Image.file(File(_imagePath!)),
            ],
          )),
      actions: <Widget>[
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          onPressed: () async {
            final filter = ProfanityFilter();
            // implement - Check for profanity -
            //returns a msg "Please refrain from using profanity"(if profanity is present)
            // hint: use hasProfanity() plugin, then change true to profanity check
            // your codes begin here
            final text = cmntController.text.trim();
            //empty
            if (text.isEmpty) {
              Fluttertoast.showToast(msg: "Comment cannot be empty.");
              return;
            }
            //some "hurt myself" word
            final crisis = RegExp(
              r'(suicide|kill myself|end my life|want to die|self[- ]?harm|cut myself)',
              caseSensitive: false,
            );
            //
            final hasIssue = filter.hasProfanity(text) || crisis.hasMatch(text);

            if (hasIssue) {
              if (filter.hasProfanity(text)) {
                Fluttertoast.showToast(
                    msg: "Please refrain from using profanity.");
              }
              if (crisis.hasMatch(text)) {
                Fluttertoast.showToast(
                  msg:
                      "Your message seems distressing. Please consider reaching out to someone you trust or campus counseling.",
                  toastLength: Toast.LENGTH_LONG,
                );
              }
              return;

              // end
              //SUICIDAL MESSAGES FILTER HERE
            } else {
              // add code to set feelValue to g b n, 'Positive'='g', 'Negative'='b', 'Neutral'='n'
              if (selectedTone != null) {
                String feelValue;
                // your codes begin here
                switch (selectedTone) {
                  case 'Positive':
                    feelValue = 'g'; // good
                    break;
                  case 'Negative':
                    feelValue = 'b'; // bad
                    break;
                  case 'Neutral':
                  default:
                    feelValue = 'n';
                    break;
                }

                // end
                // Generating a random delay between 8 and 24 hours
                int delayInHours = Random().nextInt(17) +
                    8; // Generates a number between 0 and 16, then adds 8
                DateTime postTime = DateTime.now();
                DateTime visibleTime =
                    postTime.add(Duration(hours: delayInHours));
                // use FirebaseFirestore.instance to store the comment entry (data, user, feelvalue, posttime, visibletime)
                // your codes begin here
                final userEmail = auth?.email ?? 'anonymous';
                await FirebaseFirestore.instance
                    .collection('comments')
                    .doc(locValue) // 位置键（你的弹窗标题里就是 locValue）
                    .collection('comments')
                    .add({
                  'data': text,
                  'user': userEmail,
                  'feel': feelValue, // g / b / n
                  'postTime': Timestamp.fromDate(postTime),
                  'visibleTime': Timestamp.fromDate(visibleTime),
                  // 可选附带：方便后续查询/统计
                  'college': dropdownValue,
                  'locationName': locValue,
                });
                Fluttertoast.showToast(msg: "Comment submitted.");

                // end
                setState(() {
                  selectedTone = null;
                  cmntController.clear();
                });
                Navigator.of(context).pop();
              } else {
                // Handle case when no tone is selected (Maybe show a snackbar or alert)
              }
            }
          },
          child: const Text('Add Entry'),
        ),
        ElevatedButton(
          onPressed: () {
            galleryFile = null;
            setState(() {
              selectedTone = null;
              cmntController.clear();
            });
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Position _location = Position(
      latitude: 0,
      longitude: 0,
      speed: 0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      speedAccuracy: 0,
      heading: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0);

  late GoogleMapController mapController;
  //this is the function to load custom map style json
  void changeMapMode(GoogleMapController mapController) {
    getJsonFile("lib/assets/map_style.json")
        .then((value) => setMapStyle(value, mapController));
  }

  //helper function
  void setMapStyle(String mapStyle, GoogleMapController mapController) {
    mapController.setMapStyle(mapStyle);
  }

  //helper function
  Future<String> getJsonFile(String path) async {
    ByteData byte = await rootBundle.load(path);
    var list = byte.buffer.asUint8List(byte.offsetInBytes, byte.lengthInBytes);
    return utf8.decode(list);
  }

  final LatLng _center = const LatLng(40.6049, -75.3775);

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void _displayCurrentLocation() async {
    final pos = await LocationRepo.getCurrent();
    if (pos == null) {
      Fluttertoast.showToast(msg: "Location permission denied/disabled.");
      return;
    }

    await LocationRepo.writeUserLocation(
        pos); // write in Firestore: users/{uid}

    _add(pos.latitude, pos.longitude, 'Your Location', true,
        -1); //write point on the map

    try {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 14),
      );
    } catch (_) {}

    setState(() {
      _location = pos;
    });
  }

  BitmapDescriptor getMarkerColor(double feelValue) {
    if (feelValue >= 0 && feelValue <= 0.7) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else if (feelValue <= 1.3) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    } else if (feelValue <= 2) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }

  void _add(double lat, double lng, String id, bool yourLoc, double feelValue) {
    String markerIdVal = id;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: markerIdVal),
      //calls function above to get color for map
      icon: getMarkerColor(feelValue),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              _buildPopupDialog(context, markerIdVal),
        );
      },
    );

    // The marker is added to the map
    setState(() {
      markers[markerId] = marker;
    });
  }

  void _addCollegeMarkers(String collegeName) async {
    FirebaseFirestore.instance
        .collection("locations")
        .where("college", isEqualTo: collegeName)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var location = data['location'] as List<dynamic>;
        var name = data['name'] as String;

        //adds location for each "name" aka "building"
        double lat = location[0];
        double lng = location[1];

        _add(lat, lng, name, false, -1);
      }
    }).catchError((error) {
      print("Error getting documents: $error");
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    changeMapMode(mapController);
  }

  List<String> items = [
    "Journal",
    "Profile",
  ];

  /// List of body icon
  List<IconData> icons = [
    Icons.home,
    Icons.explore,
    Icons.settings,
    Icons.person
  ];
  int current = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Location",
        home: Scaffold(
            backgroundColor: Colors.lightGreen[100],
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.indigo.shade300,
              title: Text(
                "Home Page",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("lib/assets/beach.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                width: double.infinity,
                height: double.infinity,
                margin: const EdgeInsets.all(5),
                child: Column(children: [
                  SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.all(5),
                            width: 85,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: TextButton(
                                child: Text(
                                  "Journal",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.indigo.shade300),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Journal()));
                                },
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.all(5),
                            width: 85,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: TextButton(
                                child: Text(
                                  "Activities",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.indigo.shade300),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Dailies()));
                                },
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.all(5),
                            width: 85,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: TextButton(
                                child: Text(
                                  "Groups",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.indigo.shade300),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Groups()));
                                },
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.all(5),
                            width: 85,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: TextButton(
                                child: Text(
                                  "Profile",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.indigo.shade300),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Profile()));
                                },
                              ),
                            ),
                          ),
                        ],
                      )),
                  Text(
                    Random().nextInt(2) == 0
                        ? "\"You have an individual story to tell\""
                        : "\"Find happiness in the darkest times\"",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Colors.indigo.shade300),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Change current college:",
                          style: TextStyle(color: Colors.indigo.shade500),
                        ),
                        DropdownButton(
                          value: dropdownValue.isEmpty ? null : dropdownValue,
                          hint: const Text('Select college'),
                          items: collegeList
                              .map<DropdownMenuItem<String>>((String v) {
                            return DropdownMenuItem<String>(
                                value: v, child: Text(v));
                          }).toList(),
                          onChanged: (String? value) {
                            if (value == null) return;
                            setState(() => dropdownValue = value);
                            _addCollegeMarkers(value);
                            _displayCurrentLocation();
                          },
                        ),
                        SizedBox(
                            width: 500,
                            height: 500,
                            child: GoogleMap(
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                target: _center,
                                zoom: 11.0,
                              ),
                              markers: Set<Marker>.of(markers.values),
                            )),
                      ],
                    ),
                  ),
                ]))));
  }
}
