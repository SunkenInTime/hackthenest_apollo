import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackthenest_music/providers/sample_provider.dart';
import 'package:hackthenest_music/sample.dart';
import 'package:hackthenest_music/widgets/sample_widget.dart';

class SamplesScreen extends ConsumerWidget {
  const SamplesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double fullScreenWidth = MediaQuery.of(context).size.width;

    double sampleWidth = (fullScreenWidth / 2) - (fullScreenWidth / 18);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Samples"),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(samplesProvider.notifier).getSamplesFromFile();
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(samplesProvider.notifier).clearAllRecordings();
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        padding: const EdgeInsets.all(10),
        itemCount: ref.watch(samplesProvider).listOfSamples.length,
        itemBuilder: (context, index) {
          Sample currentSample =
              ref.watch(samplesProvider).listOfSamples[index];
          return SampleWidget(
            sampleWidth: sampleWidth,
            currentSample: currentSample,
          );
        },
      ),
    );
  }
}
