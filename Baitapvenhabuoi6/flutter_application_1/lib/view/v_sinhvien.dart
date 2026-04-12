import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/sinhvien.dart';
import '../provider/sinhvien_provider.dart';

class SinhVienScreen extends StatefulWidget {
  const SinhVienScreen({super.key});

  @override
  State<SinhVienScreen> createState() => _SinhVienScreenState();
}

class _SinhVienScreenState extends State<SinhVienScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Gọi sau khi widget build xong mới load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SinhVienProvider>().loadSinhViens();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Dialog THÊM sinh viên ──────────────────────────────
 void _showAddDialog() {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Thêm Sinh Viên'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Tên Sinh Viên'),
            autofocus: true,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = nameCtrl.text.trim();
            final email = emailCtrl.text.trim();

            if (name.isEmpty || email.isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập đầy đủ!')),
              );
              return;
            }

            // Lấy provider TRƯỚC khi đóng dialog
            final provider = context.read<SinhVienProvider>();

            // Đóng dialog TRƯỚC
            Navigator.pop(ctx);

            // Lưu vào SQLite SAU — không còn dùng context nữa nên an toàn
            provider.addSinhVien(name, email);
          },
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
}

  // ── Dialog CHI TIẾT + CẬP NHẬT sinh viên ─────────────
  void _showDetailDialog(SinhVien sv) {
    final nameCtrl = TextEditingController(text: sv.name);
    final emailCtrl = TextEditingController(text: sv.email);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thông tin chi tiết của sinh viên'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dữ liệu: ${sv.id} ${sv.name}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            const Text('Tên Sinh Viên'),
            TextField(controller: nameCtrl),
            const SizedBox(height: 10),
            const Text('Email'),
            TextField(controller: emailCtrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Hủy
            child: const Text('Hủy'),
          ),
          ElevatedButton(
  onPressed: () {
    final updated = SinhVien(
      id: sv.id,
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
    );

    // Lấy provider TRƯỚC
    final provider = context.read<SinhVienProvider>();

    // Đóng TRƯỚC
    Navigator.pop(ctx);

    // Cập nhật SAU
    provider.updateSinhVien(updated);
  },
  child: const Text('Cập nhật'),
),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Thanh tìm kiếm thay AppBar ──────────────────
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm sinh viên...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54),
          ),
          onChanged: (value) {
            // Mỗi khi gõ → gọi search trong provider
            context.read<SinhVienProvider>().search(value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchCtrl.clear();
              context.read<SinhVienProvider>().search('');
            },
          ),
        ],
      ),

      // ── Danh sách sinh viên ─────────────────────────
      body: Consumer<SinhVienProvider>(
        builder: (context, provider, child) {
          final list = provider.danhSach;

          if (list.isEmpty) {
            return const Center(
              child: Text('Chưa có thông tin sinh viên'),
            );
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final sv = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: ListTile(
                  // Avatar
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  // Tên sinh viên
                  title: Text(
                    sv.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                  // Email
                  subtitle: Text(sv.email),
                  // Nhấn vào item → xem chi tiết + cập nhật
                  onTap: () => _showDetailDialog(sv),
                  // Icon thùng rác → xóa
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await context
                          .read<SinhVienProvider>()
                          .deleteSinhVien(sv.id!);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),

      // ── Nút + góc dưới phải ─────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}