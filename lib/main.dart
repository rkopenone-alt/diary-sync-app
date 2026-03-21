import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const DiarySyncApp());
}

class DiarySyncApp extends StatelessWidget {
  const DiarySyncApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary Sync Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
