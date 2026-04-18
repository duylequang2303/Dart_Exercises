import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/core/route.dart'; // Chỉ cần gọi "Bản đồ" này là đủ
import 'package:flutter_vitatrack_1/core/constants.dart'; // Gọi hằng số để lấy tên App
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: VitaTrackApp()));
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