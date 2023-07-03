import 'package:flutter/material.dart';
import 'package:focusboostapp_flutter/stats_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class StatsLayout extends StatefulWidget {
  const StatsLayout({super.key});

  @override
  State<StatsLayout> createState() => _StatsLayoutState();
}

class _StatsLayoutState extends State<StatsLayout> {
  List<Stats> _userStats = List<Stats>.empty();

  @override
  void initState() {
    super.initState();
    getStats();
  }

  void getStats() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'stats_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE stats(id INTEGER PRIMARY KEY AUTOINCREMENT, startTimestamp TEXT, stopTimestamp TEXT, timer TEXT, completedSession BOOLEAN, DND BOOLEAN, immersiveMode BOOLEAN)',
        );
      },
      version: 1,
    );

    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('stats', orderBy: 'id DESC');

    setState(() {
      _userStats = List.generate(maps.length, (i) {
        return Stats(
            startTimestamp: maps[i]['startTimestamp'],
            stopTimestamp: maps[i]['stopTimestamp'],
            timer: maps[i]['timer'],
            completedSession: maps[i]['completedSession'],
            DND: maps[i]['DND'],
            immersiveMode: maps[i]['immersiveMode']
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: _userStats.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildPlayerModelList(_userStats[index]);
          },
        ),
      ),
    );
  }

  Widget _buildPlayerModelList(Stats items) {
    return Card(
      child: ExpansionTile(
        title: Text(
          items.startTimestamp,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        children: <Widget>[
          ListTile(
            title: Text(
              "Session started: " + items.startTimestamp.toString(),
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ListTile(
            title: Text(
              "Session ended: " + items.stopTimestamp.toString(),
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ListTile(
            title: Text(
              "Session result: " + (items.completedSession == 1 ? "Completed" : "Failed"),
              style: TextStyle(fontWeight: FontWeight.w700, color: items.completedSession == 1 ? Colors.green : Colors.redAccent),
            ),
          ),
          ListTile(
            title: Text(
              "Session length: " + items.timer,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ListTile(
            title: Text(
              "DND mode: " + (items.DND == 1 ? "Enabled" : "Disabled"),
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ListTile(
            title: Text(
              "Immersive Mode: " + (items.immersiveMode==1 ? "Enabled" : "Disabled"),
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

