import 'package:flutter/material.dart';
import '../core/database_helper.dart';
import '../models/log_entry.dart';
import '../utils/nlp_parser.dart';
import '../services/voice_service.dart';
import '../services/notification_service.dart';

class AddLogScreen extends StatefulWidget {
  const AddLogScreen({Key? key}) : super(key: key);

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final VoiceService _voiceService = VoiceService();

  // Mode A Controllers
  final _whomMetCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _reminderCtrl = TextEditingController();
  
  // Mode B Controller
  final _smartTextCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _voiceService.init();
  }

  String _generateUuid() => DateTime.now().millisecondsSinceEpoch.toString() + _whomMetCtrl.text.hashCode.toString();

  Future<void> _saveLog(Map<String, String?> data, String desc) async {
    int sno = await DatabaseHelper.instance.getNextSno();
    
    LogEntry entry = LogEntry(
      uuid: _generateUuid(),
      sno: sno,
      date: data['date'] ?? DateTime.now().toString().split(' ')[0],
      time: data['time'] ?? "${DateTime.now().hour}:${DateTime.now().minute}",
      whomMet: data['whomMet'] ?? 'Unknown',
      description: desc,
      reminderTime: data['reminderTask'],
      isSynced: 0,
    );

    await DatabaseHelper.instance.insertLog(entry);
    
    if (data['reminderTask'] != null && data['reminderTask']!.isNotEmpty) {
        // Trigger local notification logic
        _showReminderDialog(entry);
    } else {
        if (mounted) Navigator.of(context).pop();
    }
  }

  void _showReminderDialog(LogEntry entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Schedule Reminder'),
        content: Text('Set reminder for: ${entry.reminderTime}'),
        actions: [
          TextButton(onPressed: () {
             NotificationService().scheduleReminder(
               id: entry.sno, 
               title: 'Reminder: ${entry.whomMet}', 
               body: entry.reminderTime!, 
               scheduledDate: DateTime.now().add(const Duration(minutes: 15))
             );
             Navigator.of(context).pop();
             Navigator.of(context).pop();
          }, child: const Text('15m before')),
          TextButton(onPressed: () {
             NotificationService().scheduleReminder(
               id: entry.sno, 
               title: 'Reminder: ${entry.whomMet}', 
               body: entry.reminderTime!, 
               scheduledDate: DateTime.now().add(const Duration(minutes: 30))
             );
             Navigator.of(context).pop();
             Navigator.of(context).pop();
          }, child: const Text('30m before')),
        ],
      )
    );
  }

  Widget _buildModeA() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildVoiceField('Whom Met', _whomMetCtrl),
        const SizedBox(height: 16),
        _buildVoiceField('Description', _descCtrl, maxLines: 3),
        const SizedBox(height: 16),
        _buildVoiceField('Reminder Task (Optional)', _reminderCtrl),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            _saveLog({
              'whomMet': _whomMetCtrl.text,
              'reminderTask': _reminderCtrl.text,
            }, _descCtrl.text);
          },
          child: const Text('Save Log'),
        )
      ],
    );
  }

  Widget _buildModeB() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _smartTextCtrl,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'e.g. Met Ravi today at 4pm, he asked me to send the report tomorrow.',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
               final parsed = NLPParser.parseSmartText(_smartTextCtrl.text);
               _saveLog(parsed, _smartTextCtrl.text);
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Analyze & Save'),
          )
        ],
      ),
    );
  }

  Widget _buildVoiceField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: Icon(_voiceService.isListening ? Icons.mic : Icons.mic_none, color: Colors.blue),
          onPressed: () {
            if (_voiceService.isListening) {
               _voiceService.stopListening();
               setState(() {});
            } else {
               _voiceService.startListening((text) {
                 setState(() { controller.text = text; });
               });
               setState(() {});
            }
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Log Entry'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Step-by-Step'),
            Tab(text: 'Smart Input'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildModeA(),
          Column(children: [ Expanded(child: _buildModeB()) ]),
        ],
      ),
    );
  }
}
