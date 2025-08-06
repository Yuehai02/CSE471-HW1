import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_app/dailies.dart';
import 'package:mobile_app/home.dart';
import 'package:mobile_app/main.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class Walking extends StatelessWidget {
  const Walking({super.key});

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

  Future _speak(newVoiceText) async {
    var result = await flutterTts.speak(newVoiceText!);
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Widget _buildJournalDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('The Body Scan Meditation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              " Focus on your feet. Feel the firm ground beneath you as each foot rolls from heel to toe. Try to hold awareness of your steps for 2 to 3 minutes.",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          IconButton(
              icon: Icon(Icons.volume_up),
              onPressed: () {
                if (ttsState == TtsState.stopped) {
                  _speak("Focus on your feet. Feel the firm ground beneath you as each foot rolls from heel to toe. Try to hold awareness of your steps for 2 to 3 minutes."
                      );
                } else {
                  _stop();
                }
                setState(() {});
              }),
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
      title: const Text('Brainpower Booster'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              "Changing the direction you walk—forward, backward, or sideways—keeps your mind alert, turns up your calorie burn, and activates some often-underused muscles, such as your outer and inner thighs. This routine is best done on a school track (most are ¼-mile around)..",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          IconButton(
              icon: Icon(Icons.volume_up),
              onPressed: () {
                if (ttsState == TtsState.stopped) {
                  _speak("Changing the direction you walk—forward, backward, or sideways—keeps your mind alert, turns up your calorie burn, and activates some often-underused muscles, such as your outer and inner thighs. This routine is best done on a school track (most are ¼-mile around)"
                      );
                } else {
                  _stop();
                }
                setState(() {});
              }),

        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed:() {
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
      title: const Text('Head For The Trees'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              "A dose of nature can boost your mood and energize you in just 5 minutes. If you exercise in a natural setting and go longer (a lunchtime stroll in a park or an all-day hike in the mountains), you can improve your memory and attention 20% more than you can by walking in an urban environment.",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          IconButton(
              icon: Icon(Icons.volume_up),
              onPressed: () {
                if (ttsState == TtsState.stopped) {
                  _speak("A dose of nature can boost your mood and energize you in just 5 minutes. If you exercise in a natural setting and go longer (a lunchtime stroll in a park or an all-day hike in the mountains), you can improve your memory and attention 20% more than you can by walking in an urban environment."
                      );
                } else {
                  _stop();
                }
                setState(() {});
              }),
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
                            "Walking",
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
                            child: Text('Happiness Walk',
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
                            child: Text('Brainpower Booster',
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
                            child: Text('Head For The Trees',
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
