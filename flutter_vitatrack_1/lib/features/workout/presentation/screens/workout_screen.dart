import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/screens/live_workout_screen.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/screens/strength_log_screen.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/providers/workout_timer_provider.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  final Set<String> _deletedWorkoutIds = {};
  bool _pressed = false;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _aiWorkoutResult;
  List<ExerciseEntity> _aiExercises = [];



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
      final result = await ref.read(parseWorkoutPlanUseCaseProvider).call(query);
      if (!mounted) return;
      if (!_isSearching) return; // Người dùng đã ấn hủy

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
        final msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: VitaTrackTheme.mauNguyHiem,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildTodaySummaryCard(),
                    const SizedBox(height: 24),
                    _buildExercisesSection(),
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
    // Lấy lịch sử để gợi ý các bài tập gần nhất
    final historyAsync = ref.read(workoutHistoryProvider);
    final allWorkouts = historyAsync.value ?? [];
    
    // Lọc ra các bài tập unique gần nhất
    final uniqueRecentWorkouts = <String, WorkoutEntity>{};
    for (final w in allWorkouts.reversed) {
      if (!uniqueRecentWorkouts.containsKey(w.name)) {
        uniqueRecentWorkouts[w.name] = w;
      }
      if (uniqueRecentWorkouts.length >= 3) break; // Chỉ lấy tối đa 3 bài gần nhất
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
              
              if (uniqueRecentWorkouts.isNotEmpty) ...[
                const Text('Tập lại bài gần đây', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...uniqueRecentWorkouts.values.map((w) {
                  return _buildStartChoice(sheetContext, _getIconForWorkout(w.name), w.name, VitaTrackTheme.mauNguyHiem, workoutToRepeat: w);
                }),
                const Divider(color: VitaTrackTheme.mauCardNhat, height: 24),
                const Text('Bài tập tiêu chuẩn', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
              ],

              _buildStartChoice(sheetContext, Icons.directions_run, 'Chạy bộ ngoài trời', VitaTrackTheme.mauChinh),
              _buildStartChoice(sheetContext, Icons.pedal_bike, 'Đạp xe ngoài trời', VitaTrackTheme.mauThanhCong),
              _buildStartChoice(sheetContext, Icons.directions_walk, 'Đi bộ', VitaTrackTheme.mauChinh),
              _buildStartChoice(sheetContext, Icons.pool, 'Bơi lội', VitaTrackTheme.mauChinh),
              _buildStartChoice(sheetContext, Icons.pedal_bike, 'Đạp xe trong nhà', VitaTrackTheme.mauThanhCong),
              const Divider(color: VitaTrackTheme.mauCardNhat, height: 24),
              _buildStartChoice(sheetContext, Icons.fitness_center, 'Bài tập sức mạnh', VitaTrackTheme.mauNguyHiem, forceType: 'strength'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStartChoice(BuildContext sheetContext, IconData icon, String title, Color color, {WorkoutEntity? workoutToRepeat, String? forceType}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
      subtitle: workoutToRepeat != null && workoutToRepeat.exercises.isNotEmpty 
          ? Text('${workoutToRepeat.exercises.length} động tác', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right, color: VitaTrackTheme.mauChuPhu),
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.pop(sheetContext);
        
        final String type = forceType ?? workoutToRepeat?.type ?? 'cardio';
        final bool isStrength = type == 'strength' || title.toLowerCase().contains('sức mạnh');

        final result = await Navigator.push<bool>(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) => isStrength
                ? StrengthLogScreen(
                    workoutName: title,
                    exercises: workoutToRepeat?.exercises ?? [],
                  )
                : LiveWorkoutScreen(
                    tenBaiTap: title, 
                    iconBaiTap: icon,
                    type: type,
                    exercises: workoutToRepeat?.exercises ?? [],
                  ),
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

  Widget _buildTodaySummaryCard() {
    // Lấy dữ liệu thật từ provider
    final historyAsync = ref.watch(workoutHistoryProvider);
    final List<WorkoutEntity> allWorkouts = historyAsync.value ?? [];
    final now = DateTime.now();
    final todayWorkouts = allWorkouts.where((w) {
      return w.date.year == now.year &&
             w.date.month == now.month &&
             w.date.day == now.day;
    }).toList();

    final totalSeconds = todayWorkouts.fold<int>(0, (sum, w) => sum + w.duration.inSeconds);
    final totalMin = totalSeconds ~/ 60;
    final totalCalories = todayWorkouts.fold<double>(0.0, (sum, w) => sum + w.calories).toInt();
    final sessionCount = todayWorkouts.length;
    final avgMin = sessionCount > 0 ? (totalMin / sessionCount).round() : 0;

    final hasData = todayWorkouts.isNotEmpty;
    const goalMin = 45;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(VitaTrackTheme.boGocLon)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniStat(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, hasData ? '$totalCalories' : '--', 'kcal đốt'),
              _miniStat(Icons.fitness_center, VitaTrackTheme.mauPhu, hasData ? '$sessionCount' : '--', 'bài tập'),
              _miniStat(Icons.timer_outlined, VitaTrackTheme.mauCanhBao, hasData ? '~$avgMin' : '--', 'phút/bài'),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: hasData ? (totalMin / goalMin).clamp(0.0, 1.0) : 0.0,
              backgroundColor: VitaTrackTheme.mauCardNhat,
              color: VitaTrackTheme.mauChinh,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tiến độ hôm nay', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
              Text('$totalMin / $goalMin phút', style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VitaTrackTheme.mauChinh,
                  foregroundColor: VitaTrackTheme.mauNen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _showStartMenu,
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text('Bắt đầu ngay', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExercisesSection() {
    // Lấy lịch sử thực tế từ DataSource
    final historyAsync = ref.watch(workoutHistoryProvider);
    final List<WorkoutEntity> allWorkouts = historyAsync.value ?? [];
    final visibleWorkouts = allWorkouts.where((w) => !_deletedWorkoutIds.contains(w.id)).toList();

    return Column(
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
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                      });
                    },
                    child: const Text('Hủy', style: TextStyle(color: VitaTrackTheme.mauNguyHiem, fontWeight: FontWeight.bold)),
                  ),
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: VitaTrackTheme.mauChinh),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          final plan = WorkoutEntity(
                            id: '${DateTime.now().millisecondsSinceEpoch}',
                            name: _aiWorkoutResult!['standardName'] ?? 'Bài tập AI',
                            duration: Duration.zero,
                            exercises: _aiExercises,
                            calories: 0,
                            steps: 0,
                            iconCodePoint: (_aiWorkoutResult!['type'] == 'strength' ? Icons.fitness_center : Icons.directions_run).codePoint,
                            type: _aiWorkoutResult!['type'] ?? 'strength',
                          );
                          await ref.read(workoutRepositoryProvider).saveWorkoutPlan(plan);
                          ref.invalidate(workoutPlansProvider);
                          setState(() {
                            _searchController.clear();
                            _aiWorkoutResult = null;
                            _aiExercises = [];
                          });
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu giáo án vào danh sách của bạn!'), backgroundColor: VitaTrackTheme.mauThanhCong, behavior: SnackBarBehavior.floating));
                        },
                        child: const Text('LƯU', style: TextStyle(color: VitaTrackTheme.mauChinh, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VitaTrackTheme.mauThanhCong,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          final isStrength = _aiWorkoutResult!['type'] == 'strength';
                          final result = await Navigator.push<bool>(context, PageRouteBuilder(
                            pageBuilder: (_, _, _) => isStrength
                                ? StrengthLogScreen(
                                    workoutName: _aiWorkoutResult!['standardName'] ?? 'Bài tập AI',
                                    exercises: _aiExercises,
                                  )
                                : LiveWorkoutScreen(
                                    tenBaiTap: _aiWorkoutResult!['standardName'] ?? 'Bài tập AI',
                                    iconBaiTap: Icons.directions_run,
                                    type: _aiWorkoutResult!['type'] ?? 'cardio',
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
                        label: const Text('BẮT ĐẦU TẬP 🚀', style: TextStyle(color: VitaTrackTheme.mauNen, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Giáo án của bạn', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        Consumer(
          builder: (context, ref, child) {
            final plansAsync = ref.watch(workoutPlansProvider);
            final plans = plansAsync.value ?? [];
            if (plans.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(16)),
                child: const Text(
                  'Bạn chưa lưu giáo án nào. Hãy dùng AI để tạo giáo án nhé!',
                  style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return _buildPlanCard(plan);
                },
              ),
            );
          },
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
        if (visibleWorkouts.isEmpty)
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
          ...visibleWorkouts.reversed.take(5).map<Widget>((w) => _buildWorkoutHistoryCard(w)),
      ],
    );
  }

  // Đã xóa hàm _showAllExercises theo yêu cầu

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

  Widget _buildPlanCard(WorkoutEntity plan) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(24)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            HapticFeedback.lightImpact();
            final isStrength = plan.type == 'strength';
            final result = await Navigator.push<bool>(context, PageRouteBuilder(
              pageBuilder: (_, _, _) => isStrength
                  ? StrengthLogScreen(
                      workoutName: plan.name,
                      exercises: plan.exercises,
                    )
                  : LiveWorkoutScreen(
                      tenBaiTap: plan.name,
                      iconBaiTap: Icons.fitness_center,
                      type: plan.type,
                      exercises: plan.exercises,
                    ),
              transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
            ));
            if (!mounted) return;
            if (result == true) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu bài tập vào lịch sử!'), backgroundColor: VitaTrackTheme.mauThanhCong, behavior: SnackBarBehavior.floating));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: (plan.type == 'strength' ? VitaTrackTheme.mauNguyHiem : VitaTrackTheme.mauChinh).withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(plan.type == 'strength' ? Icons.fitness_center : Icons.directions_run, color: plan.type == 'strength' ? VitaTrackTheme.mauNguyHiem : VitaTrackTheme.mauChinh),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${plan.exercises.length} động tác', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutHistoryCard(WorkoutEntity w) {
    final IconData icon = _getIconForWorkout(w.name);

    return Dismissible(
      key: Key(w.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(color: VitaTrackTheme.mauNguyHiem, borderRadius: BorderRadius.circular(24)),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        setState(() {
          _deletedWorkoutIds.add(w.id);
        });
        await ref.read(workoutRepositoryProvider).deleteWorkout(w.id);
        ref.invalidate(workoutHistoryProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa bài tập!'), behavior: SnackBarBehavior.floating));
        }
      },
      child: Container(
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
      ),
    );
  }





  Widget _miniStat(IconData icon, Color color, String val, String unit) {
    return Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 6), Text(val, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 16)), Text(unit, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 11))]);
  }


}
