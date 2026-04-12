import 'package:flutter/material.dart';
import '../database/sanpham_db_helper.dart';
import '../model/sanpham.dart';

class SanPhamProvider extends ChangeNotifier {
  List<SanPham> _list = [];
  List<SanPham> get list => _list;

  Future<void> load() async {
    _list = await SanPhamDbHelper().getAll();
    notifyListeners();
  }

  Future<void> add(String ten, double gia, double giamGia) async {
    await SanPhamDbHelper().insert(SanPham(ten: ten, gia: gia, giamGia: giamGia));
    await load();
  }

  Future<void> update(SanPham sp) async {
    await SanPhamDbHelper().update(sp);
    await load();
  }

  Future<void> delete(int id) async {
    await SanPhamDbHelper().delete(id);
    await load();
  }
}