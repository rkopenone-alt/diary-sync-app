class NLPParser {
  /// Extracts { name, date, time, reminderTask } from raw text
  static Map<String, String?> parseSmartText(String text) {
    Map<String, String?> result = {
      'whomMet': null,
      'date': null,
      'time': null,
      'reminderTask': null,
    };

    // 1. Extract Whomet
    // Very simple offline heuristic looking for Capitalized words after "Met", "met with", "Meeting"
    RegExp nameExp = RegExp(r'(?i)(met|meeting) (with )?([A-Z][a-z]+) (and ([A-Z][a-z]+))?');
    var nameMatch = nameExp.firstMatch(text);
    if (nameMatch != null && nameMatch.groupCount >= 3) {
      result['whomMet'] = nameMatch.group(3); // First identified name
    }

    // 2. Extract relative Date
    if (text.toLowerCase().contains("tomorrow")) {
      result['date'] = _getDateString(1);
    } else if (text.toLowerCase().contains("today")) {
      result['date'] = _getDateString(0);
    }

    // 3. Extract time (e.g., 4am, 4 am, 10:00 PM)
    RegExp timeExp = RegExp(r'(\d{1,2}(:\d{2})?\s?(am|pm|AM|PM))');
    var timeMatch = timeExp.firstMatch(text);
    if (timeMatch != null) {
      result['time'] = timeMatch.group(0);
    }

    // 4. Extract Tasks for Reminders
    List<String> taskKeywords = ['ask', 'send', 'remind', 'meet', 'follow up'];
    List<String> sentences = text.split(RegExp(r'[,.!?]| and '));
    for (String s in sentences) {
      if (taskKeywords.any((k) => s.toLowerCase().contains(k))) {
        result['reminderTask'] = s.trim();
        break; // take first found task
      }
    }

    // Default fallbacks if parsing fails
    result['date'] ??= _getDateString(0);
    result['time'] ??= "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";
    result['whomMet'] ??= "Unknown";

    return result;
  }

  static String _getDateString(int offsetDays) {
    DateTime dt = DateTime.now().add(Duration(days: offsetDays));
    return "${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}";
  }
}
