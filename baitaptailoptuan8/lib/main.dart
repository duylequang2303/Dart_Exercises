// =============================================================
// Bài tập 07: Ứng dụng Đa phương tiện (Multimedia App)
// Điều hướng: BottomNavigationBar 4 tab
//   Tab 0: Bộ Sưu Tập  (Bài 1, 2, 3 - Ảnh và Video)
//   Tab 1: Nhạc Cơ Bản (Bài 4 - Trình phát nhạc đơn giản)
//   Tab 2: Nhạc Pro    (Bài 5 - Giao diện nghe nhạc hiện đại)
//   Tab 3: Hồ Sơ       (Bài 6 - SQLite quản lý người dùng)
// =============================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/media_picker_screen.dart';
import 'screens/audio_player_screen.dart';
import 'screens/music_player_screen.dart';
import 'screens/user_profile_screen.dart';

void main() {
  // Khởi tạo SQLite cho Windows/Desktop
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Chạy ứng dụng đầy đủ với 4 Tab điều hướng
  runApp(const MediaPickerApp());
}

// ==============================================================
// Ứng dụng gốc
// ==============================================================
class MediaPickerApp extends StatelessWidget {
  const MediaPickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Đa phương tiện',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const MainShell(),
    );
  }
}

// ==============================================================
// MainShell: Khung chứa BottomNavigationBar 4 tab
// ==============================================================
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Dùng IndexedStack để giữ trạng thái các màn hình khi chuyển tab
  final List<Widget> _screens = const [
    MediaPickerScreen(), // Tab 0: Chọn/Chụp ảnh, Quay video
    AudioPlayerScreen(), // Tab 1: Trình phát nhạc đơn giản
    MusicPlayerScreen(), // Tab 2: Trình phát nhạc chuyên nghiệp
    UserProfileScreen(), // Tab 3: Quản lý Hồ sơ người dùng
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.white30,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_media_outlined),
            activeIcon: Icon(Icons.perm_media_rounded),
            label: 'Bộ Sưu Tập',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.audiotrack_outlined),
            activeIcon: Icon(Icons.audiotrack_rounded),
            label: 'Nhạc Cơ Bản',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.album_outlined),
            activeIcon: Icon(Icons.album_rounded),
            label: 'Nhạc Pro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Hồ Sơ',
          ),
        ],
      ),
    );
  }
}
