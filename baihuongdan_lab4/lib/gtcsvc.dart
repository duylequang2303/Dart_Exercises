import 'package:flutter/material.dart';

class GTCSVC extends StatefulWidget{
  const GTCSVC({super.key});

  @override
  State<GTCSVC> createState() => _GTCSVC();

}

class _GTCSVC extends State<GTCSVC>{
  int _currentIndex = 0;

  @override
  Widget build(BuildContext content){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
   
          backgroundColor: Colors.blue,
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            Center(child: Text("Chào mừng đến với HUIT"),),
            Center(child: Text("Hệ thống máy tính hiện đại."),),
            Center(child: Text("Khu vực căn tin sinh viên"),),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index){
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
            BottomNavigationBarItem(icon: Icon(Icons.computer), label: "Phòng máy"),
            BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: "Căn tin")
          ],
        ),
      ),
    );
  }
}