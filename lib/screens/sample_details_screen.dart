import 'package:flutter/material.dart';
import 'package:hackthenest_music/sample.dart';

class SampleDetailsScreen extends StatefulWidget {
  const SampleDetailsScreen({super.key, required this.currentSample});
  final Sample currentSample;
  @override
  State<SampleDetailsScreen> createState() => _SampleDetailsScreenState();
}

class _SampleDetailsScreenState extends State<SampleDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sample Details"),
      ),
      body: Column(
        children: [
          Text(widget.currentSample.name),
        ],
      ),
    );
  }
}
