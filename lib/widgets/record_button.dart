import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackthenest_music/providers/recording_provider.dart';

class RecordButton extends ConsumerStatefulWidget {
  const RecordButton({super.key});

  @override
  ConsumerState<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends ConsumerState<RecordButton> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(recordingProvider).isRecording;
    const outerCircleSize = 75.0;
    const innerCircleSize = 50.0;

    Future<bool> showSaveDialog() async {
      bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Name Sample"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _controller,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Done'),
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true when done
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context)
                      .pop(false); // Return false when cancelled
                },
              ),
            ],
          );
        },
      );
      return result ?? false; // Return false if the dialog is dismissed
    }

    return GestureDetector(
      onTap: () async {
        if (isRecording) {
          final filePath =
              await ref.read(recordingProvider.notifier).stopRecording();

          final result = await showSaveDialog();

          if (result && _controller.text.isNotEmpty) {
            await ref
                .read(recordingProvider.notifier)
                .setName(filePath!, _controller.text);
          } else {
            await ref
                .read(recordingProvider.notifier)
                .setName(filePath!, "New Sample");
          }
        } else {
          await ref.read(recordingProvider.notifier).startRecording();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: outerCircleSize,
          height: outerCircleSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer circle (only visible when not recording)
              if (!isRecording)
                Container(
                  width: outerCircleSize,
                  height: outerCircleSize,
                  decoration: const ShapeDecoration(
                    color: Color(0x47FF0000),
                    shape: OvalBorder(),
                  ),
                ),
              // Inner shape (circle when not recording, square when recording)
              Container(
                width: innerCircleSize,
                height: innerCircleSize,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFF0000),
                  shape: isRecording
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))
                      : const OvalBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
