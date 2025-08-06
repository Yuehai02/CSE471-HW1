import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_app/dailies.dart';
import 'package:mobile_app/home.dart';
import 'package:mobile_app/main.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class Meditation extends StatelessWidget {
  const Meditation({super.key});

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
              "1. Get into a comfortable position. You can sit or lie down.\n2. Close your eyes for a deeper practice.\n3. Starting with your feet and toes, tune into and pay attention to any sensations you feel, like pain or discomfort. You may also notice sensations like tingling, stinging, aching or throbbing.\n4.  Take a nice deep breath in through your nose, exhaling through the mouth, releasing the uncomfortable sensation. Allow that area of your body to release, loosen up, and soften.\n5. Work your way up the body, paying attention to how you feel as you focus on the legs, the hips, the back, the stomach, the chest, the neck and shoulders, the arms and hands, and finally the face.",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          IconButton(
              icon: Icon(Icons.volume_up),
              onPressed: () {
                if (ttsState == TtsState.stopped) {
                  _speak(
                      "1. Get into a comfortable position. You can sit or lie down. 2. Close your eyes for a deeper practice. 3. Starting with your feet and toes, tune into and pay attention to any sensations you feel, like pain or discomfort. You may also notice sensations like tingling, stinging, aching or throbbing. 4.  Take a nice deep breath in through your nose, exhaling through the mouth, releasing the uncomfortable sensation. Allow that area of your body to release, loosen up, and soften. 5. Work your way up the body, paying attention to how you feel as you focus on the legs, the hips, the back, the stomach, the chest, the neck and shoulders, the arms and hands, and finally the face.");
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
      title: const Text('Progressive muscle relaxation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              "Get into a comfortable position, either sitting or lying down.\n 2. Strive to tense and then release each large muscle or muscle group for about five seconds or so, then relax the muscles.\n3. Begin by taking a few deep breaths from the abdomen. Tense, hold, and relax each large muscle group, working your way up or down the body.\n4. Try and notice the contrast between a tensed state and a relaxed state inhaling as you tense the muscle and exhaling as you relax and let go.",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          IconButton(
              icon: Icon(Icons.volume_up),
              onPressed: () {
                if (ttsState == TtsState.stopped) {
                  _speak(
                      "Get into a comfortable position, either sitting or lying down. 2. Strive to tense and then release each large muscle or muscle group for about five seconds or so, then relax the muscles. 3. Begin by taking a few deep breaths from the abdomen. Tense, hold, and relax each large muscle group, working your way up or down the body. 4. Try and notice the contrast between a tensed state and a relaxed state inhaling as you tense the muscle and exhaling as you relax and let go.");
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

  Widget _buildMapDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('The blackboard technique'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              "1.Start by closing your eyes and picturing a huge blackboard. The blackboard can be as big as you are.\n 2. Now in your imagination, take the chalk and write down the number 100 on the board as large as you can write it.\n3. Then erase the number away as slowly as you can, making sure that all of the chalk is removed from the blackboard.\n4. Write the number 99 next, then erasing it very slowly.\n5. Continue counting down until you fall asleep or reach zero when the task begins again.",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          IconButton(
            icon: Icon(Icons.volume_up),
            onPressed: () {
              if (ttsState == TtsState.stopped) {
                _speak(
                    "1.Start by closing your eyes and picturing a huge blackboard. The blackboard can be as big as you are. 2. Now in your imagination, take the chalk and write down the number 100 on the board as large as you can write it. 3. Then erase the number away as slowly as you can, making sure that all of the chalk is removed from the blackboard. 4. Write the number 99 next, then erasing it very slowly. 5. Continue counting down until you fall asleep or reach zero when the task begins again.");
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
                            "Meditation",
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
                            child: Text('The Body Scan Meditation',
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
                            child: Text('The Blackboard technique',
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
                            child: Text('Progressive muscle relaxation',
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
