import 'package:flutter/material.dart';
import '../core/database_helper.dart';
import '../models/log_entry.dart';
import '../core/excel_exporter.dart';
import 'add_log_screen.dart';
import 'sync_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<LogEntry> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await DatabaseHelper.instance.getAllLogs();
    setState(() {
      _logs = logs;
    });
  }

  Future<void> _exportExcel() async {
    try {
      final path = await ExcelExporter.exportLogsToExcel();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Exported to $path'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Export failed: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Sync Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_view),
            onPressed: _exportExcel,
            tooltip: 'Export to Excel',
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
               await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SyncScreen()));
               _loadLogs(); // refresh after syncing
            },
            tooltip: 'Sync Devices',
          ),
        ],
      ),
      body: _logs.isEmpty
          ? const Center(child: Text('No Logs yet. Add one!'))
          : ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${log.date} ${log.time} - ${log.whomMet}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.description),
                        if (log.reminderTime != null && log.reminderTime!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.alarm, size: 14, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  log.reminderTime!,
                                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                    trailing: log.isSynced == 1 
                        ? const Icon(Icons.cloud_done, color: Colors.green, size: 20)
                        : const Icon(Icons.cloud_upload_outlined, color: Colors.grey, size: 20),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddLogScreen())
          );
          _loadLogs(); // Refresh after adding
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
