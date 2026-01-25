import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '/app_module.dart';
import 'src/utils/theme.dart';
import 'src/utils/util.dart';

void main() {
  return runApp(
    ModularApp(
      module: AppModule(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme =
        createTextTheme(context, "Lexend", "Atkinson Hyperlegible");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      routerConfig: Modular.routerConfig,
    );
  }
}
