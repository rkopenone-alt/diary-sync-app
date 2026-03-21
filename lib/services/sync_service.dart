import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import '../core/database_helper.dart';
import '../models/log_entry.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  HttpServer? _server;
  final int port = 8080;

  Future<void> startServer() async {
    if (_server != null) return; // Already running

    final router = Router();
    
    // Endpoint to receive logs and return local logs
    router.post('/api/sync', (Request request) async {
       try {
         final payload = await request.readAsString();
         final List<dynamic> jsonList = jsonDecode(payload);
         final externalLogs = jsonList.map((j) => LogEntry.fromMap(j)).toList();
         
         // 1. Merge received logs into local DB
         await DatabaseHelper.instance.mergeLogs(externalLogs);
         
         // 2. Fetch all local logs to send back
         final allLocalLogs = await DatabaseHelper.instance.getAllLogs();
         
         return Response.ok(
           jsonEncode(allLocalLogs.map((e) => e.toMap()).toList()),
           headers: {'Content-Type': 'application/json'}
         );
       } catch (e) {
         return Response.internalServerError(body: e.toString());
       }
    });

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router.call);

    _server = await io.serve(handler, InternetAddress.anyIPv4, port);
    print('Sync Server running on port ${_server!.port}');
  }

  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<List<String>> getLocalIpAddresses() async {
    List<String> ips = [];
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: false,
    );
    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (!addr.isLoopback) {
          ips.add(addr.address);
        }
      }
    }
    return ips;
  }

  Future<bool> syncWithDevice(String targetIp) async {
    try {
      final localLogs = await DatabaseHelper.instance.getAllLogs();
      final payload = jsonEncode(localLogs.map((e) => e.toMap()).toList());

      final response = await http.post(
        Uri.parse('http://$targetIp:$port/api/sync'),
        headers: {'Content-Type': 'application/json'},
        body: payload,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final externalLogs = jsonList.map((j) => LogEntry.fromMap(j)).toList();
        
        // Merge the response back into our local DB
        await DatabaseHelper.instance.mergeLogs(externalLogs);
        return true;
      }
      return false;
    } catch (e) {
      print('Sync error: $e');
      return false;
    }
  }
}
