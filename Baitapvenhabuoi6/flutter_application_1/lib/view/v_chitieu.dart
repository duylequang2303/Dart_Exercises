import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/chitieu_provider.dart';

class ChiTieuScreen extends StatefulWidget {
  const ChiTieuScreen({super.key});
  @override
  State<ChiTieuScreen> createState() => _ChiTieuScreenState();
}

class _ChiTieuScreenState extends State<ChiTieuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChiTieuProvider>().load();
    });
  }

  void _showAddDialog() {
    final noiDungCtrl = TextEditingController();
    final soTienCtrl = TextEditingController();
    final ghiChuCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Chi Tiêu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: noiDungCtrl, decoration: const InputDecoration(labelText: 'Nội dung')),
            TextField(controller: soTienCtrl, decoration: const InputDecoration(labelText: 'Số tiền'), keyboardType: TextInputType.number),
            TextField(controller: ghiChuCtrl, decoration: const InputDecoration(labelText: 'Ghi chú')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final noiDung = noiDungCtrl.text.trim();
              final soTien = double.tryParse(soTienCtrl.text) ?? 0;
              if (noiDung.isEmpty) return;
              final provider = context.read<ChiTieuProvider>();
              Navigator.pop(ctx);
              provider.add(noiDung, soTien, ghiChuCtrl.text.trim());
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Chi Tiêu')),
      body: Consumer<ChiTieuProvider>(
        builder: (context, provider, child) {
          final list = provider.list;
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng chi tiêu:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${provider.tongChiTieu.toStringAsFixed(0)} VND',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('Chưa có chi tiêu nào'))
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final ct = list[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            child: ListTile(
                              title: Text(ct.noiDung, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: ct.ghiChu.isNotEmpty ? Text(ct.ghiChu) : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${ct.soTien.toStringAsFixed(0)} VND',
                                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => context.read<ChiTieuProvider>().delete(ct.id!),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
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