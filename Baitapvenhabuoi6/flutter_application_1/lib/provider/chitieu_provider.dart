import 'package:flutter/material.dart';
import '../database/chitieu_db_helper.dart';
import '../model/chitieu.dart';

class ChiTieuProvider extends ChangeNotifier {
  List<ChiTieu> _list = [];
  List<ChiTieu> get list => _list;

  double get tongChiTieu => _list.fold(0, (sum, ct) => sum + ct.soTien);

  Future<void> load() async {
    _list = await ChiTieuDbHelper().getAll();
    notifyListeners();
  }

  Future<void> add(String noiDung, double soTien, String ghiChu) async {
    await ChiTieuDbHelper().insert(ChiTieu(noiDung: noiDung, soTien: soTien, ghiChu: ghiChu));
    await load();
  }

  Future<void> delete(int id) async {
    await ChiTieuDbHelper().delete(id);
    await load();
  }
}