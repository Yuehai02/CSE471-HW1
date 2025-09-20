import 'dart:math';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_app/home.dart';
import 'package:mobile_app/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Groups extends StatelessWidget {
  const Groups({super.key});

  @override
  Widget build(BuildContext context) {
    return MyHomePage(title: 'Groups');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController cmntController = TextEditingController();
  TextEditingController descController = TextEditingController();
  //group examples
  var _groupList = [
    [
      "First group :)",
      "Public",
      "leh3003@wellcoach.org",
      "my first group, seeing how it works"
    ],
    [
      "Bookstores!!",
      "Public",
      "mat202@wellcoach.org",
      "A group for all who love bookstores!!"
    ],
    [
      "Libraries enjoyers",
      "Public",
      "lem111@wellcoach.org",
      "I like books. Do you?"
    ]
  ];
  var _groupEntry = [false, false, false];
  String _visibility = 'Public';
  final List<String> _visibilityOptions = ['Public', 'Private'];

  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Group Creation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: cmntController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Group Name',
            ),
          ),
          SizedBox(height: 5),
          TextField(
            maxLines: null,
            controller: descController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Description',
            ),
          ),
          SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: _visibility,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Visibility',
            ),
            items: _visibilityOptions
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() => _visibility = v ?? 'Public'),
          ),
          const SizedBox(height: 5),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            // add the newly created group to the group list dropdown option (public private) auth!.email
            // your codes begin here
            final name = cmntController.text.trim();
            final desc = descController.text.trim();
            if (name.isEmpty) {
              Fluttertoast.showToast(msg: "Group name cannot be empty.");
              return;
            }

            final user = FirebaseAuth.instance.currentUser;
            final creatorEmail = user?.email ?? 'anonymous';
            final creatorUid = user?.uid;
            final visibility = _visibility;

            try {
              await FirebaseFirestore.instance.collection('groups').add({
                'name': name,
                'visibility': visibility,
                'creatorEmail': creatorEmail,
                'creatorUid': creatorUid,
                'description': desc,
                'createdAt': FieldValue.serverTimestamp(),
              });

              setState(() {
                _groupList.add([name, visibility, creatorEmail, desc]);
                _groupEntry.add(false);
              });

              Fluttertoast.showToast(msg: "Group created.");
            } catch (e) {
              Fluttertoast.showToast(msg: "Create failed: $e");
            } finally {
              cmntController.clear();
              descController.clear();
              Navigator.of(context).pop();
            }
            // end
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Create'),
        ),
        ElevatedButton(
          onPressed: () {
            cmntController.clear();
            descController.clear();
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildGroupDialogFromMap(
      BuildContext context, Map<String, dynamic> g) {
    return AlertDialog(
      title: const Text('Group Description'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            (g['description'] ?? '') as String,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              Fluttertoast.showToast(msg: "Please sign in first.");
              return;
            }
            final name = (g['name'] ?? '') as String;
            final docId = "${user.uid}_${name.replaceAll(' ', '_')}";

            try {
              await FirebaseFirestore.instance
                  .collection('groupMembers')
                  .doc(docId)
                  .set({
                'groupName': name,
                'userUid': user.uid,
                'userEmail': user.email,
                'joinedAt': FieldValue.serverTimestamp(),
                'visibility': g['visibility'] ?? 'Public',
                'creatorEmail': g['creatorEmail'] ?? '',
              }, SetOptions(merge: true));

              Fluttertoast.showToast(msg: 'Joined "$name".');
              Navigator.of(context, rootNavigator: true).pop();
            } catch (e) {
              Fluttertoast.showToast(msg: "Join failed: $e");
            }
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Join'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildGroupDialog(BuildContext context, index) {
    return AlertDialog(
      title: const Text('Group Description'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(_groupList[index][3],
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12))
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            // show corresponding group description after click
            // your codes begin here
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              Fluttertoast.showToast(msg: "Please sign in first.");
              return;
            }

            final groupName = _groupList[index][0] as String;
            final docId = "${user.uid}_${groupName.replaceAll(' ', '_')}";

            try {
              await FirebaseFirestore.instance
                  .collection('groupMembers')
                  .doc(docId)
                  .set({
                'groupName': groupName,
                'userUid': user.uid,
                'userEmail': user.email,
                'joinedAt': FieldValue.serverTimestamp(),
                'visibility': _groupList[index][1],
                'creatorEmail': _groupList[index][2],
              }, SetOptions(merge: true));

              setState(() {
                _groupEntry[index] = true;
              });

              Fluttertoast.showToast(msg: "Joined \"$groupName\".");
              Navigator.of(context).pop();
            } catch (e) {
              Fluttertoast.showToast(msg: "Join failed: $e");
            }
            // end
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Join'),
        ),
        ElevatedButton(
          onPressed: () {
            // your codes begin here
            Navigator.of(context).pop();
            // end
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
    return Scaffold(
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
                          Icons.home,
                          size: 30.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Home()),
                          );
                        },
                      ),
                      SizedBox(width: 60),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade300),
                        child: const Text('Create a Group'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                _buildPopupDialog(context),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Existing Groups",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.indigo.shade300),
                  ),
                  SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                            height: 30,
                            width: 380,
                            alignment: Alignment.center,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                      width: 95,
                                      child: Text(
                                        "Name",
                                        style: TextStyle(
                                            color: Colors.indigo.shade500),
                                      )),
                                  Container(
                                      width: 75,
                                      child: Text(
                                        "Visibility",
                                        style: TextStyle(
                                            color: Colors.indigo.shade500),
                                      )),
                                  Container(
                                      width: 110,
                                      child: Text(
                                        "Creator",
                                        style: TextStyle(
                                            color: Colors.indigo.shade500),
                                      )),
                                  Container(width: 95, child: Text("")),
                                ])),
                      ]),
                  Divider(color: Colors.black),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('groups')
                          .snapshots(),
                      builder: (context, groupsSnap) {
                        if (groupsSnap.hasError) {
                          return Center(
                              child: Text('Error: ${groupsSnap.error}'));
                        }
                        if (!groupsSnap.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('groupMembers')
                              .where('userUid',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser?.uid)
                              .snapshots(),
                          builder: (context, memSnap) {
                            final joined = <String>{};
                            if (memSnap.hasData) {
                              for (final d in memSnap.data!.docs) {
                                final m = d.data() as Map<String, dynamic>;
                                final n = (m['groupName'] ?? '') as String;
                                if (n.isNotEmpty) joined.add(n);
                              }
                            }

                            final groups = groupsSnap.data!.docs
                                .map((d) => d.data() as Map<String, dynamic>)
                                .toList();

                            if (groups.isEmpty) {
                              return const Center(child: Text('No groups yet'));
                            }

                            return ListView.builder(
                              itemCount: groups.length,
                              itemBuilder: (context, index) {
                                final g = groups[index];
                                final name = (g['name'] ?? '') as String;
                                final visibility =
                                    (g['visibility'] ?? 'Public') as String;
                                final creator =
                                    (g['creatorEmail'] ?? '') as String;
                                final isJoined = joined.contains(name);

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 380,
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: 95,
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Colors.indigo.shade500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 50,
                                            child: Text(
                                              visibility,
                                              style: TextStyle(
                                                  color:
                                                      Colors.indigo.shade500),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 110,
                                            child: Text(
                                              creator,
                                              style: TextStyle(
                                                  color:
                                                      Colors.indigo.shade500),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 95,
                                            child: isJoined
                                                ? ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                Colors.indigo
                                                                    .shade300),
                                                    onPressed: () {},
                                                    child:
                                                        const Icon(Icons.check),
                                                  )
                                                : (visibility == 'Public'
                                                    ? ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .indigo
                                                                        .shade300),
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (_) =>
                                                                _buildGroupDialogFromMap(
                                                                    context, g),
                                                          );
                                                        },
                                                        child: const Text(
                                                          'Join Group',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 12),
                                                        ),
                                                      )
                                                    : ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .indigo
                                                                        .shade300),
                                                        onPressed:
                                                            null, // Private: 不可直接加入
                                                        child: const Icon(
                                                            Icons.lock),
                                                      )),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ))));
  }
}
