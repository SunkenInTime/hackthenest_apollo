import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackthenest_music/constant/routes.dart';
import 'package:hackthenest_music/providers/sample_provider.dart';
import 'package:hackthenest_music/sample.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

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
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    setupAudioPlayer();
  }

  void setupAudioPlayer() async {
    await audioPlayer.setFilePath(widget.currentSample.path);

    audioPlayer.playerStateStream.listen((playerState) {
      if (mounted) {
        setState(() {
          isPlaying = playerState.playing;
          if (playerState.processingState == ProcessingState.completed) {
            isPlaying = false;
            audioPlayer.seek(Duration.zero);
          }
        });
      }
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> togglePlayPause() async {
    try {
      if (isPlaying) {
        await audioPlayer.pause();
      } else {
        if (audioPlayer.position == audioPlayer.duration) {
          await audioPlayer.seek(Duration.zero);
        }
        await audioPlayer.play();
      }
    } catch (e) {
      log('Error toggling play/pause: $e');
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
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
            // Current time / Total duration
            Positioned(
              left: widget.sampleWidth * 0.65,
              top: widget.sampleWidth * 0.777,
              child: StreamBuilder<Duration>(
                stream: audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  return Text(
                    (snapshot.data == null)
                        ? widget.currentSample.formatDuration()
                        : formatDuration(position),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.sampleWidth * 0.085,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  );
                },
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
                child: SizedBox.shrink()),
            Positioned(
              left: widget.sampleWidth * 0.4,
              top: widget.sampleWidth * 0.35,
              child: Icon(
                isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Colors.white,
                size: widget.sampleWidth * 0.25,
              ),
            ),

            // Optional: Add a visual indicator when playing
            if (isPlaying)
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: widget.sampleWidth,
                  height: widget.sampleWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(33),
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      onTap: () async {
        togglePlayPause();
      },
      onLongPress: () async {
        final result =
            await Share.shareXFiles([XFile(widget.currentSample.path)]);

        if (result.status == ShareResultStatus.success) {
          log("Big W");
        }
      },
    );
  }
}
