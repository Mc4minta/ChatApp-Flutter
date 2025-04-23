import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _firebase = FirebaseAuth.instance;
final _supabase = Supabase.instance.client;
final ImagePicker _picker = ImagePicker();

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

  void submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    try {
      if (_isLogin) {
        final userCredential = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        print('DEBUG : Logged user in with: ${userCredential.user?.email}');
      } else {
        final userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        try {
          // Read image bytes
          final fileBytes =
              _pickedImage != null
                  ? await _pickedImage!.readAsBytes()
                  : await DefaultAssetBundle.of(context)
                      .load('assets/images/default-profile.jpg')
                      .then((bd) => bd.buffer.asUint8List());

          // Generate filename and extension
          final fileExt =
              _pickedImage != null ? _pickedImage!.path.split('.').last : 'jpg';
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          final path = 'uploads/$fileName';

          // Upload to Supabase
          final response = await _supabase.storage
              .from('images')
              .uploadBinary(
                path,
                fileBytes,
                fileOptions: FileOptions(contentType: 'image/$fileExt'),
              );

          // Get public URL
          final imageUrl = _supabase.storage.from('images').getPublicUrl(path);


          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'createdAt': FieldValue.serverTimestamp(),
                'username': _enteredUsername,
                'email': _enteredEmail,
                'profileImageUrl': imageUrl,
              });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image upload successful!")),
          );
        } catch (error) {
          print('DEBUG: Error uploading image: $error');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to upload image: ${error.toString()}"),
            ),
          );
        }

        print('DEBUG : Sign user up with: ${userCredential.user?.email}');
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
          message =
              'User with this email doesn\'t exist. Please create an account';
          break;
        case 'invalid-credential':
          message = 'Your email or password is not correct';
          break;
        default:
          message = error.message;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Authentication failed.')),
      );
      print(error.code);
      print(error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 300,
                child: Image.asset('assets/Logo.jpg', fit: BoxFit.cover),
              ),
              Card(
                color: const Color.fromARGB(255, 232, 232, 233),
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            Text(
                              "Profile Image",
                              style: TextStyle(
                                color: Color.fromARGB(
                                  255,
                                  100,
                                  100,
                                  100,
                                ), // Soft grey for elegance
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (!_isLogin)
                            CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  _pickedImage != null
                                      ? FileImage(_pickedImage!)
                                      : const AssetImage(
                                        'assets/images/default-profile.jpg',
                                      ),
                            ),
                          // User Image picker
                          if (!_isLogin)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    var pickedFile = await _picker.pickImage(
                                      source: ImageSource.gallery,
                                    );
                                    if (pickedFile != null) {
                                      setState(() {
                                        _pickedImage = File(pickedFile.path);
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.image),
                                  label: const Text("Gallery"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(
                                      255,
                                      188,
                                      242,
                                      255,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    var pickedFile = await _picker.pickImage(
                                      source: ImageSource.camera,
                                    );
                                    if (pickedFile != null) {
                                      setState(() {
                                        _pickedImage = File(pickedFile.path);
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text("Camera"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(
                                      255,
                                      188,
                                      242,
                                      255,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          // Username Form
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Username',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().length < 4) {
                                  return 'Username must be at least 4 characters long.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          // Email Form
                          TextFormField(
                            decoration: const InputDecoration(
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
                          // Password Form
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
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
                          const SizedBox(height: 12),
                          // Submit button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                188,
                                242,
                                255,
                              ),
                            ),
                            onPressed: () {
                              submit();
                              print('DEBUG: Submit button clicked');
                            },
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
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
