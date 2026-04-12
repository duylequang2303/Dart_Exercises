import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dữ liệu giả lập chuẩn UI để trình diễn tính năng Vuốt Xóa
  final List<Map<String, dynamic>> _danhSachThongBao = [
    {
      "id": "1",
      "tieuDe": "Hoàn thành mục tiêu bước chân! 🏆",
      "noiDung": "Chúc mừng! Bạn đã đạt 10,000 bước ngày hôm nay. Hãy duy trì phong độ nhé.",
      "thoiGian": "Vừa xong",
      "daDoc": false,
      "loai": "hoatDong",
      "icon": Icons.do_not_step,
      "mau": VitaTrackTheme.mauThanhCong
    },
    {
      "id": "2",
      "tieuDe": "Đến giờ uống nước rồi 💧",
      "noiDung": "Cơ thể bạn cần được nạp nước. Hãy uống một ly nước 250ml ngay nào.",
      "thoiGian": "2 giờ trước",
      "daDoc": true,
      "loai": "nuoc",
      "icon": Icons.water_drop,
      "mau": VitaTrackTheme.mauChinh
    },
    {
      "id": "3",
      "tieuDe": "Gợi ý bữa tối từ AI Coach 🤖",
      "noiDung": "Hôm nay bạn đã nạp khá nhiều Carbs. Bữa tối nên ưu tiên Protein và Rau xanh (như Ức gà áp chảo).",
      "thoiGian": "5 giờ trước",
      "daDoc": true,
      "loai": "ai",
      "icon": Icons.smart_toy,
      "mau": VitaTrackTheme.mauPhu
    },
    {
      "id": "4",
      "tieuDe": "Cảnh báo nhịp tim ❤️",
      "noiDung": "Nhịp tim của bạn lúc 14:30 có dấu hiệu tăng cao đột ngột (125 BPM) khi đang nghỉ ngơi.",
      "thoiGian": "Hôm qua",
      "daDoc": true,
      "loai": "canhBao",
      "icon": Icons.favorite,
      "mau": VitaTrackTheme.mauNguyHiem
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDanhSachThongBao(), // Tab Tất cả
                  _buildDanhSachThongBao(chiHienChuaDoc: true), // Tab Chưa đọc
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: VitaTrackTheme.mauCard, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new, color: VitaTrackTheme.mauChu, size: 18),
                ),
              ),
              const SizedBox(width: 16),
              const Text('Thông báo', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          // Nút Đánh dấu đã đọc tất cả
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() {
                for (var tb in _danhSachThongBao) { tb['daDoc'] = true; }
              });
            },
            child: const Icon(Icons.done_all, color: VitaTrackTheme.mauChinh),
          )
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(30)),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(color: VitaTrackTheme.mauChinh, borderRadius: BorderRadius.circular(30)),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: VitaTrackTheme.mauNen,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelColor: VitaTrackTheme.mauChuPhu,
          onTap: (_) => HapticFeedback.selectionClick(),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chưa đọc'),
          ],
        ),
      ),
    );
  }

  Widget _buildDanhSachThongBao({bool chiHienChuaDoc = false}) {
    final listHienThi = chiHienChuaDoc 
        ? _danhSachThongBao.where((tb) => tb['daDoc'] == false).toList()
        : _danhSachThongBao;

    if (listHienThi.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: listHienThi.length,
      itemBuilder: (context, index) {
        final tb = listHienThi[index];

        // 1. STAGGERED ANIMATION: Trượt từ phải sang trái lần lượt
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 150)), // Delay dựa theo index
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - value), 0), // Trượt ngang
              child: Opacity(opacity: value, child: child),
            );
          },
          // 2. TÍNH NĂNG "VUỐT ĐỂ XÓA" QUYỀN LỰC
          child: Dismissible(
            key: Key(tb['id']),
            direction: DismissDirection.endToStart, // Chỉ cho vuốt sang trái
            onDismissed: (direction) {
              HapticFeedback.mediumImpact(); // Rung khi xóa
              setState(() => _danhSachThongBao.removeWhere((item) => item['id'] == tb['id']));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã xóa thông báo'),
                  backgroundColor: VitaTrackTheme.mauCardNhat,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            // Giao diện nền đỏ hiện ra khi vuốt
            background: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(color: VitaTrackTheme.mauNguyHiem, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocVua)),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete_outline, color: VitaTrackTheme.mauChu, size: 28),
            ),
            child: _buildCardThongBao(tb),
          ),
        );
      },
    );
  }

  Widget _buildCardThongBao(Map<String, dynamic> tb) {
    bool daDoc = tb['daDoc'];
    return GestureDetector(
      onTap: () {
        if (!daDoc) {
          HapticFeedback.lightImpact();
          setState(() => tb['daDoc'] = true);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: daDoc ? VitaTrackTheme.mauCard.withOpacity(0.5) : VitaTrackTheme.mauCard,
          borderRadius: BorderRadius.circular(VitaTrackTheme.boGocVua),
          border: Border.all(
            color: daDoc ? Colors.transparent : VitaTrackTheme.mauChinh.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon thông báo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: tb['mau'].withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(tb['icon'], color: tb['mau'], size: 20),
            ),
            const SizedBox(width: 16),
            
            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tb['tieuDe'],
                    style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16, fontWeight: daDoc ? FontWeight.w600 : FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tb['noiDung'],
                    style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tb['thoiGian'],
                    style: TextStyle(color: daDoc ? VitaTrackTheme.mauChuPhu.withOpacity(0.5) : VitaTrackTheme.mauChinh, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            // Chấm xanh báo chưa đọc
            if (!daDoc)
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 10, height: 10,
                decoration: const BoxDecoration(color: VitaTrackTheme.mauChinh, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  // Giao diện khi không có thông báo
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, val, child) => Transform.scale(scale: val, child: child),
            child: Icon(Icons.notifications_off_outlined, size: 80, color: VitaTrackTheme.mauCardNhat),
          ),
          const SizedBox(height: 16),
          const Text('Bạn đã xem hết thông báo!', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 16)),
        ],
      ),
    );
  }
}