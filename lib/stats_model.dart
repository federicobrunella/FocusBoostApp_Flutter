
class Stats {
  //final int id;
  final String startTimestamp;
  final String stopTimestamp;
  final int DND;
  final int immersiveMode;
  final String timer;
  final int completedSession;

  Stats({ required this.startTimestamp,
    required this.stopTimestamp,
    required this.timer,
    required this.completedSession,
    required this.DND,
    required this.immersiveMode});

  // Convert into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'startTimestamp': startTimestamp,
      'stopTimestamp': stopTimestamp,
      'timer' : timer,
      'completedSession' : completedSession,
      'DND' : DND,
      'immersiveMode' : immersiveMode
    };

  }
}
