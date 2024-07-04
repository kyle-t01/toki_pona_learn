import 'package:flutter/material.dart';
import '../src/views/screens/main_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toki Pona Learning App',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 225, 166)),
        useMaterial3: true,
        fontFamily: 'sitelenselikiwen',
      ),
      home: const MainMenu(),
    );
  }
}
