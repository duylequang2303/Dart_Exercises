import 'package:flutter/material.dart';

class BaiTap01 extends StatelessWidget {
  const BaiTap01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ListView Demo"),
        backgroundColor: const Color(0xFFEFA804),
        leading: IconButton(icon: const Icon(Icons.home), onPressed: () {}),
      ),
      body: Column(
        children: [
          // Header 1
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.blue,
            width: double.infinity,
            child: const Text("Chọn loại đề tài", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          // Phần GridView cho các loại đề tài [cite: 701, 702, 703]
          SizedBox(
            height: 120,
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(10),
              children: const [
                CategoryCircle(title: "Đồ án"),
                CategoryCircle(title: "KLKS"),
                CategoryCircle(title: "Luận văn"),
                CategoryCircle(title: "Khác"),
              ],
            ),
          ),
          // Header 2
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.blue,
            width: double.infinity,
            child: const Text("Chọn chuyên ngành thực hiện", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          // Danh sách chuyên ngành sử dụng ListView [cite: 705, 707, 709, 711]
          Expanded(
            child: ListView(
              children: const [
                MajorItem(title: "Công nghệ phần mềm", subtitle: "Phát triển các ứng dụng giải quyết các vấn đề thực tế"),
                MajorItem(title: "Hệ thống thông tin", subtitle: "Phát triển các kỹ thuật xử lý thông tin trong tổ chức"),
                MajorItem(title: "Mạng máy tính", subtitle: "Xử lý các vấn đề liên quan đến mạng máy tính"),
                MajorItem(title: "An toàn thông tin", subtitle: "Thiết kế và đảm bảo an toàn cho hệ thống máy tính"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCircle extends StatelessWidget {
  final String title;
  const CategoryCircle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 35, backgroundColor: Colors.deepPurple, child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12))),
      ],
    );
  }
}

class MajorItem extends StatelessWidget {
  final String title, subtitle;
  const MajorItem({super.key, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: const Color(0xFFC8C5B1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.home),
        title: Text(title, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }
}