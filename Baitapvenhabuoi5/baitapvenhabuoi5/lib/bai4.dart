import 'package:flutter/material.dart';

class BaiTap04 extends StatefulWidget {
  const BaiTap04({super.key});
  @override
  State<BaiTap04> createState() => _BaiTap04State();
}

class _BaiTap04State extends State<BaiTap04> {
  // Hàm hiển thị hộp thoại xác nhận khi thêm vào giỏ hàng [cite: 820, 843]
  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn vừa thêm sản phẩm vào Giỏ hàng"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Không")),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đồng ý")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cửa hàng điện thoại"),
        backgroundColor: Colors.orange,
        actions: [IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {})],
      ),
      // Menu Drawer bên trái [cite: 784, 807, 808, 809]
      drawer: Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              accountName: Text("Vũ Văn Vĩnh"),
              accountEmail: Text("vinhvv@huit.edu.vn"),
              currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person)),
            ),
            ListTile(leading: const Icon(Icons.store), title: const Text("Cửa hàng"), onTap: () {}),
            ListTile(leading: const Icon(Icons.shopping_basket), title: const Text("Giỏ hàng"), onTap: () {}),
            ListTile(leading: const Icon(Icons.exit_to_app), title: const Text("Thoát"), onTap: () {}),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text("Chọn sản phẩm bạn muốn sử dụng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          // Danh sách sản phẩm dạng Grid [cite: 799, 810, 814]
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: [
                      Container(height: 100, color: Colors.grey[300], child: const Icon(Icons.phone_iphone, size: 50)),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Điện thoại 01", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Text("1200.0", style: TextStyle(color: Colors.teal)),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _showConfirmDialog, 
                        child: const Icon(Icons.add)
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}