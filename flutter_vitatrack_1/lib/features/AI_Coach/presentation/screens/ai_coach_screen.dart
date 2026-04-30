import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_tab.dart';
import 'analysis_tab.dart';
import 'plan_tab.dart';
import '../providers/chat_provider.dart';
import '../widgets/app_colors.dart';

/// Màn hình chính AI Coach - chứa header + TabBar 3 tab
class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildTabBar(),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  ChatTab(),
                  AnalysisTab(),
                  PlanTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.black, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Coach',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                _OnlineStatusIndicator(),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(child: Text('Trò chuyện',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          Tab(child: Text('Phân tích',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          Tab(child: Text('Kế hoạch',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
        indicator: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(26),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.black,
        unselectedLabelColor: AppColors.textSecondary,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _OptionsBottomSheet(
        onClearChat: () {
          Navigator.pop(context);
          ref.read(chatProvider.notifier).clearChat();
        },
      ),
    );
  }
}

class _OnlineStatusIndicator extends StatefulWidget {
  const _OnlineStatusIndicator();

  @override
  State<_OnlineStatusIndicator> createState() =>
      _OnlineStatusIndicatorState();
}

class _OnlineStatusIndicatorState extends State<_OnlineStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.positiveColor.withValues(alpha: _animation.value),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text('Đang hoạt động',
            style: TextStyle(
                color: AppColors.positiveColor,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _OptionsBottomSheet extends StatelessWidget {
  final VoidCallback onClearChat;
  const _OptionsBottomSheet({required this.onClearChat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded,
                color: Colors.red),
            title: const Text('Xóa lịch sử trò chuyện',
                style: TextStyle(color: Colors.red, fontSize: 15)),
            onTap: onClearChat,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ],
      ),
    );
  }
}