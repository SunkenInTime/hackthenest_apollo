import 'package:flutter/material.dart';
import 'package:hackthenest_music/widgets/record_button.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Record"),
      ),
      body: Center(
        child: Column(
          children: [const Expanded(child: Column()), RecordButton()],
        ),
      ),
    );
  }
}
