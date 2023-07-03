import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsLayout extends StatefulWidget {
  const SettingsLayout({super.key});

  @override
  State<SettingsLayout> createState() => _SettingsLayoutState();
}

class _SettingsLayoutState extends State<SettingsLayout> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  int _timerHours = 0;
  int _timerMinutes = 4;
  int _timerSeconds = 0;
  bool _DND = false;
  bool _immersiveMode = false;

  Duration _duration = Duration(hours: 0, minutes: 0, seconds: 0);

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _timerHours = (prefs.getInt('timerHours') ?? 0);
      _timerMinutes = (prefs.getInt('timerMinutes') ?? 0);
      _timerSeconds = (prefs.getInt('timerSeconds') ?? 5);

      //_timerString = sprintf("%02i:%02i:%02i", [_timerHours,_timerMinutes,_timerSeconds]);
      _duration = Duration(hours: _timerHours, minutes: _timerMinutes);

      _DND = (prefs.getBool('DND') ?? false);
      _immersiveMode = (prefs.getBool('immersiveMode') ?? false);
    });
  }

  void saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _timerHours = _duration.inHours;
    _timerMinutes = _duration.inMinutes - (_timerHours*60);
    _timerSeconds = _duration.inSeconds - (_timerHours*3600)-(_timerMinutes*60);

    prefs.setInt('timerHours', _timerHours);
    prefs.setInt('timerMinutes', _timerMinutes);
    prefs.setInt('timerSeconds', _timerSeconds);

    prefs.setBool('DND', _DND);
    prefs.setBool('immersiveMode', _immersiveMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Timer Settings:",
                style: TextStyle(fontSize: 25.0),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              DurationPicker(
                duration: _duration,
                onChange: (val){
                  setState(() {
                    _duration = val;
                  });
                  saveSettings();
                },
              ),
              ]
            ),
            const Divider(
              height: 30,
              thickness: 2,
              indent: 20,
              endIndent: 20,
              color: Colors.black12,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Sessions Settings:",
                style: TextStyle(fontSize: 25.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                              "DND Mode:",
                              style: TextStyle(fontSize: 20.0)
                          ),
                          Switch(
                            value: _DND,
                            onChanged: (value) {
                              setState(() {
                                _DND = value;
                              });
                              saveSettings();
                            },
                          ),
                        ]
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                              "Immersive Mode:",
                              style: TextStyle(fontSize: 20.0)
                          ),
                          Switch(
                            value: _immersiveMode,
                            onChanged: (value) {
                              setState(() {
                                _immersiveMode = value;
                              });
                              saveSettings();
                            },
                          ),
                        ]
                    ),
                    ],
              ),
            ),
          ]
      ),
    );
  }
/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 30),
              Text("Timer settings"),
              DurationPicker(
                duration: _duration,
                onChange: (val){
                  setState(() {
                    _duration = val;
                  });
                  saveSettings();
                },
              ),
              Text('$_duration'),
              Text('$_timerHours'),
              Text('$_timerMinutes'),
              Text('$_timerSeconds'),
              Switch(
                  value: _DND,
                  onChanged: (value) {
                    setState(() {
                      _DND = value;
                    });
                  },
              ),
            ]
        ),
      ),
    );
  }*/

  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
              title: Text('Timer settings:'),
              tiles: <SettingsTile>[
                SettingsTile(
                  leading: Icon(Icons.timer),
                  title: Text('Timer Duration'),
                  value: Text('Set the timer duration'),
                  onPressed: (BuildContext context) => AlertDialog(
                    title: const Text('Abbandonare la sessione?'),
                    content: const Text('Sei sicuro di voler interrompere la sessione in corso?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Abbandona'),
                        child: const Text('Abbandona'),
                      ),
                    ],
                  ),
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
  }*/
}

