import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // Submit function
  void submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    try { // sign up or login user with credentials
      if (_isLogin) {
        // Log user in with firebase auth
        final userCredential = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        print('DEBUG : Logged user in with: ${userCredential.user?.email}');
      } else {
        // Sign user up with firebase auth
        final userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        print('DEBUG : Sign user up with: ${userCredential.user?.email}');
        // Collect credentials in firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            // TODO: add user image url to firestore
            .set({'username': _enteredUsername, 'email': _enteredEmail});
      }
    } on FirebaseAuthException catch (error) {
      var message = error.message;
      switch (error.code) {
        case 'email-already-in-use':
          message = 'Email already in use';
          break;
        case 'wrong-password':
          message = 'Your email or password is not correct';
          break;
        case 'user-not-found':
          message = 'User with this email don\'t exist please create an account';
          break;
        case 'invalid-credential':
          message = 'Your email or password is not correct';
        default:
          message = error.message;
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Authentication failed.')),
      );
      print(error.code);
      print(error.message);
    }
  }

  @override // auth screen widget
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container for picture and card
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              // Signup and Login Card
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        // Card components
                        children: [
                          // user image picker
                          if (!_isLogin)
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
                          ),
                          // camera and gallery
                          if(!_isLogin)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  var pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    setState(() {
                                      _pickedImage = File(pickedFile.path);
                                    });
                                  }
                                }, 
                                label: Icon(Icons.image),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async{
                                  var pickedFile = await _picker.pickImage(source: ImageSource.camera);
                                  if (pickedFile != null) {
                                    setState(() {
                                      _pickedImage = File(pickedFile.path);
                                    });
                                  }
                                }, 
                                label: Icon(Icons.camera_alt),
                              ),
                            ],
                          ),
                          // Email form
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          // Password form
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          // Username form
                          if (!_isLogin)
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: ('Username'),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Username must be at least 4 characters long.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          const SizedBox(height: 12),
                          // Signup and Login button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                            ),
                            onPressed: () {
                              submit();
                              print('DEBUG: Submit button clicked');
                            },
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                          // Switch auth mode button
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                              print('DEBUG: Switching mode');
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
