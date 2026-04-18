// =============================================================
// Bai 07: Multimedia App - Diem vao chinh
// Giao dien: BottomNavigationBar 4 tab
//   Tab 0: Media Picker  (Bai 1,2,3 - anh va video)
//   Tab 1: Audio Player  (Bai 4 - phat nhac don gian)
//   Tab 2: Music Player  (Bai 5 - giao dien nhac hien dai)
//   Tab 3: User Profile  (Bai 6 - SQLite quan ly nguoi dung)
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
  // Khoi tao cho SQLite tren Windows/Desktop
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // --- Bỏ comment (xóa dấu //) ở dòng bạn muốn chạy thử ---

  runApp(
    const MaterialApp(home: MediaPickerScreen()),
  ); // Chạy Bài 1, 2, 3 (Ảnh / Video)
  // runApp(const MaterialApp(home: AudioPlayerScreen()));            // Chạy Bài 4 (Audio Player)
  // runApp(const MaterialApp(home: MusicPlayerScreen()));            // Chạy Bài 5 (Music Player pro)
  // runApp(const MaterialApp(home: UserProfileScreen()));            // Chạy Bài 6 (SQLite User Profile)
}

// ==============================================================
// Widget goc cua ung dung
// ==============================================================
class MediaPickerApp extends StatelessWidget {
  const MediaPickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multimedia App - Bai 07',
      debugShowCheckedModeBanner: false,
      // Cau hinh theme toan cuc - dark mode hien dai
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}

// ==============================================================
// MainShell: Khung chinh chua BottomNavigationBar 4 tab
// ==============================================================
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Chi muc tab dang chon
  int _currentIndex = 0;

  // Cac man hinh tuong ung voi moi tab
  // IndexedStack giu trang thai cac man hinh khi doi tab
  final List<Widget> _screens = const [
    MediaPickerScreen(), // Tab 0: Chon/chup anh, quay video
    AudioPlayerScreen(), // Tab 1: Trinh phat nhac don gian
    MusicPlayerScreen(), // Tab 2: Giao dien nhac chuyen nghiep
    UserProfileScreen(), // Tab 3: Quan ly user voi SQLite
  ];

  // Cau hinh cac item tab
  static const List<_TabItem> _tabs = [
    _TabItem(
      icon: Icons.perm_media_outlined,
      activeIcon: Icons.perm_media_rounded,
      label: 'Media',
    ),
    _TabItem(
      icon: Icons.music_note_outlined,
      activeIcon: Icons.music_note_rounded,
      label: 'Audio',
    ),
    _TabItem(
      icon: Icons.album_outlined,
      activeIcon: Icons.album_rounded,
      label: 'Player',
    ),
    _TabItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Users',
    ),
  ];

  // Mau sac cho tung tab (highlight khi active)
  static const List<Color> _tabColors = [
    Color(0xFF6C63FF), // Tab 0: tim
    Color(0xFF00BCD4), // Tab 1: xanh da troi
    Color(0xFFFF6B9D), // Tab 2: hong
    Color(0xFFFF9800), // Tab 3: cam
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack giu widget song neu khong lo man hinh
      body: IndexedStack(index: _currentIndex, children: _screens),

      // Thanh dieu huong phia duoi voi thiet ke tuy chinh
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12121F),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final isActive = i == _currentIndex;
              final tab = _tabs[i];
              final color = _tabColors[i];

              return Expanded(
                child: GestureDetector(
                  key: Key('nav_tab_$i'),
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Chi bao vu hieu ung go
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? color.withValues(alpha: 0.18)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isActive ? tab.activeIcon : tab.icon,
                            color: isActive ? color : Colors.white30,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Nhan tab
                        Text(
                          tab.label,
                          style: TextStyle(
                            color: isActive ? color : Colors.white30,
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.normal,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// Model nho de giu cau hinh tab
class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
