import 'package:flutter/material.dart';
import '../src/views/screens/main_menu.dart';
import '../src/database/db_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // load in the database
  final DatabaseHelper helper = DatabaseHelper();
  helper.initializeDatabase().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toki Pona Learning App',
      theme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 7, 83, 90),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 10, 56, 61),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 7, 83, 90),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
        cardTheme: const CardTheme(
          color: Color.fromARGB(255, 18, 18, 18), // Dark background for cards
          shadowColor: Colors.black,
          elevation: 5,
          margin: EdgeInsets.all(8),
        ),
      ),
      home: const MainMenu(),
    );
  }
}
