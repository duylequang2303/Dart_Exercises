import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'database/db_helper.dart';
import 'database/todo_db_helper.dart';
import 'database/sanpham_db_helper.dart';
import 'database/chitieu_db_helper.dart';
import 'database/user_db_helper.dart';
import 'provider/sinhvien_provider.dart';
import 'provider/todo_provider.dart';
import 'provider/sanpham_provider.dart';
import 'provider/chitieu_provider.dart';
import 'view/v_sinhvien.dart';
import 'view/v_todo.dart';
import 'view/v_sanpham.dart';
import 'view/v_chitieu.dart';
import 'view/v_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await DatabaseHelper().initDB();
  await TodoDbHelper().initDB();
  await SanPhamDbHelper().initDB();
  await ChiTieuDbHelper().initDB();
  await UserDbHelper().initDB();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SinhVienProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => SanPhamProvider()),
        ChangeNotifierProvider(create: (_) => ChiTieuProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bài Tập Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Đổi home để test từng bài:
      // SinhVienScreen() → Bài 1
      // TodoScreen()     → Bài 2
      // SanPhamScreen()  → Bài 3
      // ChiTieuScreen()  → Bài 4
      // LoginScreen()    → Bài 5
      home: const LoginScreen(),
    );
  }
}