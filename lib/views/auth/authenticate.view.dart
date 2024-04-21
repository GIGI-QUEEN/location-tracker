import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_firebase/views/auth/login.view.dart';
import 'package:tutorial_firebase/views/main.view.dart';

class Authenticate extends StatelessWidget {
  const Authenticate({super.key});

  @override
  Widget build(BuildContext context) {
    //Instance to know the authentication state.
    final firebaseUser = context.watch<User?>();
    if (firebaseUser != null) {
      //Means that the user is logged in already and hence navigate to HomePage
      return const MainView();
    }
    //The user isn't logged in and hence navigate to SignInPage.
    return const LoginView();
  }
}
