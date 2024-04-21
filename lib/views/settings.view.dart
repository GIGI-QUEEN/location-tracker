import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_firebase/constants/routes_names.dart';
import 'package:tutorial_firebase/providers/authentication_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();
    final firebaseUser = context.watch<User?>();

    if (firebaseUser == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, signUp));
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('settings'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Logged in as ${firebaseUser?.email}'),
            const SizedBox(
              height: 20,
            ),
            Text('UID: ${firebaseUser?.uid}'),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
              onPressed: () async {
                try {
                  await authProvider.signOut();
                } catch (e) {
                  throw Exception(e);
                }
              },
              child: const Text('logout'),
            ),
          ],
        ),
      ),
    );
  }
}
