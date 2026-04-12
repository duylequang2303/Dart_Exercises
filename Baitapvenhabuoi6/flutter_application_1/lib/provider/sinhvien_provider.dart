import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../model/sinhvien.dart';

class SinhVienProvider extends ChangeNotifier {
  List<SinhVien> _danhSach = [];
  List<SinhVien> _danhSachGoc = []; // giữ bản gốc để search

  List<SinhVien> get danhSach => _danhSach;

  // Load từ SQLite — gọi khi app khởi động
  Future<void> loadSinhViens() async {
  try {
    _danhSachGoc = await DatabaseHelper().getSinhViens();
    _danhSach = List.from(_danhSachGoc);
    print('=== loadSinhViens: ${_danhSach.length} sinh viên');
    notifyListeners();
  } catch (e) {
    print('=== LỖI load: $e');
  }
}

  // Thêm mới
Future<void> addSinhVien(String name, String email) async {
  try {
    print('=== Bắt đầu thêm: $name - $email');
    final sv = SinhVien(name: name, email: email);
    await DatabaseHelper().insertSinhVien(sv);
    print('=== Đã insert xong');
    await loadSinhViens();
    print('=== Đã load xong, danh sách: ${_danhSach.length} người');
  } catch (e) {
    print('=== LỖI: $e');
  }
}



  // Cập nhật
  Future<void> updateSinhVien(SinhVien sv) async {
    await DatabaseHelper().updateSinhVien(sv);
    await loadSinhViens();
  }

  // Xóa
  Future<void> deleteSinhVien(int id) async {
    await DatabaseHelper().deleteSinhVien(id);
    await loadSinhViens();
  }

  // Tìm kiếm (lọc trên danh sách gốc)
  void search(String keyword) {
    if (keyword.isEmpty) {
      _danhSach = List.from(_danhSachGoc);
    } else {
      _danhSach = _danhSachGoc
          .where((sv) =>
              sv.name.toLowerCase().contains(keyword.toLowerCase()) ||
              sv.email.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}