import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackthenest_music/func/stream_to_amp.dart';
import 'package:hackthenest_music/providers/recording_provider.dart';
import 'package:hackthenest_music/widgets/record_button.dart';
import 'package:record/record.dart' as record;
import 'package:waveform_flutter/waveform_flutter.dart' as wave_form;

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  final liveRecorder = record.AudioRecorder();
  Stream<Uint8List>? stream;
  final audioProcessor = AudioStreamProcessor();
  bool isRecording = false;

  @override
  void dispose() {
    stopRecording();
    liveRecorder.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startRecording();
  }

  Future<void> startRecording() async {
    try {
      if (await liveRecorder.hasPermission()) {
        stream = await liveRecorder.startStream(
          const record.RecordConfig(
            encoder: record.AudioEncoder.pcm16bits,
            sampleRate: 44100,
          ),
        );

        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      if (isRecording) {
        await liveRecorder.stop();
        setState(() {
          isRecording = false;
          stream = null;
        });
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Record"),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: wave_form.AnimatedWaveList(
                        stream: liveRecorder
                            .onAmplitudeChanged(
                              Duration(milliseconds: 5),
                            )
                            .map((record.Amplitude recordAmp) =>
                                wave_form.Amplitude(
                                  current: recordAmp.current,
                                  max: recordAmp.max,
                                )),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 50,
                  ),
                  RecordButton(),
                  IconButton(
                    isSelected: ref.watch(recordingProvider).isNoiseCanceling,
                    onPressed: () {
                      ref
                          .read(recordingProvider.notifier)
                          .toggleNoiseCancellation();
                    },
                    icon: const Icon(Icons.noise_aware_rounded),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Add extension methods to easily convert between types
extension RecordAmplitudeConverter on record.Amplitude {
  wave_form.Amplitude toWaveForm() {
    return wave_form.Amplitude(current: current, max: max);
  }
}

extension WaveFormAmplitudeConverter on wave_form.Amplitude {
  record.Amplitude toRecord() {
    return record.Amplitude(current: current, max: max);
  }
}
