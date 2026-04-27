import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

class LiveWorkoutScreen extends StatefulWidget {
  final String tenBaiTap;
  final IconData iconBaiTap;

  const LiveWorkoutScreen({
    super.key, 
    required this.tenBaiTap, 
    required this.iconBaiTap
  });

  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> with TickerProviderStateMixin {
  bool _dangDemNguoc = true;
  int _soDemNguoc = 3;
  bool _daKetThuc = false; 
  
  int _thoiGianGiay = 0;
  int _nhipTim = 95;
  double _calo = 0.0;
  Timer? _workoutTimer;
  Timer? _sensorTimer;

  late AnimationController _holdController;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    
    _holdController.addListener(() {
      if (mounted) setState(() {}); 
      if (_holdController.value == 1.0 && !_daKetThuc) {
        _ketThucBaiTap(); 
      }
    });

    _batDauDemNguoc();
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _sensorTimer?.cancel();
    _holdController.dispose();
    super.dispose();
  }

  void _batDauDemNguoc() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_soDemNguoc > 1) {
        if (mounted) {
          setState(() {
            _soDemNguoc--;
            HapticFeedback.heavyImpact(); 
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _dangDemNguoc = false; 
            HapticFeedback.vibrate(); 
          });
          _batDauLiveTracking();
        }
      }
    });
  }

  void _batDauLiveTracking() {
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() { _thoiGianGiay++; _calo += 0.15; });
    });
    _sensorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) setState(() { _nhipTim = 120 + Random().nextInt(25); });
    });
  }

  // ĐÃ BỌC LỆNH THOÁT VÀO FUTURE ĐỂ CHỐNG CRASH RENDER
  void _ketThucBaiTap() {
    if (_daKetThuc) return; 
    _daKetThuc = true; 
    
    _holdController.stop(); 
    HapticFeedback.heavyImpact();
    
    // Tạo một Map chứa kết quả bài tập
    Map<String, dynamic> ketQua = {
      "ten": widget.tenBaiTap,
      "gio": "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      "thoiGian": _formatThoiGian(_thoiGianGiay),
      "calo": _calo.toInt(),
      "nhipTim": _nhipTim,
      "icon": widget.iconBaiTap,
    };
    
    Future.microtask(() {
      if (mounted) {
        // Trả kết quả 'ketQua' về cho màn hình ActivityScreen
        Navigator.pop(context, ketQua); 
      }
    });
  }

  String _formatThoiGian(int tongGiay) {
    int phut = tongGiay ~/ 60;
    int giay = tongGiay % 60;
    return '${phut.toString().padLeft(2, '0')}:${giay.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      body: SafeArea(
        child: _dangDemNguoc ? _buildManHinhDemNguoc() : _buildManHinhLive(),
      ),
    );
  }

  Widget _buildManHinhDemNguoc() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Chuẩn bị', style: TextStyle(color: VitaTrackTheme.mauChuPhu.withOpacity(0.5), fontSize: 24)),
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            key: ValueKey(_soDemNguoc), 
            tween: Tween<double>(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Text('$_soDemNguoc', style: const TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 120, fontWeight: FontWeight.bold, height: 1)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManHinhLive() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.iconBaiTap, color: VitaTrackTheme.mauChinh, size: 24),
              const SizedBox(width: 8),
              Text(widget.tenBaiTap, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatThoiGian(_thoiGianGiay),
                style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 80, fontWeight: FontWeight.w200, fontFeatures: [FontFeature.tabularFigures()]),
              ),
              const Text('THỜI GIAN', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14, letterSpacing: 2)),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _taoThongSoLive(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, _calo.toStringAsFixed(1), 'KCAL'),
                  Container(width: 1, height: 50, color: VitaTrackTheme.mauCardNhat),
                  _taoThongSoLive(Icons.favorite, VitaTrackTheme.mauNguyHiem, '$_nhipTim', 'BPM', isHeart: true),
                ],
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: Column(
            children: [
              GestureDetector(
                onTapDown: (_) {
                  if (!_daKetThuc) {
                    HapticFeedback.lightImpact();
                    _holdController.forward(); 
                  }
                },
                onTapUp: (_) { if (!_daKetThuc) _holdController.reverse(); },
                onTapCancel: () { if (!_daKetThuc) _holdController.reverse(); },
                child: SizedBox(
                  width: 100, height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const CircularProgressIndicator(value: 1.0, strokeWidth: 6, color: VitaTrackTheme.mauCard),
                      CircularProgressIndicator(value: _holdController.value, strokeWidth: 8, backgroundColor: Colors.transparent, color: VitaTrackTheme.mauNguyHiem, strokeCap: StrokeCap.round),
                      Container(width: 70, height: 70, decoration: const BoxDecoration(color: VitaTrackTheme.mauNguyHiem, shape: BoxShape.circle), child: const Icon(Icons.stop_rounded, color: VitaTrackTheme.mauNen, size: 36)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: _holdController.value > 0 ? 0.0 : 1.0, 
                duration: const Duration(milliseconds: 200),
                child: const Text('Nhấn giữ để kết thúc', style: TextStyle(color: VitaTrackTheme.mauChuPhu)),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _taoThongSoLive(IconData icon, Color color, String value, String unit, {bool isHeart = false}) {
    return Column(
      children: [
        isHeart 
        ? TweenAnimationBuilder<double>(
            key: ValueKey(value), 
            tween: Tween<double>(begin: 1.2, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, scale, child) => Transform.scale(scale: scale, child: Icon(icon, color: color, size: 28)),
          )
        : Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 36, fontWeight: FontWeight.bold)),
        Text(unit, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12, letterSpacing: 1)),
      ],
    );
  }
}