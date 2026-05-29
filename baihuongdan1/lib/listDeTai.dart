import 'package:flutter/material.dart';
import 'package:baihuongdan1/DeTai.dart';

class MyListDeTai extends StatefulWidget {
  const MyListDeTai({super.key});

  @override
  State<MyListDeTai> createState() => _MyDialogState();
}

class _MyDialogState extends State<MyListDeTai> {

  static List<DeTai> dsDeTai = [

    DeTai(
      maDeTai: "DT01",
      tenDeTai: 'Khai thác tập hữu ích cao trên CSDL giao dịch',
      tenGiangVien: 'ThS. TRẦN MINH PHÚC',
      noiDung:
          'Khai phá tập HUI, tìm hiểu và vận dụng các kỹ thuật tỉa hiệu quả để giảm bớt không gian tìm kiếm',
      chuyenNganh: 'CNPM',
    ),

    DeTai(
      maDeTai: "DT03",
      tenDeTai:
          'Phát hiện tấn công và ngăn ngừa phát tán mã độc trong hệ thống mạng',
      tenGiangVien: 'ThS. Vũ Văn Vinh',
      noiDung:
          'Khai phá topKHUI, kết hợp với việc tăng ngưỡng sớm để có được minUtil lớn nhất',
      chuyenNganh: 'CNPM',
    ),

    DeTai(
      maDeTai: "DT02",
      tenDeTai: 'Khai tác K tập hữu ích cao nhất (topKHUI)',
      tenGiangVien: 'TS. Vũ Đức Thịnh',
      noiDung:
          'Khai phá topKHUI, kết hợp với việc tăng ngưỡng sớm để có được minUtil lớn nhất',
      chuyenNganh: 'MMT',
    ),

    DeTai(
      maDeTai: "DT04",
      tenDeTai: 'Xây dựng hệ thống thông tin hỗ trợ việc giảng dạy tại HUIT',
      tenGiangVien: 'ThS. Nguyễn Văn Lễ',
      noiDung:
          'Xây dựng hệ thống hỗ trợ giảng dạy và quản lý thông tin sinh viên',
      chuyenNganh: 'HTTT',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ListView Demo - Trần Minh Phúc"),
        backgroundColor: const Color.fromARGB(255, 239, 168, 4),
        leading: IconButton(icon: const Icon(Icons.home), onPressed: () {}),
      ),

      body: ListView.builder(
        itemCount: dsDeTai.length,
        itemBuilder: (BuildContext context, int index) {
          return DeTaiItem(
            deTai: dsDeTai[index],
          );
        },
      ),
    );
  }
}