import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackthenest_music/constant/routes.dart';
import 'package:hackthenest_music/constant/theme.dart';
import 'package:hackthenest_music/providers/sample_provider.dart'; //;'
import 'package:hackthenest_music/sample.dart';
import 'package:hackthenest_music/screens/home_screen.dart';
import 'package:hackthenest_music/screens/sample_details_screen.dart';

void main() {
  runApp(ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: darkTheme,
      home: const HomePage(),
      routes: {
        Routes.sampleDetailsRoute: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          return SampleDetailsScreen(
            currentSample: args as Sample,
          );
        },
      },
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(samplesProvider.notifier).setSampleDir(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            log(ref.read(samplesProvider).listOfSamples.toString());
            return const HomeScreen();

          default:
            return const Scaffold(
              body: Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
        }
      },
    );
  }
}
