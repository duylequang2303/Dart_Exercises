# ===================================================
# KHUNG FLUTTER SQLITE - CHỈ ĐỌC CHỖ CÓ ← ĐỔI
# ===================================================

# ═══════════════════════════════════════════════════
# BƯỚC 1: pubspec.yaml - PASTE ĐOẠN NÀY VÀO
# ═══════════════════════════════════════════════════

dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.9.0
  shared_preferences: ^2.2.0

# Sau đó chạy: flutter pub get


# ═══════════════════════════════════════════════════
# BƯỚC 2: database_helper.dart
# CHỈ CẦN ĐỔI 2 CHỖ:
#   [A] Tên bảng và cột theo đề
#   [B] Dữ liệu mẫu insert
# ═══════════════════════════════════════════════════

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {

    # ← ĐỔI [A]: THAY TOÀN BỘ PHẦN NÀY THEO ĐỀ BÀI
    # Đề cho bảng gì thì tạo bảng đó, cột gì thì tạo cột đó
    await db.execute('''
      CREATE TABLE TenBang1 (        ← đổi TenBang1
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tenCot1 TEXT,                ← đổi tên cột
        tenCot2 REAL,                ← TEXT=chữ, REAL=số thập phân, INTEGER=số nguyên
        tenCot3 INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE TenBang2 (        ← đổi TenBang2
        id TEXT PRIMARY KEY,         ← nếu id là chữ thì dùng TEXT
        tenCot1 TEXT,
        tenCot2 TEXT
      )
    ''');

    # ← ĐỔI [B]: INSERT DỮ LIỆU MẪU (tài khoản test, danh mục mẫu...)
    await db.insert('TenBang2', {
      'id': 'admin',
      'tenCot1': 'gia tri mau',
      'tenCot2': 'gia tri mau'
    });
  }

  # ══════════════════════════════════════
  # PHẦN NÀY KHÔNG ĐỔI GÌ HẾT - COPY Y CHANG
  # ══════════════════════════════════════

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
      String table, String where, List<dynamic> args) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: args);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<int> updateById(String table, Map<String, dynamic> data, int id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteById(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<double> sumColumn(String table, String col, String whereCol, dynamic whereVal) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM($col) as total FROM $table WHERE $whereCol = ?',
      [whereVal],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}


# ═══════════════════════════════════════════════════
# BƯỚC 3: main.dart
# CHỈ ĐỔI: tên trang đầu tiên (home:)
# ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'pages/login_page.dart';      ← đổi nếu tên file khác

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ten App',               ← ĐỔI tên app
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),        ← ĐỔI trang đầu tiên
    );
  }
}


# ═══════════════════════════════════════════════════
# BƯỚC 4: login_page.dart
# CHỈ ĐỔI:
#   [A] Tên bảng User → tên bảng user trong đề
#   [B] 'id' và 'password' → tên cột trong đề
#   [C] Tên trang chuyển đến sau login
# ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_helper.dart';
import 'summary_page.dart';          ← ĐỔI [C] nếu tên trang khác

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idCtrl   = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure  = true;
  bool _remember = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  void _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('remember') ?? false) {
      setState(() {
        _idCtrl.text   = prefs.getString('saved_id')   ?? '';
        _passCtrl.text = prefs.getString('saved_pass') ?? '';
        _remember      = true;
      });
    }
  }

  void _login() async {
    final id   = _idCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (id.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long nhap day du!')));
      return;
    }

    final users = await DatabaseHelper.instance.getAll('User');  ← ĐỔI [A] tên bảng
    final found = users.where(
      (u) => u['id'] == id && u['password'] == pass             ← ĐỔI [B] tên cột
    ).toList();

    if (found.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sai tai khoan hoac mat khau!'),
          backgroundColor: Colors.red));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (_remember) {
      await prefs.setString('saved_id',   id);
      await prefs.setString('saved_pass', pass);
      await prefs.setBool('remember',     true);
    } else {
      await prefs.clear();
    }

    Navigator.pushReplacement(context,
      MaterialPageRoute(
        builder: (_) => SummaryPage(userId: id)));   ← ĐỔI [C] tên trang + tham số
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(children: [
            const Text('Dang Nhap',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),

            TextField(
              controller: _idCtrl,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder())),
            const SizedBox(height: 16),

            TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure)))),
            const SizedBox(height: 8),

            Row(children: [
              Checkbox(
                value: _remember,
                onChanged: (v) => setState(() => _remember = v!)),
              const Text('Ghi nho mat khau')]),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _login,
                child: const Text('DANG NHAP'))),
          ]),
        ),
      ),
    );
  }
}


