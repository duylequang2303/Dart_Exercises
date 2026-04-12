import 'package:flutter/material.dart';

class BaiTap02 extends StatelessWidget {
  const BaiTap02({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text("Mô phỏng MoMo", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 1. Grid các dịch vụ chính
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            padding: const EdgeInsets.all(10),
            children: const [
              MomoService(Icons.send, "Chuyển tiền"),
              MomoService(Icons.receipt_long, "Thanh toán\nhóa đơn"),
              MomoService(Icons.phone_android, "Nạp tiền\nđiện thoại"),
              MomoService(Icons.card_giftcard, "Mua mã thẻ\ndi động"),
              MomoService(Icons.history, "Hoa Đổi\nMoMo"),
              MomoService(Icons.directions_walk, "Đi bộ cùng\nMaMa"),
              MomoService(Icons.water_drop, "Thanh toán\nnước"),
              MomoService(Icons.grid_view, "Xem thêm\ndịch vụ"),
            ],
          ),

          // 2. Tiêu đề Sự kiện
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              "Sự kiện đang diễn ra",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),

          // 3. Banner quảng cáo có hình ảnh
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                image: NetworkImage('https://img.pikbest.com/origin/09/20/35/067pIkbEsTq8e.jpg!sw800'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    color: Colors.black45,
                    child: const Text(
                      "Đến 50 triệu",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. MoMo đề xuất
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text("MoMo đề xuất", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          
          // Danh sách ngang cho mục đề xuất
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: const [
                MomoSuggestItem(Icons.attach_money, "Vay nhanh"),
                MomoSuggestItem(Icons.savings, "Túi Thần Tài"),
                MomoSuggestItem(Icons.credit_card, "Ví Trả Sau"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Service có hiệu ứng Hover/Tap (InkWell)
class MomoService extends StatelessWidget {
  final IconData icon;
  final String label;
  const MomoService(this.icon, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {}, // Thêm sự kiện Tap để có hiệu ứng hover mờ
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.pink, size: 28),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, height: 1.2),
          ),
        ],
      ),
    );
  }
}

// Widget cho mục đề xuất
class MomoSuggestItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const MomoSuggestItem(this.icon, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.orange, size: 30),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}