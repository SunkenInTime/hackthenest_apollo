class Sample {
  final String name;
  final Duration length;
  final String path;
  Sample(this.path, {required this.name, required this.length});

  @override
  String toString() {
    String message = "Name: $name Length: $length Path: $path\n";
    return message;
  }

  String formatDuration() {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(length.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(length.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
