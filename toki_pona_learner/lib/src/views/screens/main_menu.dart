import 'package:flutter/material.dart';
import '../screens/practice_screen.dart';
import '../screens/dictionary.dart';
import '../screens/view.dart';
import '../../database/db_helper.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Dictionary()),
                  );
                },
                child: const Text('Dictionary'),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ViewScreen()),
                  );
                },
                child: const Text('View Words'),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PracticeScreen()),
                  );
                },
                child: const Text('Practice'),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showUploadInstructions(context);
                },
                child: const Text('Upload Custom Dictionary'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final dbHelper = DatabaseHelper();
                  await dbHelper.revertToDefaultCSV();
                },
                child: const Text('Revert to Default Dictionary'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showUploadInstructions(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('CSV Upload Instructions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please format your CSV file as below',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text("Word - P.of Speech - Definition"),
              const SizedBox(height: 8),
              const Text(
                '"moku","noun","meal"\n'
                '"moku","noun","food"\n'
                '"moku","verb","to eat"\n'
                '"moku","verb","drink"\n'
                '"moku","verb","consume"\n',
                style: TextStyle(fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _uploadCSV(context);
                },
                child: const Text('Upload CSV'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadCSV(BuildContext context) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.uploadCSV();
  }
}
