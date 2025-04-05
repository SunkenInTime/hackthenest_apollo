import 'package:flutter/material.dart';
import 'package:hackthenest_music/screens/recording_screen.dart';
import 'package:hackthenest_music/screens/samples_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 1;
  final screens = const [
    RecordingScreen(),
    SamplesScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: currentIndex,
        onTap: (i) {
          setState(() {
            currentIndex = i;
          });
        },
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.record_voice_over_outlined),
            title: const Text("Record"),
            selectedColor: Colors.red,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.audio_file),
            title: const Text("Samples"),
            selectedColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
