// import 'dart:developer';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:hackthenest_music/func/helper_functions.dart';
// import 'package:hackthenest_music/permission_helper.dart';
// import 'package:path_provider/path_provider.dart';

// import 'package:record/record.dart';

// class RecordingProvider with ChangeNotifier {
//   bool isRecording = false;
//   final record = AudioRecorder();
// void startRecording() async {
//   try {
//     final granted = await PermissionHelper.requestStoragePermissions();

//     if (!granted) return;

//     if (await record.hasPermission() && isRecording == false) {
//       // Start recording to file

//       String date = DateTime.now().toString();
//       setRecordingStaus(true);
//       String randomFileName = HelperFunctions().getRandomString(5);

//       // Get the external storage directory

//       Directory? directory = await getExternalStorageDirectory();
//       String? storagePath = directory?.path;

//       // Construct the file path
//       String filePath = '$storagePath/recordings/$date-$randomFileName.wav';
//       Directory createDir = Directory('$storagePath/recordings/');
//       if (!createDir.existsSync()) {
//         createDir.createSync(recursive: true);
//       }

//       // await File(filePath).create();
//       await record.start(const RecordConfig(encoder: AudioEncoder.wav),
//           path: filePath);
//       // ... or to stream
//       // final stream = await record.startStream(const RecordConfig(AudioEncoder.pcm16bits));
//     }
//   } catch (e) {
//     setRecordingStaus(false);
//     log(e.toString());
//   }
// }

//   void setRecordingStaus(bool value) {
//     isRecording = value;
//     notifyListeners();
//   }

//   void stopRecording() async {
//     // Stop recording...
//     try {
//       final path = await record.stop();
//       log(path!);
//       setRecordingStaus(false);
//       // record.dispose(); // As always, don't forget this one.
//     } catch (e) {
//       setRecordingStaus(false);
//       log(e.toString());
//     }
//   }
// }

import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackthenest_music/func/helper_functions.dart';
import 'package:hackthenest_music/permission_helper.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class RecordingState {
  final bool isRecording;
  final AudioRecorder recorder;

  RecordingState({
    required this.isRecording,
    required this.recorder,
  });

  RecordingState copyWith({
    bool? isRecording,
    AudioRecorder? recorder,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      recorder: recorder ?? this.recorder,
    );
  }
}

// Manual provider definition
final recordingProvider =
    NotifierProvider<RecordingNotifier, RecordingState>(RecordingNotifier.new);

class RecordingNotifier extends Notifier<RecordingState> {
  @override
  RecordingState build() {
    return RecordingState(
      isRecording: false,
      recorder: AudioRecorder(),
    );
  }

  void setRecordingStatus(bool value) {
    state = state.copyWith(isRecording: value);
  }

  Future<void> startRecording() async {
    try {
      final granted = await PermissionHelper.requestStoragePermissions();

      if (!granted) return;

      if (await state.recorder.hasPermission() && !state.isRecording) {
        String date = DateTime.now().toString();
        setRecordingStatus(true);
        String randomFileName = HelperFunctions().getRandomString(5);

        Directory? directory = await getExternalStorageDirectory();
        String? storagePath = directory?.path;

        String filePath = '$storagePath/recordings/$date-$randomFileName.m4a';
        Directory createDir = Directory('$storagePath/recordings/');
        if (!createDir.existsSync()) {
          createDir.createSync(recursive: true);
        }

        await state.recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacHe),
          path: filePath,
        );
      }
    } catch (e) {
      setRecordingStatus(false);
      log(e.toString());
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await state.recorder.stop();
      log(path!);
      setRecordingStatus(false);
    } catch (e) {
      setRecordingStatus(false);
      log(e.toString());
    }
  }
}
