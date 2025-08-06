import 'package:flutter/material.dart';
import 'package:mobile_app/dailies.dart';
import 'package:mobile_app/home.dart';
import 'package:mobile_app/main.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Excercise extends StatelessWidget {
  const Excercise({super.key});

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

enum TtsState { playing, stopped, paused, continued }

class _MyHomePageState extends State<MyHomePage> {
  late FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;
  static const String _title = 'Excercise';

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    // Start handler, mostly for changing state to playing
    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });
  }

  Widget _buildJournalDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Cardio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              "1. Walk at a speed between 3.0 and 4.0 mph.\n\n2. Increase the incline every minute, starting at zero and ending at 15. This is the maximum incline you should go, but it's also okay to stop at an incline that's comfortable for you, which could be anywhere between seven and 10. \n\n3. Once you reach your maximum incline, go back down every minute until you reach zero. \n\n4. Cool down with a five- to eight-minute easy walk, followed by stretching.",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          IconButton(
            icon: Icon(Icons.volume_up), //todo: Cancel icon shows when ttsState is playing
            onPressed: () {
              if (ttsState == TtsState.stopped) {
                _speak(
                  "1. Walk at a speed between 3.0 and 4.0 mph. 2. Increase the incline every minute, starting at zero and ending at 15. This is the maximum incline you should go, but it's also okay to stop at an incline that's comfortable for you, which could be anywhere between seven and 10. 3. Once you reach your maximum incline, go back down every minute until you reach zero. 4. Cool down with a five- to eight-minute easy walk, followed by stretching.",
                );
              } else {
                _stop();
              }
              setState(() {});
            },
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            if (ttsState == TtsState.playing) {
              _stop();
            }
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildProfileDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Yoga'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              "1. Get on your hands and knees, with your neck in a neutral position. \n2. Keep your wrists directly under your shoulders and your knees directly under your hips. \n3. Inhaling into cow pose, arch your back so that your belly approaches the mat, lifting your chest and chin.\n4. Exhale into cat pose, drawing your navel in while rounding your back and letting gravity drop your head toward the floor.",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          IconButton(
              icon: Icon(Icons.volume_up),
              onPressed: () {
              if (ttsState == TtsState.stopped) {
                _speak(
                  "1. Get on your hands and knees, with your neck in a neutral position. 2. Keep your wrists directly under your shoulders and your knees directly under your hips. 3. Inhaling into cow pose, arch your back so that your belly approaches the mat, lifting your chest and chin. 4. Exhale into cat pose, drawing your navel in while rounding your back and letting gravity drop your head toward the floor.",
                );
              } else {
                _stop();
              }
              setState(() {});
              },)
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            if (ttsState == TtsState.playing) {
              _stop();
            }
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildMapDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Weight Lifting'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              'Legs: dumbbell squats — 3 sets of 6–8 reps \n Shoulders: standing shoulder press — 3 sets of 6–8 reps \nLegs: dumbbell lunge — 2 sets of 8–10 reps per leg ',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          IconButton(
              icon: Icon(Icons.volume_up),
              onPressed: () {
              if (ttsState == TtsState.stopped) {
                _speak(
                  "Legs: dumbbell squats — 3 sets of 6–8 reps. Shoulders: standing shoulder press — 3 sets of 6–8 reps. Legs: dumbbell lunge — 2 sets of 8–10 reps per leg.",
                );
              } else {
                _stop();
              }
              setState(() {});
              },)
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            if (ttsState == TtsState.playing) {
              _stop();
            }
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future _speak(newVoiceText) async {
    var result = await flutterTts.speak(newVoiceText!);
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.indigo,
            // and so on for every text style
          ),
        ),
        title: _title,
        home: Scaffold(
            appBar: AppBar(title: const Text(_title)),
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
                                    builder: (context) => const Dailies()),
                              );
                            },
                          ),
                          SizedBox(width: 80),
                          Text(
                            "Exercises",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.indigo.shade300),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            '\nPlease click on the button for some exercise ideas!',
                            style: TextStyle(fontSize: 20),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo.shade300),
                            child: Text('Cardio',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 12)),
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
                                backgroundColor: Colors.indigo.shade300),
                            child: Text('Yoga',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 12)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _buildMapDialog(context),
                              );
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo.shade300),
                            child: Text('Weight Lifting',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 12)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _buildProfileDialog(context),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                )))));
  }
}
