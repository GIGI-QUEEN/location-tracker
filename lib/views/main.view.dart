import 'package:flutter/material.dart';

import 'package:tutorial_firebase/views/settings.view.dart';
import 'package:tutorial_firebase/views/friends/friends.view.dart';
import 'package:tutorial_firebase/views/map.view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const FriendsView(),
    const MapView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.group), label: 'friends'),
          NavigationDestination(icon: Icon(Icons.public), label: 'map'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'settings'),
        ],
      ),
    );
  }
}
