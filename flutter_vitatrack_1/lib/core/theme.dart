import 'package:flutter/material.dart';

class VitaTrackTheme {
  // ==========================================
  // 1. BẢNG MÀU CHUẨN (PALETTE)
  // ==========================================
  static const Color mauNen = Color(0xFF0A0A0F);      // Đen sâu (Deep Space)
  static const Color mauCard = Color(0xFF16161E);     // Đen xám (Card background)
  static const Color mauCardNhat = Color(0xFF22222E); // Card phụ/Highlight
  
  static const Color mauChinh = Color(0xFF00E5FF);    // Cyan Neon (Chủ đạo)
  static const Color mauPhu = Color(0xFF7000FF);      // Tím Electric (Phụ)
  
  static const Color mauThanhCong = Color(0xFF00FF94); // Xanh lá Neon
  static const Color mauCanhBao = Color(0xFFFFB800);  // Vàng hổ phách
  static const Color mauNguyHiem = Color(0xFFFF2D55);  // Đỏ rực
  
  static const Color mauChu = Color(0xFFFFFFFF);      // Trắng thuần
  static const Color mauChuPhu = Color(0xFF8E8E93);   // Xám hệ thống (iOS style)

  // ==========================================
  // 2. CHỈ SỐ BO GÓC & ĐỘ DÀY
  // ==========================================
  static const double boGocNho = 8.0;
  static const double boGocVua = 16.0;
  static const double boGocLon = 24.0;
  static const double boGocTron = 50.0;

  // ==========================================
  // 3. ĐỊNH NGHĨA KIỂU CHỮ (TEXT STYLES)
  // ==========================================
  // Thay vì viết TextStyle() ở mọi nơi, hãy gọi: VitaTrackTheme.tieuDeLon
  
  static const TextStyle tieuDeLon = TextStyle(
    color: mauChu,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle tieuDeVua = TextStyle(
    color: mauChu,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle tieuDeNho = TextStyle(
    color: mauChu,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle vanBanChinh = TextStyle(
    color: mauChu,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle vanBanPhu = TextStyle(
    color: mauChuPhu,
    fontSize: 13,
    height: 1.4,
  );

  static const TextStyle chuThich = TextStyle(
    color: mauChuPhu,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  // ==========================================
  // 4. HIỆU ỨNG ĐỔ BÓNG & DECORATION
  // ==========================================
  static BoxDecoration hopCard = BoxDecoration(
    color: mauCard,
    borderRadius: BorderRadius.circular(boGocVua),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration hopVienNeon = BoxDecoration(
    color: mauCard,
    borderRadius: BorderRadius.circular(boGocVua),
    border: Border.all(color: mauChinh.withOpacity(0.3), width: 1),
  );

  // ==========================================
  // 5. THEME DATA CHO MATERIAL APP
  // ==========================================
  static ThemeData layTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: mauChinh,
      scaffoldBackgroundColor: mauNen,
      fontFamily: 'SF Pro Display', // Hoặc Inter nếu bạn có cài font
      cardColor: mauCard,
      colorScheme: const ColorScheme.dark(
        primary: mauChinh,
        secondary: mauPhu,
        surface: mauCard,
      ),
      // Cấu hình mặc định cho các Widget
      dividerTheme: const DividerThemeData(color: mauCardNhat, thickness: 1),
    );
  }
}