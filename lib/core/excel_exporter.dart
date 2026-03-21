import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/log_entry.dart';
import 'database_helper.dart';

class ExcelExporter {
  static Future<String> exportLogsToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Logs'];
    
    // Header Row
    sheetObject.appendRow([
      TextCellValue('S.No'),
      TextCellValue('Date'),
      TextCellValue('Time'),
      TextCellValue('Whom Met'),
      TextCellValue('Description'),
      TextCellValue('Reminder'),
    ]);

    // Data Rows
    List<LogEntry> logs = await DatabaseHelper.instance.getAllLogs();
    
    // Sort by Date + Time descending
    logs.sort((a, b) {
      int dateCmp = b.date.compareTo(a.date);
      if (dateCmp != 0) return dateCmp;
      return b.time.compareTo(a.time);
    });

    for (var log in logs) {
      sheetObject.appendRow([
        IntCellValue(log.sno),
        TextCellValue(log.date),
        TextCellValue(log.time),
        TextCellValue(log.whomMet),
        TextCellValue(log.description),
        TextCellValue(log.reminderTime ?? ''),
      ]);
    }

    // Save File
    var fileBytes = excel.save();
    Directory dir;
    if (Platform.isAndroid) {
      // In a real app we might use permission handler and save to Downloads
      // For this implementation, getExternalStorageDirectory works for internal app folder
      dir = (await getExternalStorageDirectory()) ?? await getApplicationSupportDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    
    final path = '${dir.path}/diary_logs_export.xlsx';
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
      
    return path;
  }
}
