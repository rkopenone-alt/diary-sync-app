class LogEntry {
  final String uuid;
  final int sno;
  final String date;  // format: yyyy-MM-dd
  final String time;  // format: HH:mm
  final String whomMet;
  final String description;
  final String? reminderTime; // format: yyyy-MM-dd HH:mm:ss
  final int isSynced;

  LogEntry({
    required this.uuid,
    required this.sno,
    required this.date,
    required this.time,
    required this.whomMet,
    required this.description,
    this.reminderTime,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'sno': sno,
      'date': date,
      'time': time,
      'whomMet': whomMet,
      'description': description,
      'reminderTime': reminderTime,
      'isSynced': isSynced,
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      uuid: map['uuid'],
      sno: map['sno'],
      date: map['date'],
      time: map['time'],
      whomMet: map['whomMet'],
      description: map['description'],
      reminderTime: map['reminderTime'],
      isSynced: map['isSynced'] ?? 0,
    );
  }

  // Create a copy of the object with updated fields
  LogEntry copyWith({
    String? uuid,
    int? sno,
    String? date,
    String? time,
    String? whomMet,
    String? description,
    String? reminderTime,
    int? isSynced,
  }) {
    return LogEntry(
      uuid: uuid ?? this.uuid,
      sno: sno ?? this.sno,
      date: date ?? this.date,
      time: time ?? this.time,
      whomMet: whomMet ?? this.whomMet,
      description: description ?? this.description,
      reminderTime: reminderTime ?? this.reminderTime,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
