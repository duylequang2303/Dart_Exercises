import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../services/mock_data_service.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});
  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final data = MockDataService.instance;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _dangTaiPhanHoi = false;
  final List<Map<String, dynamic>> _tinNhan = [];

  // Danh sách gợi ý chat thông minh
  final List<String> _goiYChat = [
    "Thực đơn giảm mỡ bụng?",
    "Hôm nay tập bài gì?",
    "Đau cơ sau tập phải làm sao?",
    "Tính BMI của tôi",
  ];

  @override
  void initState() {
    super.initState();
    _tinNhan.addAll([
      {"role": "ai", "text": "Chào bạn! Tôi là VitaTrack AI Coach. Dựa trên dữ liệu hôm nay, bạn đã đi được ${data.soBuocChan} bước. Tôi có thể giúp gì cho bạn?"},
    ]);
  }

  void _cuonXuongCuoi() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // LOGIC FAKE GỌI API AI
  void _guiTinNhan(String vanBan) async {
    if (vanBan.trim().isEmpty) return;

    // 1. Thêm tin nhắn User
    setState(() {
      _tinNhan.add({"role": "user", "text": vanBan});
      _dangTaiPhanHoi = true; // Hiện 3 chấm
    });
    _controller.clear();
    _cuonXuongCuoi();

    // 2. Giả lập delay mạng internet (1.5 giây)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 3. AI bắt đầu trả lời (Kích hoạt Typewriter)
    if (mounted) {
      setState(() {
        _dangTaiPhanHoi = false; // Tắt 3 chấm
        _tinNhan.add({"role": "ai", "text": _layCauTraLoiGia(vanBan), "isNew": true});
      });
      _cuonXuongCuoi();
    }
  }

  String _layCauTraLoiGia(String cauHoi) {
    cauHoi = cauHoi.toLowerCase();
    if (cauHoi.contains("mỡ")) {
      return "Để giảm mỡ, bạn cần thâm hụt calo. Hiện tại bạn đang nạp ${data.caloDaNap} kcal / ${data.caloMucTieu} kcal. Gợi ý: Hãy thêm 20 phút Cardio vào cuối buổi tập nhé!";
    } else if (cauHoi.contains("tập")) {
      return "Dựa trên lịch sử của bạn, hôm nay chúng ta nên tập thân trên (Upper Body). Chú trọng vào Ngực và Lưng xô. Bạn muốn tôi lên chi tiết các bài tập không?";
    } else if (cauHoi.contains("đau cơ")) {
      return "Đau cơ (DOMS) là bình thường sau khi tập nặng. Gợi ý: \n1. Uống đủ 2L nước.\n2. Ăn nhiều Protein (hiện tại bạn nạp khá ít).\n3. Giãn cơ tĩnh 15 phút trước khi ngủ.";
    }
    final randomPhanHoi = [
      "Tuyệt vời! Hãy giữ vững phong độ nhé. Cần điều chỉnh gì cứ báo tôi.",
      "Tôi đã ghi nhận. Bạn nhớ bổ sung thêm nước nhé, hiện tại mới được ${(data.soLyNuoc * 0.25).toStringAsFixed(1)} Lít thôi.",
      "Thông tin này rất thú vị. Theo góc độ dinh dưỡng, bạn đang làm rất tốt!",
    ];
    return randomPhanHoi[Random().nextInt(randomPhanHoi.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // KHU VỰC TIN NHẮN
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: _tinNhan.length + (_dangTaiPhanHoi ? 1 : 0),
            itemBuilder: (context, index) {
              // Hiển thị animation 3 chấm nếu AI đang suy nghĩ
              if (index == _tinNhan.length && _dangTaiPhanHoi) {
                return _buildThinkingBubble();
              }
              
              final tn = _tinNhan[index];
              final isAi = tn['role'] == 'ai';
              final isNew = tn['isNew'] == true; // Đánh dấu tin nhắn mới để chạy Typewriter

              return isAi 
                  ? _buildAiBubble(tn['text'], isNew: isNew) 
                  : _buildUserBubble(tn['text']);
            },
          ),
        ),

        // THANH GỢI Ý CHAT
        _buildSuggestionsBar(),
        const SizedBox(height: 12),

        // KHUNG NHẬP LIỆU
        _buildInputArea(),
      ],
    );
  }

  Widget _buildSuggestionsBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _goiYChat.map((goiY) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              backgroundColor: VitaTrackTheme.mauCard,
              side: BorderSide(color: VitaTrackTheme.mauChinh.withOpacity(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              label: Text(goiY, style: const TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 13)),
              onPressed: () {
                HapticFeedback.lightImpact(); // Rung khi bấm gợi ý
                _guiTinNhan(goiY);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: VitaTrackTheme.mauChinh,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildAiBubble(String text, {bool isNew = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16, right: 8),
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: VitaTrackTheme.mauChinh.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy, color: VitaTrackTheme.mauChinh, size: 18),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16, right: 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: VitaTrackTheme.mauCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(color: VitaTrackTheme.mauCardNhat),
              ),
              // HIỆU ỨNG GÕ CHỮ (NẾU LÀ TIN MỚI)
              child: isNew ? TypewriterText(text: text) : Text(text, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 15, height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16, right: 8),
            width: 32, height: 32,
            decoration: BoxDecoration(color: VitaTrackTheme.mauChinh.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy, color: VitaTrackTheme.mauChinh, size: 18),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: VitaTrackTheme.mauCard,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomRight: Radius.circular(20), bottomLeft: Radius.circular(4)),
            ),
            child: _DotAnimation(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: VitaTrackTheme.mauCard,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: VitaTrackTheme.mauCardNhat),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic_none, color: VitaTrackTheme.mauChuPhu),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: VitaTrackTheme.mauChu),
              decoration: const InputDecoration(
                hintText: 'Hỏi AI Coach điều gì đó...',
                hintStyle: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14),
                border: InputBorder.none,
              ),
              onSubmitted: (_) {
                HapticFeedback.mediumImpact();
                _guiTinNhan(_controller.text);
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact(); // Rung mạnh báo hiệu đã gửi
              _guiTinNhan(_controller.text);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: VitaTrackTheme.mauChinh, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: VitaTrackTheme.mauNen, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// WIDGET MA THUẬT 1: HIỆU ỨNG GÕ CHỮ (TYPEWRITER) DÀNH CHO AI
// ==========================================================
class TypewriterText extends StatefulWidget {
  final String text;
  const TypewriterText({super.key, required this.text});

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = "";
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Mỗi 30ms gõ ra 1 ký tự
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
        // Thi thoảng tạo độ rung nhẹ giả lập tiếng máy đánh chữ
        if (_currentIndex % 15 == 0) HapticFeedback.selectionClick();
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 15, height: 1.4),
    );
  }
}

// ==========================================================
// WIDGET MA THUẬT 2: HIỆU ỨNG 3 CHẤM NẢY KHI CHỜ API
// ==========================================================
class _DotAnimation extends StatefulWidget {
  @override
  State<_DotAnimation> createState() => _DotAnimationState();
}

class _DotAnimationState extends State<_DotAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final offset = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
            final opacity = (offset < 0.5 ? offset : 1.0 - offset) * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Opacity(
                opacity: opacity.clamp(0.2, 1.0),
                child: const CircleAvatar(radius: 4, backgroundColor: VitaTrackTheme.mauChinh),
              ),
            );
          }),
        );
      },
    );
  }
}