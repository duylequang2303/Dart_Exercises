import 'package:flutter/material.dart';
import 'sms_reader_screen.dart';
import 'contacts_reader_screen.dart';
import 'contacts_manager_screen.dart';
import 'sms_analyzer_screen.dart';

void main() {
  runApp(const MultimediaApp());
}

class MultimediaApp extends StatelessWidget {
  const MultimediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multimedia App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Chính'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SmsReaderScreen()),
                );
              },
              child: const Text('1. Đọc SMS'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactsReaderScreen()),
                );
              },
              child: const Text('2. Đọc Danh Bạ'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactsManagerScreen()),
                );
              },
              child: const Text('3. Quản Lý Danh Bạ'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SmsAnalyzerScreen()),
                );
              },
              child: const Text('4. Phân Tích SMS'),
            ),
          ],
        ),
      ),
    );
  }
}