# ═══════════════════════════════════════════════════
# BƯỚC 5: add_xxx_page.dart  (page nhập liệu)
# CHỈ ĐỔI:
#   [A] Tên class và file
#   [B] Các TextEditingController theo field đề bài
#   [C] Phần validate trong _save()
#   [D] Tên bảng và cột khi insert
#   [E] UI: thêm/bớt TextField theo đề
# ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'summary_page.dart';

class AddXxxPage extends StatefulWidget {           ← ĐỔI [A] tên class
  final String userId;
  const AddXxxPage({super.key, required this.userId});
  @override
  State<AddXxxPage> createState() => _AddXxxPageState();  ← ĐỔI [A]
}

class _AddXxxPageState extends State<AddXxxPage> {  ← ĐỔI [A]

  # ← ĐỔI [B]: thêm controller cho mỗi field đề bài yêu cầu
  final _tenCtrl    = TextEditingController();
  final _soTienCtrl = TextEditingController();
  final _ghiChuCtrl = TextEditingController();
  String _loai = 'chi';           # biến cho toggle/dropdown
  String? _danhMuc;               # biến cho dropdown
  List<String> _danhSachDM = [];  # danh sách dropdown

  @override
  void initState() {
    super.initState();
    _loadDanhMuc();  # load dropdown từ DB nếu cần
  }

  void _loadDanhMuc() async {
    final rows = await DatabaseHelper.instance.queryWhere(
      'DanhMuc', 'categoryType = ?', [_loai]);   ← ĐỔI tên bảng và cột
    setState(() {
      _danhSachDM = rows.map((r) => r['categoryName'] as String).toList();
      _danhMuc = _danhSachDM.isNotEmpty ? _danhSachDM.first : null;
    });
  }

  void _save() async {
    # ← ĐỔI [C]: validate từng field đề yêu cầu
    if (_tenCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chua nhap ten!')));
      return;
    }
    if (double.tryParse(_soTienCtrl.text.trim()) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('So tien khong hop le!')));
      return;
    }

    # ← ĐỔI [D]: tên bảng và tên cột khớp với CREATE TABLE ở database_helper
    await DatabaseHelper.instance.insert('GiaoDich', {
      'tenCot1':    _tenCtrl.text.trim(),
      'tenCot2':    double.parse(_soTienCtrl.text.trim()),
      'tenCot3':    _loai,
      'tenCot4':    _danhMuc,
      'tenCot5':    _ghiChuCtrl.text.trim(),
      'user_id':    widget.userId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Luu thanh cong!'), backgroundColor: Colors.green));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Them moi')),   ← ĐỔI tiêu đề
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          # ← ĐỔI [E]: thêm/bớt widget theo đề

          # --- TOGGLE THU/CHI (nếu đề cần) ---
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () { setState(() => _loai = 'thu'); _loadDanhMuc(); },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _loai == 'thu' ? Colors.blue : Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
                child: Text('Thu', style: TextStyle(
                  color: _loai == 'thu' ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold))))),
            Expanded(child: GestureDetector(
              onTap: () { setState(() => _loai = 'chi'); _loadDanhMuc(); },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _loai == 'chi' ? Colors.blue : Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8), bottomRight: Radius.circular(8))),
                child: Text('Chi', style: TextStyle(
                  color: _loai == 'chi' ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold))))),
          ]),
          const SizedBox(height: 20),

          # --- TEXTFIELD THƯỜNG ---
          TextField(
            controller: _tenCtrl,
            decoration: const InputDecoration(
              labelText: 'Ten',           ← ĐỔI label
              border: OutlineInputBorder())),
          const SizedBox(height: 16),

          # --- TEXTFIELD SỐ ---
          TextField(
            controller: _soTienCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'So tien',       ← ĐỔI label
              border: OutlineInputBorder())),
          const SizedBox(height: 16),

          # --- DROPDOWN ---
          DropdownButtonFormField<String>(
            value: _danhMuc,
            decoration: const InputDecoration(
              labelText: 'Danh muc',      ← ĐỔI label
              border: OutlineInputBorder()),
            items: _danhSachDM.map((c) =>
              DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _danhMuc = v)),
          const SizedBox(height: 16),

          # --- GHI CHÚ ---
          TextField(
            controller: _ghiChuCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Ghi chu',
              border: OutlineInputBorder())),
          const SizedBox(height: 24),

          # --- NÚT LƯU ---
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('LUU', style: TextStyle(fontSize: 16)))),
        ]),
      ),
    );
  }
}


