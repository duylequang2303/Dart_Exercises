import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'chat_tab.dart';
import 'analysis_tab.dart';
import 'plan_tab.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  int _tabHienTai = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTabBar(),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _hienThiNoiDungTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hienThiNoiDungTab() {
    switch (_tabHienTai) {
      case 0: return  ChatTab();
      case 1: return const AnalysisTab();
      case 2: return const PlanTab();
      default: return ChatTab();
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: VitaTrackTheme.mauChinh, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.smart_toy, color: VitaTrackTheme.mauNen, size: 32),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('AI Coach', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Đang hoạt động', style: TextStyle(color: VitaTrackTheme.mauThanhCong.withOpacity(0.8), fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Expanded(child: _taoTabButton(0, 'Trò chuyện')),
          Expanded(child: _taoTabButton(1, 'Phân tích')),
          Expanded(child: _taoTabButton(2, 'Kế hoạch')),
        ],
      ),
    );
  }

  Widget _taoTabButton(int index, String tieuDe) {
    bool dangChon = _tabHienTai == index;
    return InkWell(
      onTap: () => setState(() => _tabHienTai = index),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: dangChon ? VitaTrackTheme.mauChinh : Colors.transparent, borderRadius: BorderRadius.circular(30)),
        child: Center(child: Text(tieuDe, style: TextStyle(color: dangChon ? VitaTrackTheme.mauNen : VitaTrackTheme.mauChuPhu, fontWeight: dangChon ? FontWeight.bold : FontWeight.normal))),
      ),
    );
  }
}