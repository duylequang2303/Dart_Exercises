import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/sanpham.dart';
import '../provider/sanpham_provider.dart';

class SanPhamScreen extends StatefulWidget {
  const SanPhamScreen({super.key});
  @override
  State<SanPhamScreen> createState() => _SanPhamScreenState();
}

class _SanPhamScreenState extends State<SanPhamScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SanPhamProvider>().load();
    });
  }

  void _showAddDialog() {
    final tenCtrl = TextEditingController();
    final giaCtrl = TextEditingController();
    final giamGiaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Sản Phẩm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: tenCtrl, decoration: const InputDecoration(labelText: 'Tên sản phẩm')),
            TextField(controller: giaCtrl, decoration: const InputDecoration(labelText: 'Đơn giá'), keyboardType: TextInputType.number),
            TextField(controller: giamGiaCtrl, decoration: const InputDecoration(labelText: 'Giảm giá'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final ten = tenCtrl.text.trim();
              final gia = double.tryParse(giaCtrl.text) ?? 0;
              final giamGia = double.tryParse(giamGiaCtrl.text) ?? 0;
              if (ten.isEmpty) return;
              final provider = context.read<SanPhamProvider>();
              Navigator.pop(ctx);
              provider.add(ten, gia, giamGia);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(SanPham sp) {
    final tenCtrl = TextEditingController(text: sp.ten);
    final giaCtrl = TextEditingController(text: sp.gia.toString());
    final giamGiaCtrl = TextEditingController(text: sp.giamGia.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chi tiết Sản Phẩm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: tenCtrl, decoration: const InputDecoration(labelText: 'Tên sản phẩm')),
            TextField(controller: giaCtrl, decoration: const InputDecoration(labelText: 'Đơn giá'), keyboardType: TextInputType.number),
            TextField(controller: giamGiaCtrl, decoration: const InputDecoration(labelText: 'Giảm giá'), keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            Text('Thuế nhập khẩu: ${sp.tinhThueNhapKhau().toStringAsFixed(0)} VND',
                style: const TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final updated = SanPham(
                id: sp.id,
                ten: tenCtrl.text.trim(),
                gia: double.tryParse(giaCtrl.text) ?? 0,
                giamGia: double.tryParse(giamGiaCtrl.text) ?? 0,
              );
              final provider = context.read<SanPhamProvider>();
              Navigator.pop(ctx);
              provider.update(updated);
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
      appBar: AppBar(title: const Text('Quản lý Sản Phẩm')),
      body: Consumer<SanPhamProvider>(
        builder: (context, provider, child) {
          final list = provider.list;
          if (list.isEmpty) return const Center(child: Text('Chưa có sản phẩm'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final sp = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: ListTile(
                  onTap: () => _showDetailDialog(sp),
                  title: Text(sp.ten, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Đơn giá: ${sp.gia.toStringAsFixed(0)} VND'),
                      Text('Giảm giá: ${sp.giamGia.toStringAsFixed(0)} VND'),
                      Text('Thuế NK: ${sp.tinhThueNhapKhau().toStringAsFixed(0)} VND',
                          style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => context.read<SanPhamProvider>().delete(sp.id!),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}