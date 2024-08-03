// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() {
    return _AuthScreen();
  }
}

class _AuthScreen extends State<AuthScreen> {
  final _formkey = GlobalKey<FormState>();
  var enteredemail = "";
  var enterpass = "";
  var _isLogin = true;
  var enteredUsername = '';
  var isUploading = false;
  File? selectedImage;
  void submit() async {
    final isValid = _formkey.currentState!.validate();

    if (!_isLogin && selectedImage == null || !isValid) {
      return;
    }

    _formkey.currentState!.save();
    try {
      setState(() {
        isUploading = true;
      });
      if (_isLogin) {
        final userCredentials = await firebase.signInWithEmailAndPassword(
            email: enteredemail, password: enterpass);
      } else {
        final userCredentials = await firebase.createUserWithEmailAndPassword(
            email: enteredemail, password: enterpass);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(selectedImage!);

        final imageurl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': enteredUsername,
          'email': enteredemail,
          'image_url': imageurl,
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        //..
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'Authentication Failed'),
      ));
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: const Image(
                  image: AssetImage('assest/images/ch.png'),
                ),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: _formkey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              UserImagePicker(
                                onPickImage: (selectedimage) {
                                  selectedImage = selectedimage;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Email Address'),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return ('Please enter the valid email address');
                                }
                                return null;
                              },
                              onSaved: (value) {
                                enteredemail = value!;
                              },
                            ),
                            if (!_isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                  label: Text('UserName'),
                                ),
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 4) {
                                    return 'Please enter the valid username minimum 4 characters.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  enteredUsername = value!;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Password'),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return ('Password must have at least 6 characters');
                                }
                                return null;
                              },
                              onSaved: (value) {
                                enterpass = value!;
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            isUploading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: submit,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer),
                                    child: Text(_isLogin ? 'Login' : 'Sign Up'),
                                  ),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? "Create a account"
                                    : "I already have an account"))
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
