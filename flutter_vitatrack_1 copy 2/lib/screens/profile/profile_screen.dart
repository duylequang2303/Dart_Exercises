import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'profile_tab.dart';
import 'achievement_tab.dart';
import 'settings_tab.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _tabHienTai = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildQuickStats(),
            const SizedBox(height: 24),
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
      case 0: return  ProfileTab();
      case 1: return const AchievementTab();
      case 2: return const SettingsTab();
      default: return  ProfileTab();
    }
  }

  Widget _buildHeader() {
    final user = ref.watch(nguoiDungHienTaiProvider);
    final displayName = user?.tenHienThi ?? 'Người dùng';
    final email = user?.email ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: VitaTrackTheme.mauChinh,
            child: Text(initial, style: const TextStyle(color: VitaTrackTheme.mauNen, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(email, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.verified, color: VitaTrackTheme.mauChinh, size: 28),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem('127', 'Ngày hoạt động'),
        _statItem('1.2M', 'Tổng bước'),
        _statItem('45.2K', 'Calories đốt'),
      ],
    );
  }

  Widget _statItem(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Expanded(child: _tabBtn(0, 'Hồ sơ')),
          Expanded(child: _tabBtn(1, 'Thành tích')),
          Expanded(child: _tabBtn(2, 'Cài đặt')),
        ],
      ),
    );
  }

  Widget _tabBtn(int index, String title) {
    bool active = _tabHienTai == index;
    return InkWell(
      onTap: () => setState(() => _tabHienTai = index),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: active ? VitaTrackTheme.mauChinh : Colors.transparent, borderRadius: BorderRadius.circular(30)),
        child: Center(child: Text(title, style: TextStyle(color: active ? VitaTrackTheme.mauNen : VitaTrackTheme.mauChuPhu, fontWeight: active ? FontWeight.bold : FontWeight.normal))),
      ),
    );
  }
}