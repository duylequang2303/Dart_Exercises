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
import 'package:baitapvenhatuan8/screens/music_player_screen.dart';
import 'package:baitapvenhatuan8/screens/user_profile_screen.dart';

void main() {
  // Khởi tạo SQLite cho Windows/Desktop
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Chọn màn hình muốn chạy và comment các màn hình còn lại:

  // Bài 1, 2, 3: Chọn ảnh/video
  //runApp(const MainAppWrapper(home: MediaPickerScreen()));

  // Bài 4: Phát nhạc cơ bản
  runApp(const MainAppWrapper(home: AudioPlayerScreen()));

  // Bài 5: Phát nhạc nâng cao (Pro)
  // runApp(const MainAppWrapper(home: MusicPlayerScreen()));

  // Bài 6: Quản lý Hồ sơ gửi SQLite
  // runApp(const MainAppWrapper(home: UserProfileScreen()));
}

// ==============================================================
// Ứng dụng gốc để cung cấp Theme và điều hướng
// ==============================================================
class MainAppWrapper extends StatelessWidget {
  final Widget home;

  const MainAppWrapper({super.key, required this.home});

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
      home: home,
    );
  }
}
