import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../sample.dart';

// State class to hold the samples data
class SamplesState {
  final String? samplesDirectory;
  final List<Sample> listOfSamples;

  SamplesState({
    this.samplesDirectory,
    required this.listOfSamples,
  });

  SamplesState copyWith({
    String? samplesDirectory,
    List<Sample>? listOfSamples,
  }) {
    return SamplesState(
      samplesDirectory: samplesDirectory ?? this.samplesDirectory,
      listOfSamples: listOfSamples ?? this.listOfSamples,
    );
  }
}

// Provider definition
final samplesProvider =
    NotifierProvider<SamplesNotifier, SamplesState>(SamplesNotifier.new);

class SamplesNotifier extends Notifier<SamplesState> {
  @override
  SamplesState build() {
    return SamplesState(listOfSamples: []);
  }

  Future<void> setSampleDir() async {
    Directory? directory = await getExternalStorageDirectory();
    String newSamplesDirectory = "${directory!.path}/recordings/";

    state = state.copyWith(samplesDirectory: newSamplesDirectory);
    await getSamplesFromFile();
  }

  Future<List<FileSystemEntity>> getFiles() async {
    List<FileSystemEntity> listOfFiles = [];
    Directory createDir = Directory(state.samplesDirectory!);

    if (!createDir.existsSync()) {
      createDir.createSync(recursive: true);
    }

    log(state.samplesDirectory!);

    for (FileSystemEntity file
        in Directory(state.samplesDirectory!).listSync(recursive: true)) {
      List<String> filePathList = file.path.split(".");
      String fileExtension = filePathList[filePathList.length - 1];

      if (fileExtension == "m4a" || fileExtension == "wav") {
        listOfFiles.add(file);
      }
    }

    return listOfFiles;
  }

  Future<void> getSamplesFromFile() async {
    List<FileSystemEntity> listOfFiles = await getFiles();
    List<Sample> newSamples = [...state.listOfSamples];

    for (FileSystemEntity file in listOfFiles) {
      log("We got data");
      List<String> fileString = file.path.split("/");
      fileString = fileString[fileString.length - 1].split(".");
      String fileName = fileString[1].split("-")[1];

      final audioPlayer = AudioPlayer();

      await audioPlayer.setFilePath(file.path);
      Duration? trackLength = audioPlayer.duration;
      if (trackLength == null) {
        log("we are cooked gang");
        continue;
      }

      Sample newSample = Sample(
        file.path,
        name: fileName,
        length: trackLength,
      );
      log(newSample.toString());

      await audioPlayer.dispose();

      // Check if sample already exists
      bool sampleExists =
          newSamples.any((sample) => sample.path == newSample.path);
      if (!sampleExists) {
        newSamples.add(newSample);
      }
    }

    state = state.copyWith(listOfSamples: newSamples);
  }

  Future<void> clearAllRecordings() async {
    try {
      // Check if directory exists
      if (state.samplesDirectory == null) {
        log("Samples directory not set");
        return;
      }

      Directory directory = Directory(state.samplesDirectory!);
      if (!directory.existsSync()) {
        log("Directory doesn't exist");
        return;
      }

      // Delete all files in the directory
      await for (var entity in directory.list()) {
        if (entity is File) {
          await entity.delete();
          log("Deleted file: ${entity.path}");
        }
      }

      // Clear the samples list in state
      state = state.copyWith(listOfSamples: []);

      log("All recordings cleared successfully");
    } catch (e) {
      log("Error clearing recordings: $e");
      throw Exception("Failed to clear recordings: $e");
    }
  }
}
