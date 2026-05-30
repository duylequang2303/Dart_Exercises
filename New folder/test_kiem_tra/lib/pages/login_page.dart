import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_helper.dart';
import 'summary_page.dart';

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

  // Load lai thong tin da luu neu co
  void _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember') ?? false;
    if (remember) {
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

    // Kiem tra trong
    if (id.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long nhap day du thong tin!')));
      return;
    }

    // Kiem tra trong DB
    final users = await DatabaseHelper.instance.getAll('User');
    final found = users.where(
      (u) => u['id'] == id && u['password'] == pass
    ).toList();

    if (found.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sai tai khoan hoac mat khau!'),
          backgroundColor: Colors.red,
        ));
      return;
    }

    // Luu neu tick "ghi nho"
    final prefs = await SharedPreferences.getInstance();
    if (_remember) {
      await prefs.setString('saved_id',   id);
      await prefs.setString('saved_pass', pass);
      await prefs.setBool('remember',     true);
    } else {
      await prefs.remove('saved_id');
      await prefs.remove('saved_pass');
      await prefs.setBool('remember', false);
    }

    // Chuyen sang trang tong hop
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SummaryPage(userId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet,
                  size: 80, color: Colors.blue),
              const SizedBox(height: 12),
              const Text('Dang Nhap',
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),

              // Username
              TextField(
                controller: _idCtrl,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Remember me
              Row(
                children: [
                  Checkbox(
                    value: _remember,
                    onChanged: (v) =>
                        setState(() => _remember = v ?? false),
                  ),
                  const Text('Ghi nho mat khau'),
                ],
              ),
              const SizedBox(height: 16),

              // Nut dang nhap
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text('DANG NHAP',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}