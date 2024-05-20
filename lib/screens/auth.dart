import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  bool _isLogin = true;
  String _enteredEmail = '';
  String _enteredPassword = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    try {
      if (_isLogin) {
        // log in user

        final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        print(userCredentials);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        print(userCredentials);
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        // ...
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Authentication failed.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 30,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              child: Image.asset(
                'assets/images/chat.png',
                width: 200,
              ),
            ),
            Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Email Address'),
                        ),
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              value.contains('@') == false) {
                            return 'Plase enter valid email address';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredEmail = newValue!;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Password'),
                        ),
                        autocorrect: false,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password should be minimum 6 characters';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredPassword = newValue!;
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Text(
                          _isLogin ? 'Login' : 'Sign Up',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin
                              ? 'Create an account'
                              : 'I already have an account',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
