import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscure = true;
  String? _error;
  bool _loading = false;

  Future<void> _login() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final username = _userController.text.trim();
    final password = _passController.text;
    try {
      // Check credentials
      final userSnap =
          await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .where('password', isEqualTo: password)
              .limit(1)
              .get();
      if (userSnap.docs.isNotEmpty) {
        // Log successful login
        await FirebaseFirestore.instance.collection('logins').add({
          'username': username,
          'action': 'login',
          'status': 'success',
          'timestamp': FieldValue.serverTimestamp(),
        });
        // Save username to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        if (mounted) {
          setState(() => _loading = false);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MyHomePage(title: 'Inbox', username: username),
            ),
          );
        }
      } else {
        // Log failed login
        await FirebaseFirestore.instance.collection('logins').add({
          'username': username,
          'action': 'login',
          'status': 'failed_invalid_credentials',
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          _error = "Invalid username or password.";
          _loading = false;
        });
      }
    } catch (e) {
      // Log error
      await FirebaseFirestore.instance.collection('logins').add({
        'username': username,
        'action': 'login',
        'status': 'error',
        'error': e.toString(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _error = "Login failed. Please try again.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Login',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 32),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
              const SizedBox(height: 16),
              TextButton(
                onPressed:
                    _loading
                        ? null
                        : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          );
                        },
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
