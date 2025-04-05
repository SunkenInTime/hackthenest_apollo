import 'dart:developer';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackthenest_music/constant/routes.dart';
import 'package:hackthenest_music/providers/sample_provider.dart';
import 'package:hackthenest_music/sample.dart';

// class SampleWidget extends StatelessWidget {
//   const SampleWidget(
//       {super.key, required this.sampleWidth, required this.currentSample});
//   final double sampleWidth;
//   final Sample currentSample;
//   @override
//   Widget build(BuildContext context) {}
// }

class SampleWidget extends ConsumerStatefulWidget {
  const SampleWidget({
    super.key,
    required this.sampleWidth,
    required this.currentSample,
  });
  final double sampleWidth;
  final Sample currentSample;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SampleWidgetState();
}

class _SampleWidgetState extends ConsumerState<SampleWidget> {
  final PlayerController playerController = PlayerController();

  @override
  void initState() {
    _preparePlayer(); // Add this method
    super.initState();
    log("Fetching waveform data");
  }

  Future<void> _preparePlayer() async {
    try {
      log("Preparing player for path: ${widget.currentSample.path}");
      // Check if file exists
      final file = File(widget.currentSample.path);
      final exists = await file.exists();
      log("File exists: $exists");

      // Check file extension
      final extension = widget.currentSample.path.split('.').last.toLowerCase();
      log("File extension: $extension");
    } catch (e) {
      log("Error preparing player: $e");
      if (e is PlatformException) {
        log("Error details: ${e.message} ${e.details}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SizedBox(
        width: widget.sampleWidth,
        height: widget.sampleWidth,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: widget.sampleWidth,
                height: widget.sampleWidth,
                decoration: ShapeDecoration(
                  color: const Color(0xFF272727),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(33),
                  ),
                ),
              ),
            ),
            Positioned(
              left: widget.sampleWidth * 0.076,
              top: widget.sampleWidth * 0.135,
              child: Text(
                widget.currentSample.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.sampleWidth * 0.085,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: widget.sampleWidth * 0.65,
              top: widget.sampleWidth * 0.777,
              child: Text(
                widget.currentSample.formatDuration(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.sampleWidth * 0.085,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: widget.sampleWidth * 0.076,
              top: widget.sampleWidth * 0.777,
              child: Text(
                'wav',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.sampleWidth * 0.085,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            // ... rest of your code remains the same

            Positioned(
              left: widget.sampleWidth *
                  0.076, // Same left padding as other elements
              top: widget.sampleWidth *
                  0.4, // Adjust this value to center vertically
              child: AudioFileWaveforms(
                size: Size(50, 50),
                playerController: playerController,
                waveformType:
                    WaveformType.fitWidth, // Add this to ensure proper scaling
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        log("I am tapped");
        playerController.startPlayer();
        // Navigator.pushNamed(
        //   context,
        //   Routes.sampleDetailsRoute,
        //   arguments: widget.currentSample,
        // );
      },
    );
  }
}
