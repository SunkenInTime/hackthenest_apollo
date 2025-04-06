import 'dart:math';
import 'dart:typed_data';

import 'package:waveform_flutter/waveform_flutter.dart';

class AudioStreamProcessor {
  Stream<Amplitude> convertToAmplitudeStream(Stream<Uint8List> audioStream) {
    return audioStream.map((audioData) {
      double currentAmplitude = _calculateAmplitude(audioData);
      return Amplitude(
        current: currentAmplitude,
        max: 32767.0, // Max value for 16-bit audio
      );
    });
  }

  double _calculateAmplitude(Uint8List audioData) {
    List<int> samples = [];
    for (int i = 0; i < audioData.length; i += 2) {
      int sample = (audioData[i + 1] << 8) | audioData[i];
      if (sample > 32767) sample -= 65536;
      samples.add(sample);
    }

    double sumOfSquares = 0;
    for (int sample in samples) {
      sumOfSquares += sample * sample;
    }
    return sqrt(sumOfSquares / samples.length);
  }
}
