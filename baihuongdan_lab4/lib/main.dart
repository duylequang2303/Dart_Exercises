import 'package:baihuongdan_lab4/baitap_stack.dart';
import 'package:baihuongdan_lab4/gtcsvc.dart';
import 'package:baihuongdan_lab4/layout_demo.dart';
import 'package:baihuongdan_lab4/maytinh.dart';
import 'package:baihuongdan_lab4/thehientinhtrang.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const THTT());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // Sửa lỗi 1: Thêm ColorScheme vào trước .fromSeed
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Bạn có thể đổi MyHomePage() thành MayTinh() hoặc GTCSVC() để chạy bài tương ứng
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          // Sửa lỗi 2: Thêm MainAxisAlignment vào trước .center [cite: 91, 95]
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}