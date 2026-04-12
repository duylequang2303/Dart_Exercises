import 'package:flutter/material.dart';
// IMPORT CÁC BÀI TẬP Ở ĐÂY:
import 'bai1.dart';
import 'bai2.dart';
import 'bai3.dart';
import 'bai4.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      // THAY ĐỔI TÊN CLASS Ở ĐÂY ĐỂ XEM TỪNG BÀI:
      // BaiTap01(), BaiTap02(), BaiTap03(), BaiTap04()
      home: const BaiTap04(), 
    );
  }
}