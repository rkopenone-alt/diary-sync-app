import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final SyncService _syncService = SyncService();
  final TextEditingController _ipController = TextEditingController();
  List<String> _localIps = [];
  bool _isSyncing = false;
  bool _serverRunning = false;

  @override
  void initState() {
    super.initState();
    _initSyncNode();
  }

  Future<void> _initSyncNode() async {
    final ips = await _syncService.getLocalIpAddresses();
    setState(() {
      _localIps = ips;
    });
    await _syncService.startServer();
    setState(() {
      _serverRunning = true;
    });
  }

  @override
  void dispose() {
    // We can keep the server running globally if desired, 
    // but for security it's better to stop when leaving sync screen.
    _syncService.stopServer();
    super.dispose();
  }

  Future<void> _startSync() async {
    if (_ipController.text.isEmpty) return;

    setState(() { _isSyncing = true; });
    
    bool success = await _syncService.syncWithDevice(_ipController.text.trim());
    
    setState(() { _isSyncing = false; });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Sync Completed Successfully!' : 'Sync Failed. Check IP.'),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Pairing & Sync')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Offline Sync Engine',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Ensure both devices are on the same Wi-Fi network.'),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('This Device IP (Run Sync App on other device to connect):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_localIps.isEmpty) const Text('No active Wi-Fi connection detected.'),
                  for (var ip in _localIps)
                    Text(ip, style: const TextStyle(fontSize: 18, color: Colors.blue)),
                  const SizedBox(height: 8),
                  Text(_serverRunning ? '✓ Receiving Server Active' : 'Starting Server...'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Connect to Paired Device:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Enter IP of the other device',
                hintText: 'e.g. 192.168.1.5',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _startSync,
                icon: _isSyncing ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.sync),
                label: Text(_isSyncing ? 'Syncing...' : 'START SYNC'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
