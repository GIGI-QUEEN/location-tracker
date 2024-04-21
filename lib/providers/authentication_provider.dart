import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_firebase/services/database.service.dart';

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth;
  final DatabaseService _databaseService = DatabaseService();
  String? _signUpEmailErrorText;
  String? _loginErrorText;
  AuthenticationProvider(this.firebaseAuth);

  Stream<User?> get authState => firebaseAuth.idTokenChanges();
  String? get emailErrorText => _signUpEmailErrorText;
  String? get loginErrorText => _loginErrorText;

  Future<void> signUp(String email, String password) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      _databaseService.addUserToDB(userCredential.user!);
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          _signUpEmailErrorText = 'Email is already registered';
          notifyListeners();
          throw Exception(e);
        } else {
          notifyListeners();
          throw Exception(e);
        }
      }
    }
  }

  void clearErrorTexts() {
    _signUpEmailErrorText = null;
    _loginErrorText = null;
  }

  Future<void> signIn(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        log('got here');
        _loginErrorText = 'Invalid credentials';
        notifyListeners();
      } else {
        _loginErrorText = e.message;
        notifyListeners();
      }
      throw FirebaseAuthException(code: e.code);
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<bool> submitSignUpForm(
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) async {
    if (formKey.currentState!.validate()) {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      await signUp(email, password);
      return true;
    } else {
      return false;
    }
  }

  Future<void> submitSignInForm(
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) async {
    if (formKey.currentState!.validate()) {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      await signIn(email, password);
    }
  }
}
