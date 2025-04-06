import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackthenest_music/func/helper_functions.dart';
import 'package:hackthenest_music/permission_helper.dart';
import 'package:hackthenest_music/providers/sample_provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class RecordingState {
  final bool isRecording;
  final AudioRecorder recorder;
  final bool isNoiseCanceling;

  RecordingState({
    required this.isRecording,
    required this.recorder,
    required this.isNoiseCanceling,
  });

  RecordingState copyWith({
    bool? isRecording,
    AudioRecorder? recorder,
    bool? isNoiseCanceling,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      recorder: recorder ?? this.recorder,
      isNoiseCanceling: isNoiseCanceling ?? this.isNoiseCanceling,
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
      isNoiseCanceling: false,
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

        String filePath = '$storagePath/recordings/_$date-$randomFileName.m4a';
        Directory createDir = Directory('$storagePath/recordings/');
        if (!createDir.existsSync()) {
          createDir.createSync(recursive: true);
        }

        await state.recorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacHe,
            noiseSuppress: state.isNoiseCanceling,
            echoCancel: state.isNoiseCanceling,
          ),
          path: filePath,
        );
      }
    } catch (e) {
      setRecordingStatus(false);
      log(e.toString());
    }
  }

  void toggleNoiseCancellation() {
    state = state.copyWith(isNoiseCanceling: !state.isNoiseCanceling);
  }

  Future<void> setName(String fullPath, String newFileName) async {
    String name = newFileName;

    // Loop until doesFileExist returns true.
    while ((await ref.read(samplesProvider.notifier).doesFileExist(name))) {
      // Split the name into individual characters
      List<String> newString = name.split("");

      // Get the last character to check if it's a digit
      String lastLetter = newString.last;
      int? number = int.tryParse(lastLetter);

      if (number == null) {
        // If the last letter isn't a digit, append " 1"
        name += " 1";
      } else {
        // Remove the last digit character
        newString.removeLast();
        // Append the incremented number (as a string)
        name = "${newString.join()}${number + 1}";
      }
    }

    final File currentSample = File(fullPath);

    final String newPath = '${currentSample.parent.path}/$name.m4a';
    try {
      await currentSample.rename(newPath);
      log('File renamed successfully to: $newPath');
    } catch (e) {
      log('Error renaming file: $e');
    }

    await ref.read(samplesProvider.notifier).getSamplesFromFile();
  }

  Future<String?> stopRecording() async {
    try {
      final path = await state.recorder.stop();
      log(path!);
      setRecordingStatus(false);
      return path;
    } catch (e) {
      setRecordingStatus(false);
      log(e.toString());
    }
    return null;
  }
}
