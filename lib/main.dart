import 'dart:async';

import 'package:flutter/material.dart';
import 'package:focusboostapp_flutter/stats_model.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';
import 'package:focusboostapp_flutter/Settings.dart';
import 'package:focusboostapp_flutter/Stats.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart'; // For `SystemChrome`



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusBoostApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'FocusBoostApp'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({Key? key, required this.title}) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  //-------Settings Value:-------
  int _timerHours = 0;
  int _timerMinutes = 0;
  int _timerSeconds = 0;
  bool _DND = false;
  bool _immersiveMode = false;
  //-----------------------------

  //-----------Stats-------------
  var _startTimestamp;
  var _stopTimestamp;
  //-----------------------------

  int _time = 0;
  int _timeSetted = 0;
  double _percent = 1;
  String _timerString = "";
  String _timerLength = "";
  late Timer timer;
  bool _isRunning = false;
  bool _completedSession = false;

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _timerHours = (prefs.getInt('timerHours') ?? 0);
      _timerMinutes = (prefs.getInt('timerMinutes') ?? 0);
      _timerSeconds = (prefs.getInt('timerSeconds') ?? 5);

      _timerString = sprintf("%02i:%02i:%02i", [_timerHours,_timerMinutes,_timerSeconds]);
      _timerLength = sprintf("%02i:%02i:%02i", [_timerHours,_timerMinutes,_timerSeconds]);

      _DND = (prefs.getBool('DND') ?? false);
      _immersiveMode = (prefs.getBool('immersiveMode') ?? false);
    });
  }

  void settings(){
    Navigator.push(context,
        MaterialPageRoute(builder: (context) {
          return SettingsLayout();}));
  }

  void statistics(){
    Navigator.push(context,
        MaterialPageRoute(builder: (context) {
          return StatsLayout();}));
  }

  void enableDnd() async{
    final bool? isNotificationPolicyAccessGranted =
    await FlutterDnd.isNotificationPolicyAccessGranted;
    if (isNotificationPolicyAccessGranted != null){
      if(isNotificationPolicyAccessGranted){
        await FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_NONE);
      }else{
        FlutterDnd.gotoPolicySettings();
        await FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_NONE);
      }
    }
  }

  void disableDnd() async {
    await FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_ALL);
  }

  void enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  Future<void> saveStatsToDB(Stats stats) async {
    final database = openDatabase(
        path.join(await getDatabasesPath(), 'stats_database.db'),
        onCreate: (db, version) {
    return db.execute(
    'CREATE TABLE stats(id INTEGER PRIMARY KEY AUTOINCREMENT, startTimestamp TEXT, stopTimestamp TEXT, timer TEXT, completedSession INTEGER, DND INTEGER, immersiveMode INTEGER)',
    );
    },
    version: 1,
    );

    final db = await database;

    await db.insert(
      'stats',
      stats.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void startTimer(){
    _completedSession = false;
    _isRunning = true;
    _time = (_timerHours*3600*100)+(_timerMinutes*60*100)+_timerSeconds*100;
    _timeSetted = _time;
    _startTimestamp = DateFormat('MMM d, h:mm a').format(DateTime.now());

    //DND Mode
    if(_DND){
     //set DND mode
      enableDnd();
    }

    //Immersive Mode
    if(_immersiveMode){
      enterFullScreen();
    }

    timer = Timer.periodic(Duration(milliseconds: 10),(timer){
      setState(() {
        if(_time>0) {
          _time--;
          _percent = _time/_timeSetted;

          _timerHours = _time~/360000;
          _timerMinutes = (_time~/6000)-(_timerHours*60);
          _timerSeconds = (_time~/100)%60;

          _timerString = sprintf("%02i:%02i:%02i", [_timerHours,_timerMinutes,_timerSeconds]);
        }
        if(_time==10) {
          _completedSession = true;
          stopTimer();
        }
      });
    });
  }

  Future<void> stopTimer() async {
    timer.cancel();
    _percent=1;
    _isRunning = false;
    _stopTimestamp = DateFormat('MMM d, h:mm a').format(DateTime.now());
    _loadSettings(); //in teoria non serve

    //Disable DND if active
    if(_DND){
      disableDnd();
    }

    //Disable Immersive Mode if active
    if(_immersiveMode){
      exitFullScreen();
    }

    var sessionStats = Stats(
      startTimestamp: _startTimestamp,
      stopTimestamp: _stopTimestamp,
      timer: _timerLength,
        //completedSession:1,
        //immersiveMode: 1,
        //DND: 1
      completedSession: _completedSession ? 1 : 0,
      immersiveMode: _immersiveMode ? 1 : 0,
      DND: _DND ? 1 : 0
    );

    await saveStatsToDB(sessionStats);
  }

  @override
  Widget build(BuildContext context) {
    _loadSettings();
    return Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 120), // <-- Set height
          CircularPercentIndicator(
            progressColor: Colors.blue,
            lineWidth: 15,
            backgroundColor: Colors.white,
            startAngle: 180,
            circularStrokeCap: CircularStrokeCap.round,
            radius: 140,
            percent: _percent,
            center: Text(_timerString,
              style: Theme.of(context).textTheme.headline4,
            ),
            // the valueColor property takes the preference
            // over color property
          ),
          SizedBox(height: 60), // <-- Set height
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            ElevatedButton(
              onPressed: _isRunning ? null : startTimer,
              child: const Text("Start"),
            ),
            SizedBox(width: 80), // <-- Set height
            ElevatedButton(
              onPressed: !_isRunning ? null : () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Abbandonare la sessione?'),
                  content: const Text('Sei sicuro di voler interrompere la sessione in corso?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => [stopTimer(), Navigator.pop(context, 'Abbandona')],
                      child: const Text('Abbandona'),
                    ),
                  ],
                ),
              ),
              child: Text("Stop"),
            ),
          ]
          ),
        ],
      ),
    ),
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: settings,
                child: Icon(Icons.settings),
                heroTag: "settings",
              ),
              const SizedBox(height: 20),
              FloatingActionButton(
                onPressed: statistics,
                child: Icon(Icons.bar_chart),
                heroTag: "stats",
              ),
            ]
        )
    );
  }
}

/*class SettingsLayout extends StatelessWidget{
  SettingsLayout({Key? key, required this.title}): super(key: key);
  final String title;
  Duration _duration = Duration(hours: 0, minutes: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
              title: Text('Timer settings:'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: Icon(Icons.timer),
                  title: Text('Timer Duration'),
                  value: Text('Set the timer duration'),
                )]
          ),
          SettingsSection(
            title: Text('Sessions settings:'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: Icon(Icons.do_disturb_on_outlined),
                title: Text('Enable Do Not Disturb'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: Icon(Icons.fullscreen),
                title: Text('Enable Immersive Mode'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}*/

/*
class StatsLayout extends StatelessWidget {
  StatsLayout({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: Text("Stats"),
        )
    );
  }
}*/

