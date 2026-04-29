import 'package:flutter/material.dart';
import 'package:flutter_vitatrack_1/screens/auth/login_screen.dart';
import 'package:flutter_vitatrack_1/widgets/bottom_nav.dart';

class VitaTrackRoutes {
  // Định nghĩa tên các con đường
  static const String login = '/login';
  static const String home = '/home';

  // Hàm quản lý việc chuyển màn hình
  static Map<String, WidgetBuilder> layRoutes() {
    return {
      login: (context) => const LoginScreen(),
      home: (context) => const BottomNav(), // Dẫn vào trang chính có 5 tab
    };
  }
}