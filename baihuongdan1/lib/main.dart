import 'package:baihuongdan1/MyGirdView02.dart';
import 'package:baihuongdan1/MyListView.dart';
import 'package:baihuongdan1/listDeTai.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyGirdView02(), //đổi thành MyListView nếu muốn xem bài 1
      // đổi thành MyListDeTai nếu muốn xem bài 2
    );
  }
}
