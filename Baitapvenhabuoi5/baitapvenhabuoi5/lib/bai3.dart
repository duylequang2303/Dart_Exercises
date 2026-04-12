import 'package:flutter/material.dart';

class BaiTap03 extends StatelessWidget {
  const BaiTap03({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quà của Vinh (7)"), backgroundColor: Colors.pink[50]),
      body: ListView.builder(
        itemCount: 5, // Giả sử có 5 voucher
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number, size: 50, color: Colors.red),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Giảm 100K", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Cho đơn từ 0đ"),
                        Text("HSD: 28/02/2026", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[100]),
                    child: const Text("Dùng ngay", style: TextStyle(color: Colors.red)),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}