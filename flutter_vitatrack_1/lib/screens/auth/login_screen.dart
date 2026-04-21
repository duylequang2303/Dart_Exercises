import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Kiểm soát tab Đăng nhập / Đăng ký
  bool dangNhap = true;

  // Controller để lấy text từ input
  final emailController = TextEditingController();
  final matKhauController = TextEditingController();
  final tenController = TextEditingController();

  // Ẩn/hiện mật khẩu
  bool anMatKhau = true;

  @override
  void dispose() {
    emailController.dispose();
    matKhauController.dispose();
    tenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.loi != null && next.loi != previous?.loi) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.loi!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ===== LOGO =====
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: VitaTrackTheme.mauChinh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.bolt,
                  size: 50,
                  color: Color(0xFF0A0A0F),
                ),
              ),

              const SizedBox(height: 16),

              // ===== TÊN APP =====
              const Text(
                'VitaTrack',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: VitaTrackTheme.mauChinh,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                dangNhap ? 'Chào mừng trở lại!' : 'Tạo tài khoản mới',
                style: const TextStyle(
                  fontSize: 14,
                  color: VitaTrackTheme.mauChuPhu,
                ),
              ),

              const SizedBox(height: 40),

              // ===== TAB ĐĂNG NHẬP / ĐĂNG KÝ =====
              Container(
                decoration: BoxDecoration(
                  color: VitaTrackTheme.mauCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Tab Đăng nhập
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => dangNhap = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: dangNhap
                                ? VitaTrackTheme.mauChinh
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Đăng nhập',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: dangNhap
                                  ? VitaTrackTheme.mauNen
                                  : VitaTrackTheme.mauChuPhu,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tab Đăng ký
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => dangNhap = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !dangNhap
                                ? VitaTrackTheme.mauChinh
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Đăng ký',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: !dangNhap
                                  ? VitaTrackTheme.mauNen
                                  : VitaTrackTheme.mauChuPhu,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== INPUT TÊN (chỉ hiện khi Đăng ký) =====
              if (!dangNhap) ...[
                TextField(
                  controller: tenController,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: Icon(Icons.person_outline,
                        color: VitaTrackTheme.mauChuPhu),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ===== INPUT EMAIL =====
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined,
                      color: VitaTrackTheme.mauChuPhu),
                ),
              ),

              const SizedBox(height: 16),

              // ===== INPUT MẬT KHẨU =====
              TextField(
                controller: matKhauController,
                obscureText: anMatKhau,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: VitaTrackTheme.mauChuPhu),
                  suffixIcon: IconButton(
                    icon: Icon(
                      anMatKhau ? Icons.visibility_off : Icons.visibility,
                      color: VitaTrackTheme.mauChuPhu,
                    ),
                    onPressed: () => setState(() => anMatKhau = !anMatKhau),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ===== NÚT ĐĂNG NHẬP / ĐĂNG KÝ =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authState.dangTai ? null : () {
                    final email = emailController.text.trim();
                    final matKhau = matKhauController.text.trim();
                    if (dangNhap) {
                      ref.read(authProvider.notifier).dangNhap(email, matKhau);
                    } else {
                      final ten = tenController.text.trim();
                      ref.read(authProvider.notifier).dangKy(email, matKhau, ten);
                    }
                  },
                  child: authState.dangTai 
                      ? const SizedBox(
                          width: 24, 
                          height: 24, 
                          child: CircularProgressIndicator(
                            color: VitaTrackTheme.mauNen,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(dangNhap ? 'Đăng nhập' : 'Đăng ký'),
                ),
              ),

              const SizedBox(height: 16),

              // ===== NÚT GOOGLE =====
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Đăng nhập Google sau
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: VitaTrackTheme.mauChuPhu),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.g_mobiledata,
                      color: VitaTrackTheme.mauChu, size: 28),
                  label: const Text(
                    'Tiếp tục bằng Google',
                    style: TextStyle(color: VitaTrackTheme.mauChu),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}