import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/screens/live_workout_screen.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/providers/exercise_search_provider.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/activity_entity.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  int _tabIndex = 0;
  bool _pressed = false;

  // Dữ liệu mẫu cho hoạt động gần đây (giữ nguyên)
  static const List<Map<String, dynamic>> _recent = [
    {"name": "Run", "time": "07:30", "duration": "32 min", "cal": 320, "hr": 145, "icon": Icons.directions_run},
    {"name": "Walk", "time": "12:15", "duration": "15 min", "cal": 85, "hr": 95, "icon": Icons.directions_walk},
  ];

  final List<Map<String, dynamic>> _muscleGroups = [
    {"name": "Tất cả", "id": null},
    {"name": "Biceps", "id": 1},
    {"name": "Deltoids", "id": 2},
    {"name": "Abs", "id": 3},
    {"name": "Chest", "id": 4},
    {"name": "Triceps", "id": 5},
    {"name": "Back", "id": 6},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildTabBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _tabIndex == 0
                          ? _buildOverview(key: const ValueKey(0))
                          : _buildExercises(key: const ValueKey(1)),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- Header và BottomSheet (giữ nguyên) -----
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hoạt động', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14)),
              SizedBox(height: 4),
              Text('Hôm nay', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) async {
              setState(() => _pressed = false);
              HapticFeedback.mediumImpact();
              _showStartMenu();
            },
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 0.90 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: VitaTrackTheme.mauChinh,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _pressed
                      ? []
                      : [BoxShadow(color: VitaTrackTheme.mauChinh.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.play_arrow_rounded, color: VitaTrackTheme.mauNen, size: 20),
                    SizedBox(width: 6),
                    Text('Bắt đầu', style: TextStyle(color: VitaTrackTheme.mauNen, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStartMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: VitaTrackTheme.mauCardNhat, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text('Chọn bài tập', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildStartChoice(sheetContext, Icons.directions_run, 'Chạy bộ ngoài trời', VitaTrackTheme.mauChinh),
              _buildStartChoice(sheetContext, Icons.pedal_bike, 'Đạp xe', VitaTrackTheme.mauThanhCong),
              _buildStartChoice(sheetContext, Icons.fitness_center, 'Tập kháng lực', VitaTrackTheme.mauNguyHiem),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStartChoice(BuildContext sheetContext, IconData icon, String title, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right, color: VitaTrackTheme.mauChuPhu),
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.pop(sheetContext);
        final result = await Navigator.push<bool>(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) => LiveWorkoutScreen(tenBaiTap: title, iconBaiTap: icon),
            transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
          ),
        );
        if (!mounted) return;
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã lưu bài tập $title!'), backgroundColor: VitaTrackTheme.mauThanhCong, behavior: SnackBarBehavior.floating));
        }
      },
    );
  }

  // ----- Tab Tổng quan (giữ nguyên) -----
  Widget _buildOverview({Key? key}) {
    return Column(
      key: key,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
          child: Column(
            children: [
              SizedBox(
                width: 180, height: 180,
                child: CircularProgressIndicator(value: 0.5, backgroundColor: VitaTrackTheme.mauCardNhat, color: VitaTrackTheme.mauChinh, strokeWidth: 14, strokeCap: StrokeCap.round),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _miniStat(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, '320', 'kcal'),
                  _miniStat(Icons.straighten, VitaTrackTheme.mauThanhCong, '5.8', 'km'),
                  _miniStat(Icons.timer, VitaTrackTheme.mauCanhBao, '42', 'phút'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildHeartRateCard(),
      ],
    );
  }

  Widget _buildHeartRateCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Nhịp tim', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
              SizedBox(height: 8),
              Text('--', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 40, fontWeight: FontWeight.bold)),
              Text('Bình thường', style: TextStyle(color: VitaTrackTheme.mauThanhCong, fontSize: 13)),
            ],
          ),
          const Icon(Icons.favorite, color: VitaTrackTheme.mauNguyHiem, size: 56),
        ],
      ),
    );
  }

  // ----- Tab Bài tập (ĐÃ THÊM TÌM KIẾM VÀ LỌC) -----
  Widget _buildExercises({Key? key}) {
    final searchState = ref.watch(exerciseSearchProvider);
    final searchNotifier = ref.read(exerciseSearchProvider.notifier);

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Ô tìm kiếm
        TextField(
          controller: TextEditingController.fromValue(
            TextEditingValue(
              text: searchState.currentQuery,
              selection: TextSelection.collapsed(offset: searchState.currentQuery.length),
            ),
          ),
          onChanged: (value) {
            searchNotifier.updateQuery(value);
          },
          decoration: InputDecoration(
            hintText: 'Tìm kiếm bài tập...',
            prefixIcon: const Icon(Icons.search, color: VitaTrackTheme.mauChuPhu),
            filled: true,
            fillColor: VitaTrackTheme.mauCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
          style: const TextStyle(color: VitaTrackTheme.mauChu),
        ),
        const SizedBox(height: 20),
        // 2. Các nhóm cơ dạng Chip
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _muscleGroups.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final group = _muscleGroups[index];
              final isSelected = searchState.selectedMuscleId == group['id'];
              return FilterChip(
                label: Text(group['name']),
                selected: isSelected,
                onSelected: (_) {
                  searchNotifier.updateMuscleFilter(group['id']);
                },
                backgroundColor: VitaTrackTheme.mauCard,
                selectedColor: VitaTrackTheme.mauChinh.withValues(alpha: 0.2),
                checkmarkColor: VitaTrackTheme.mauChinh,
                labelStyle: TextStyle(
                  color: isSelected ? VitaTrackTheme.mauChinh : VitaTrackTheme.mauChuPhu,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        // 3. Danh sách bài tập (kết quả tìm kiếm/lọc)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              searchState.currentQuery.isEmpty && searchState.selectedMuscleId == null
                  ? "Bài tập gợi ý"
                  : "Kết quả (${searchState.exercises.length})",
              style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (searchState.currentQuery.isNotEmpty || searchState.selectedMuscleId != null)
              TextButton(
                onPressed: () {
                  searchNotifier.clearFilters();
                },
                child: const Text('Xóa bộ lọc', style: TextStyle(color: VitaTrackTheme.mauChinh)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (searchState.isLoading)
          const Center(child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(),
          ))
        else if (searchState.errorMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Text(searchState.errorMessage!, style: const TextStyle(color: VitaTrackTheme.mauChuPhu)),
          )
        else if (searchState.exercises.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: const Text('Không tìm thấy bài tập nào', style: TextStyle(color: VitaTrackTheme.mauChuPhu)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchState.exercises.length,
            itemBuilder: (context, index) {
              final ex = searchState.exercises[index];
              return _buildExerciseCard(ex);
            },
          ),
        const SizedBox(height: 32),
        // 4. Hoạt động gần đây (giữ nguyên)
        const Text('Hoạt động gần đây', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._recent.map<Widget>((item) => _buildRecentActivityCard(item)),
      ],
    );
  }

  // Card hiển thị một bài tập trong danh sách kết quả
  Widget _buildExerciseCard(ActivityEntity item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VitaTrackTheme.mauCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: VitaTrackTheme.mauChinh.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.fitness_center, color: VitaTrackTheme.mauChinh, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _smallInfo(Icons.timer_outlined, "${item.durationMinutes} min"),
                    const SizedBox(width: 12),
                    _smallInfo(Icons.local_fire_department_outlined, "${item.caloriesBurned} kcal"),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: VitaTrackTheme.mauChinh.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Workout",
              style: TextStyle(fontSize: 12, color: VitaTrackTheme.mauChinh, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Các widget nhỏ dùng chung
  Widget _smallInfo(IconData icon, String text) {
    return Row(children: [Icon(icon, color: VitaTrackTheme.mauChuPhu, size: 14), const SizedBox(width: 4), Text(text, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12))]);
  }

  Widget _miniStat(IconData icon, Color color, String val, String unit) {
    return Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 6), Text(val, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 16)), Text(unit, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 11))]);
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(30)),
      child: Row(children: [Expanded(child: _tabBtn(0, 'Tổng quan')), Expanded(child: _tabBtn(1, 'Bài tập'))]),
    );
  }

  Widget _tabBtn(int index, String title) {
    bool active = _tabIndex == index;
    return InkWell(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _tabIndex = index); },
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(duration: const Duration(milliseconds: 250), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: active ? VitaTrackTheme.mauChinh : Colors.transparent, borderRadius: BorderRadius.circular(30)), child: Center(child: Text(title, style: TextStyle(color: active ? VitaTrackTheme.mauNen : VitaTrackTheme.mauChuPhu, fontWeight: active ? FontWeight.bold : FontWeight.w600)))),
    );
  }

  // Card hiển thị hoạt động gần đây (giữ nguyên)
  Widget _buildRecentActivityCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF1B2E28), shape: BoxShape.circle), child: Icon(item['icon'], color: VitaTrackTheme.mauThanhCong, size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(item['name'], style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 16)), Text(item['time'], style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12))]),
                const SizedBox(height: 8),
                Row(children: [ _smallInfo(Icons.timer_outlined, item['duration']), const SizedBox(width: 12), _smallInfo(Icons.local_fire_department_outlined, '${item['cal']} kcal'), const SizedBox(width: 12), _smallInfo(Icons.favorite_outline, '${item['hr']}') ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}