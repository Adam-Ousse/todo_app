import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  String? _error;
  bool _loading = false;

  Future<void> _signUp() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final username = _userController.text.trim();
    final password = _passController.text;
    final confirm = _confirmController.text;
    if (username.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() {
        _error = "All fields are required.";
        _loading = false;
      });
      return;
    }
    if (password != confirm) {
      setState(() {
        _error = "Passwords do not match.";
        _loading = false;
      });
      return;
    }
    try {
      // Check if username exists
      final userSnap =
          await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();
      if (userSnap.docs.isNotEmpty) {
        // Log failed signup
        await FirebaseFirestore.instance.collection('logins').add({
          'username': username,
          'action': 'signup',
          'status': 'failed_username_exists',
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          _error = "Username already exists.";
          _loading = false;
        });
        return;
      }
      // Add user
      await FirebaseFirestore.instance.collection('users').add({
        'username': username,
        'password': password,
        'created_at': FieldValue.serverTimestamp(),
      });
      // Log successful signup
      await FirebaseFirestore.instance.collection('logins').add({
        'username': username,
        'action': 'signup',
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() => _loading = false);
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Log error
      await FirebaseFirestore.instance.collection('logins').add({
        'username': username,
        'action': 'signup',
        'status': 'error',
        'error': e.toString(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _error = "Signup failed. Please try again.";
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
                'Sign Up',
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
              const SizedBox(height: 16),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed:
                        () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
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
                    onPressed: _signUp,
                    child: const Text('Sign Up'),
                  ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loading ? null : () => Navigator.of(context).pop(),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