# ═══════════════════════════════════════════════════
# BƯỚC 6: summary_page.dart  (trang tổng hợp)
# CHỈ ĐỔI:
#   [A] Tên bảng và cột khi tính tổng
#   [B] UI hiển thị thêm thông tin nếu đề yêu cầu
# ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'add_xxx_page.dart';           ← ĐỔI tên file

class SummaryPage extends StatefulWidget {
  final String userId;
  const SummaryPage({super.key, required this.userId});
  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  double _tongThu = 0;
  double _tongChi = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    # ← ĐỔI [A]: 'GiaoDich' = tên bảng, 'totalAmount' = tên cột số tiền
    #             'type' = tên cột loại, 'thu'/'chi' = giá trị trong DB
    #             'user_id' = tên cột khóa ngoại
    final thu = await DatabaseHelper.instance.sumColumn(
      'GiaoDich', 'totalAmount', 'user_id', widget.userId);
      # Nếu cần lọc theo type thì dùng rawQuery tự viết

    setState(() {
      _tongThu = thu;
    });
  }

  String _format(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tong Hop')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [

          # ← ĐỔI [B]: đề yêu cầu hiển thị gì thì thêm vào đây
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              const Text('Tong thu', style: TextStyle(color: Colors.grey)),
              Text(_format(_tongThu),
                style: const TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 20),
              const Text('Tong chi', style: TextStyle(color: Colors.grey)),
              Text('-${_format(_tongChi)}',
                style: const TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold, color: Colors.red)),
            ]),
          ),
        ]),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context,
            MaterialPageRoute(
              builder: (_) => AddXxxPage(userId: widget.userId)));  ← ĐỔI tên class
          if (result == true) _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Them moi')),
    );
  }
}


# ═══════════════════════════════════════════════════
# TÓM TẮT: KHI ĐỌC ĐỀ THÌ CHÚ Ý CÁI GÌ?
# ═══════════════════════════════════════════════════

# 1. CÓ BAO NHIÊU BẢNG?
#    → Tạo bấy nhiêu CREATE TABLE trong database_helper.dart

# 2. MỖI BẢNG CÓ CỘT GÌ, KIỂU GÌ?
#    → TEXT = chữ | REAL = số thập phân | INTEGER = số nguyên

# 3. CÓ BAO NHIÊU TRANG?
#    → Tạo bấy nhiêu file trong pages/

# 4. TRANG NÀO CHUYỂN SANG TRANG NÀO?
#    → Dùng Navigator.push hoặc Navigator.pushReplacement

# 5. CÓ DROPDOWN KHÔNG?
#    → Load từ DB trong initState → _loadDanhMuc()

# 6. CÓ TÍNH TỔNG KHÔNG?
#    → Dùng hàm sumColumn() trong DatabaseHelper

# 7. CÓ GHI NHỚ ĐĂNG NHẬP KHÔNG?
#    → Dùng SharedPreferences trong login_page.dart
