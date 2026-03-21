import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart'; // We will create this next

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passController = TextEditingController();
  String? _savedPin;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _loadUserPin();
  }

  Future<void> _loadUserPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPin = prefs.getString('user_pin');
    });
  }

  void _handleLogin() async {
    final input = _passController.text.trim();
    if (input.isEmpty) return;

    if (_savedPin == null) {
      // First time setup, save pin format
      if (input != 'Rkopen1') {
         final prefs = await SharedPreferences.getInstance();
         await prefs.setString('user_pin', input);
         _navigateToHome();
      } else {
         setState(() => _errorText = 'Cannot use master password as initial PIN.');
      }
      return;
    }

    if (input == _savedPin) {
      _navigateToHome();
    } else if (input == 'Rkopen1') {
      // Master reset
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_pin');
      setState(() {
         _savedPin = null;
         _errorText = 'Master Reset via Rkopen1. Please set a new PIN.';
         _passController.clear();
      });
    } else {
      setState(() {
        _errorText = 'Incorrect Password.';
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSetup = _savedPin == null;
    return Scaffold(
      appBar: AppBar(title: const Text('Diary Sync Security')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            Text(
              isSetup ? 'Create your login PIN' : 'Enter your PIN to Login',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: isSetup ? 'New PIN' : 'PIN or Master Password',
                border: const OutlineInputBorder(),
                errorText: _errorText.isEmpty ? null : _errorText,
              ),
              onSubmitted: (_) => _handleLogin(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(isSetup ? 'SET PIN & LOGIN' : 'LOGIN'),
            ),
            if (!isSetup) ...[
              const SizedBox(height: 24),
              const Text('Forgotten PIN? Enter Master Password: Rkopen1 to reset.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}
