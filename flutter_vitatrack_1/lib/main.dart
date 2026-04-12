import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/route.dart'; // Chỉ cần gọi "Bản đồ" này là đủ
import 'core/constants.dart'; // Gọi hằng số để lấy tên App

void main() {
  runApp(const VitaTrackApp());
}

class VitaTrackApp extends StatelessWidget {
  const VitaTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: VitaTrackConstants.tenApp, // Dùng hằng số từ constants.dart
      debugShowCheckedModeBanner: false,
      
      // Dùng hệ thống Theme chuyên nghiệp chúng ta vừa nâng cấp
      theme: VitaTrackTheme.layTheme(),
      
      // ĐÃ SỬA: Không dùng home: nữa, dùng hệ thống Route cho chuyên nghiệp
      initialRoute: VitaTrackRoutes.login, 
      routes: VitaTrackRoutes.layRoutes(),
    );
  }
}