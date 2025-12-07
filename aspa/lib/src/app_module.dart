import 'package:aspa/src/pages/splash_screen.dart';
import 'package:aspa/src/utils/theme.dart';
import 'package:aspa/src/utils/util.dart';
// import 'package:aspa/src/pages/homepage_widget.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme =
        createTextTheme(context, "Lexend", "Atkinson Hyperlegible");

    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: const SplashScreen(),
    );
  }
}
