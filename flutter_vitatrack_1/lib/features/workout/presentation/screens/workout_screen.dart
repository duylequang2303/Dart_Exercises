import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/screens/live_workout_screen.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/providers/workout_timer_provider.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  int _tabIndex = 0;
  bool _pressed = false;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _aiWorkoutResult;
  List<ExerciseEntity> _aiExercises = [];

  static const List<Map<String, dynamic>> _suggested = [
    {"name": "Morning Run", "duration": "32 min", "cal": 320, "icon": Icons.directions_run, "color": Color(0xFF1B2E28)},
    {"name": "Evening Ride", "duration": "45 min", "cal": 280, "icon": Icons.pedal_bike, "color": Color(0xFF1A2136)},
    {"name": "Pool Laps", "duration": "30 min", "cal": 400, "icon": Icons.pool, "color": Color(0xFF2E241B)},
  ];

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _aiWorkoutResult = null;
      _aiExercises = [];
    });

    try {
      final result = await ref.read(workoutAiServiceProvider).parseWorkoutPlan(query);
      if (!mounted) return;

      final exercisesData = result['exercises'] as List<dynamic>?;
      final List<ExerciseEntity> list = exercisesData?.map((e) {
        final map = e as Map<String, dynamic>;
        return ExerciseEntity(
          id: '${DateTime.now().millisecondsSinceEpoch}_${map['name']}',
          name: map['name'] ?? '',
          sets: map['sets'] ?? 3,
          reps: map['reps'] ?? 10,
          duration: Duration(seconds: map['durationSeconds'] ?? 0),
          restSeconds: map['restSeconds'] ?? 45,
        );
      }).toList() ?? [];

      setState(() {
        _aiWorkoutResult = result;
        _aiExercises = list;
        _isSearching = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi phân tích bài tập bằng AI'), backgroundColor: VitaTrackTheme.mauNguyHiem),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
                      child: _tabIndex == 0 ? _buildOverview(key: const ValueKey(0)) : _buildExercises(key: const ValueKey(1)),
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
                  boxShadow: _pressed ? [] : [BoxShadow(color: VitaTrackTheme.mauChinh.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
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
              _buildStartChoice(sheetContext, Icons.fitness_center, 'Tập Gym / Sức mạnh', VitaTrackTheme.mauNguyHiem),
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

  Widget _buildOverview({Key? key}) {
    // Lấy dữ liệu thật từ workoutLocalDataSource qua provider
    final allWorkouts = ref.watch(workoutLocalDataSourceProvider).getAllWorkouts();
    // WorkoutEntity không có startTime - lưu trong RAM, tất cả đều là session hiện tại
    final todayWorkouts = allWorkouts; // Tất cả workouts trong session đều là hôm nay

    final totalSeconds = todayWorkouts.fold<int>(0, (sum, w) => sum + w.duration.inSeconds);
    final totalMin = totalSeconds ~/ 60;

    final hasData = todayWorkouts.isNotEmpty;

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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: hasData ? (totalMin / 60.0).clamp(0.0, 1.0) : 0.0,
                      backgroundColor: VitaTrackTheme.mauCardNhat,
                      color: VitaTrackTheme.mauChinh,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasData ? '$totalMin' : '--',
                          style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        const Text('phút', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _miniStat(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, hasData ? '${todayWorkouts.length} buổi' : '--', 'hôm nay'),
                  _miniStat(Icons.timer, VitaTrackTheme.mauCanhBao, hasData ? '$totalMin' : '--', 'phút'),
                  _miniStat(Icons.check_circle_outline, VitaTrackTheme.mauThanhCong, hasData ? 'Hoàn thành' : 'Chưa tập', ''),
                ],
              ),
              if (!hasData)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Hôm nay chưa có buổi tập nào\nBấm "Bắt đầu" để bắt đầu! 💪',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13, height: 1.5),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExercises({Key? key}) {
    final allWorkouts = ref.watch(workoutLocalDataSourceProvider).getAllWorkouts();

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== THANH TÌM KIẾM BÀI TẬP BẰNG AI =====
        const Text('Tìm kiếm giáo án bằng AI', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: VitaTrackTheme.mauCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: VitaTrackTheme.mauCardNhat),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: VitaTrackTheme.mauChu),
                  decoration: const InputDecoration(
                    hintText: 'Ví dụ: Hít đất 3 hiệp, plank 1 phút...',
                    hintStyle: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: VitaTrackTheme.mauChuPhu),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _performSearch,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: VitaTrackTheme.mauChinh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('AI SEARCH', style: TextStyle(color: VitaTrackTheme.mauNen, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // TRẠNG THÁI LOADING KHI TÌM KIẾM
        if (_isSearching)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const CircularProgressIndicator(color: VitaTrackTheme.mauChinh),
                  const SizedBox(height: 12),
                  const Text('AI đang thiết lập giáo án riêng cho bạn...', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
                ],
              ),
            ),
          ),

        // HIỂN THỊ KẾT QUẢ GIÁO ÁN ĐỀ XUẤT CỦA AI
        if (!_isSearching && _aiWorkoutResult != null)
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: VitaTrackTheme.mauCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: VitaTrackTheme.mauThanhCong.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _aiWorkoutResult!['standardName'] ?? 'Giáo án bài tập',
                        style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (_aiWorkoutResult!['type'] == 'strength' ? VitaTrackTheme.mauNguyHiem : VitaTrackTheme.mauChinh).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _aiWorkoutResult!['type'] == 'strength' ? 'Gym / Tạ' : 'Cardio',
                        style: TextStyle(
                          color: _aiWorkoutResult!['type'] == 'strength' ? VitaTrackTheme.mauNguyHiem : VitaTrackTheme.mauChinh,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: VitaTrackTheme.mauCardNhat),
                const SizedBox(height: 8),
                ..._aiExercises.map((ex) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ex.name,
                          style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        ex.duration.inSeconds > 0 
                            ? 'Giữ ${ex.duration.inSeconds}s x ${ex.sets} hiệp (Nghỉ ${ex.restSeconds}s)'
                            : '${ex.reps} cái x ${ex.sets} hiệp (Nghỉ ${ex.restSeconds}s)',
                        style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VitaTrackTheme.mauThanhCong,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final result = await Navigator.push<bool>(context, PageRouteBuilder(
                        pageBuilder: (_, _, _) => LiveWorkoutScreen(
                          tenBaiTap: _aiWorkoutResult!['standardName'] ?? 'Bài tập AI',
                          iconBaiTap: _aiWorkoutResult!['type'] == 'strength' ? Icons.fitness_center : Icons.directions_run,
                          type: _aiWorkoutResult!['type'] ?? 'strength',
                          exercises: _aiExercises,
                        ),
                        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
                      ));
                      if (!mounted) return;
                      if (result == true) {
                        setState(() {
                          _searchController.clear();
                          _aiWorkoutResult = null;
                          _aiExercises = [];
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu bài tập vào lịch sử!'), backgroundColor: VitaTrackTheme.mauThanhCong, behavior: SnackBarBehavior.floating));
                      }
                    },
                    icon: const Icon(Icons.play_arrow, color: VitaTrackTheme.mauNen),
                    label: const Text('BẮT ĐẦU TẬP GIÁO ÁN NÀY 🚀', style: TextStyle(color: VitaTrackTheme.mauNen, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bài tập gợi ý', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: _showAllExercises,
              child: const Text('Xem tất cả >', style: TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _suggested.length,
            itemBuilder: (context, index) {
              final item = _suggested[index];
              return _buildSuggestedCard(item);
            },
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Hoạt động gần đây', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: _showStartMenu,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: VitaTrackTheme.mauChinh.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: VitaTrackTheme.mauChinh.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: VitaTrackTheme.mauChinh, size: 16),
                    SizedBox(width: 4),
                    Text('Thêm bài tập', style: TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (allWorkouts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.fitness_center, color: VitaTrackTheme.mauChuPhu.withValues(alpha: 0.3), size: 48),
                  const SizedBox(height: 12),
                  const Text('Chưa có buổi tập nào được lưu', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14)),
                ],
              ),
            ),
          )
        else
          ...allWorkouts.reversed.take(5).map<Widget>((w) => _buildWorkoutHistoryCard(w)),
      ],
    );
  }

  void _showAllExercises() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        final allTypes = [
          {'icon': Icons.directions_run, 'name': 'Chạy bộ ngoài trời', 'color': VitaTrackTheme.mauChinh},
          {'icon': Icons.directions_walk, 'name': 'Đi bộ', 'color': VitaTrackTheme.mauThanhCong},
          {'icon': Icons.pedal_bike, 'name': 'Đạp xe', 'color': VitaTrackTheme.mauThanhCong},
          {'icon': Icons.fitness_center, 'name': 'Tập Gym / Sức mạnh', 'color': VitaTrackTheme.mauNguyHiem},
          {'icon': Icons.pool, 'name': 'Bơi lội', 'color': VitaTrackTheme.mauChinh},
          {'icon': Icons.self_improvement, 'name': 'Yoga', 'color': VitaTrackTheme.mauPhu},
          {'icon': Icons.sports_basketball, 'name': 'Bóng rổ', 'color': VitaTrackTheme.mauCanhBao},
          {'icon': Icons.sports_soccer, 'name': 'Đá bóng', 'color': VitaTrackTheme.mauThanhCong},
        ];
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: VitaTrackTheme.mauCardNhat, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Tất cả bài tập', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...allTypes.map((t) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: (t['color'] as Color).withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(t['icon'] as IconData, color: t['color'] as Color)),
                title: Text(t['name'] as String, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.play_arrow_rounded, color: VitaTrackTheme.mauChinh),
                onTap: () async {
                  HapticFeedback.lightImpact();
                  Navigator.pop(sheetCtx);
                  final result = await Navigator.push<bool>(context, PageRouteBuilder(
                    pageBuilder: (_, _, _) => LiveWorkoutScreen(tenBaiTap: t['name'] as String, iconBaiTap: t['icon'] as IconData),
                    transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
                  ));
                  if (!mounted) return;
                  if (result == true) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã lưu bài tập ${t['name']}!'), backgroundColor: VitaTrackTheme.mauThanhCong, behavior: SnackBarBehavior.floating));
                },
              )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForWorkout(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('chạy') || nameLower.contains('run')) return Icons.directions_run;
    if (nameLower.contains('đạp') || nameLower.contains('bike') || nameLower.contains('ride')) return Icons.pedal_bike;
    if (nameLower.contains('bơi') || nameLower.contains('swim') || nameLower.contains('pool')) return Icons.pool;
    if (nameLower.contains('yoga') || nameLower.contains('spa') || nameLower.contains('improvement')) return Icons.self_improvement;
    if (nameLower.contains('bóng rổ') || nameLower.contains('basketball')) return Icons.sports_basketball;
    if (nameLower.contains('đá bóng') || nameLower.contains('soccer') || nameLower.contains('football')) return Icons.sports_soccer;
    if (nameLower.contains('gym') || nameLower.contains('sức mạnh') || nameLower.contains('lực') || nameLower.contains('fitness') || nameLower.contains('kháng')) return Icons.fitness_center;
    if (nameLower.contains('đi bộ') || nameLower.contains('walk')) return Icons.directions_walk;
    return Icons.directions_run;
  }

  Widget _buildWorkoutHistoryCard(WorkoutEntity w) {
    final IconData icon = _getIconForWorkout(w.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14), 
            decoration: const BoxDecoration(color: Color(0xFF1B2E28), shape: BoxShape.circle), 
            child: Icon(icon, color: VitaTrackTheme.mauThanhCong, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    Text(w.name, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${w.duration.inMinutes} phút ${w.duration.inSeconds % 60}s', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                  ]
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: VitaTrackTheme.mauNguyHiem, size: 14),
                        const SizedBox(width: 4),
                        Text('${w.calories.toStringAsFixed(1)} kcal', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                        if (w.steps > 0) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.do_not_step, color: VitaTrackTheme.mauThanhCong, size: 14),
                          const SizedBox(width: 4),
                          Text('${w.steps} bước', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                        ]
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: VitaTrackTheme.mauThanhCong, size: 14),
                        SizedBox(width: 4),
                        Text('Hoàn thành', style: TextStyle(color: VitaTrackTheme.mauThanhCong, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final result = await Navigator.push<bool>(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) => LiveWorkoutScreen(tenBaiTap: item['name'], iconBaiTap: item['icon']),
            transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
          ),
        );
        if (!mounted) return;
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã lưu bài tập ${item['name']}!'), backgroundColor: VitaTrackTheme.mauThanhCong, behavior: SnackBarBehavior.floating));
        }
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: VitaTrackTheme.mauCard,
          borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon),
          border: Border.all(color: VitaTrackTheme.mauCardNhat),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: item['color'], borderRadius: BorderRadius.circular(12)),
              child: Icon(item['icon'], color: VitaTrackTheme.mauChinh, size: 24),
            ),
            const Spacer(),
            Text(item['name'], style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.timer_outlined, color: VitaTrackTheme.mauChuPhu, size: 14), const SizedBox(width: 4), Text(item['duration'], style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12))]),
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.local_fire_department_outlined, color: VitaTrackTheme.mauChuPhu, size: 14), const SizedBox(width: 4), Text('${item['cal']} kcal', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12))]),
          ],
        ),
      ),
    );
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
}
