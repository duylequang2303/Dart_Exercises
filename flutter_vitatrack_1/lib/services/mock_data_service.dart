import 'dart:async';
import 'package:flutter/material.dart';

class MockDataService extends ChangeNotifier {
  static final MockDataService instance = MockDataService._internal();
  MockDataService._internal() { _startSensorSim(); }

  // === DỮ LIỆU GỐC ===
  int _steps = 8234;
  int _stepGoal = 10000;
  int _heartRate = 72;
  int _caloNap = 1760;
  int _caloMucTieu = 2200;
  int _lyNuoc = 6;
  String buoiDangChon = "Bữa trưa";

  List<Map<String, dynamic>> lichSuBuaAn = [
    {"ten": "Bữa sáng", "gio": "07:30", "chiTiet": "Phở bò, Trà sữa", "calo": 450, "icon": Icons.breakfast_dining},
    {"ten": "Bữa trưa", "gio": "12:00", "chiTiet": "Cơm tấm sườn", "calo": 620, "icon": Icons.lunch_dining},
  ];

  // === GETTER TIẾNG VIỆT ===
  int get soBuocChan => _steps;
  int get buocChanMucTieu => _stepGoal;
  int get nhipTim => _heartRate;
  int get caloDaNap => _caloNap;
  int get caloMucTieu => _caloMucTieu;
  int get soLyNuoc => _lyNuoc;

  // === GETTER TIẾNG ANH (giữ tương thích) ===
  int get steps => _steps;
  int get stepGoal => _stepGoal;
  int get heartRate => _heartRate;
  int get caloNap => _caloNap;
  int get lyNuoc => _lyNuoc;
  List<Map<String, dynamic>> get mealHistory => lichSuBuaAn;

  // === ACTIONS ===
  void uongNuoc() { if (_lyNuoc < 10) { _lyNuoc++; notifyListeners(); } }
  void botNuoc()  { if (_lyNuoc > 0)  { _lyNuoc--; notifyListeners(); } }
  void addWater()    => uongNuoc();
  void removeWater() => botNuoc();

  void capNhatBuocChan(int value) { _steps += value; notifyListeners(); }
  void updateSteps(int value) => capNhatBuocChan(value);

  void themMonVaoLichSu(String ten, int calo, String chiTiet) {
    _caloNap += calo;
    lichSuBuaAn.insert(0, {
      "ten": buoiDangChon,
      "gio": "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      "chiTiet": "$ten ($chiTiet)",
      "calo": calo,
      "icon": Icons.lunch_dining,
    });
    notifyListeners();
  }

  void themMonAn(int calo, double protein, double carbs, double fat) {
    _caloNap += calo;
    lichSuBuaAn.insert(0, {
      "ten": buoiDangChon,
      "gio": "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      "chiTiet": "P:${protein.toInt()}g, C:${carbs.toInt()}g, F:${fat.toInt()}g",
      "calo": calo,
      "icon": Icons.lunch_dining,
    });
    notifyListeners();
  }

  // Alias cũ
  void addMeal(String name, int kcal, String detail) =>
      themMonVaoLichSu(name, kcal, detail);

  void _startSensorSim() {
    Timer.periodic(const Duration(seconds: 4), (timer) {
      _steps += 1;
      _heartRate = 70 + (timer.tick % 12);
      notifyListeners();
    });
  }
}