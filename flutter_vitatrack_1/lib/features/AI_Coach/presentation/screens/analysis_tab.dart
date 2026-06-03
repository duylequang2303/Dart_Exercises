import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analysis_plan_provider.dart'; // ← healthAnalysisProvider
import '../../domain/entities/user_health_context.dart'; // ← UserHealthContext
import '../widgets/app_colors.dart';

class AnalysisTab extends ConsumerWidget {
  const AnalysisTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(healthAnalysisProvider);
    final healthContext = ref.watch(userHealthContextProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(healthAnalysisProvider.notifier).refresh(),
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      child: analysisAsync.when(
        loading: () => const _LoadingView(),
        error: (e, s) => _ErrorView(
          onRetry: () =>
              ref.read(healthAnalysisProvider.notifier).refresh(),
        ),
        data: (analysis) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // ── 1. Nhận xét tổng quan từ AI ──────────────
            _AiSummaryCard(summary: analysis.summary),
            const SizedBox(height: 12),

            // ── 2. Điểm tốt / Cần cải thiện ─────────────
            if (analysis.diemTot.isNotEmpty)
              _FeedbackCard(
                title: 'Điểm tốt hôm nay',
                icon: Icons.thumb_up_rounded,
                iconColor: AppColors.positiveColor,
                items: analysis.diemTot,
                isPositive: true,
              ),
            const SizedBox(height: 12),

            if (analysis.canCaiThien.isNotEmpty)
              _FeedbackCard(
                title: 'Cần cải thiện',
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.orange,
                items: analysis.canCaiThien,
                isPositive: false,
              ),
            const SizedBox(height: 12),

            // ── 3. Thể trạng (Profile) ────────────────────
            _BodyStatusCard(context: healthContext),
            const SizedBox(height: 12),

            // ── 4. Sức khỏe hôm nay ───────────────────────
            _HealthTodayCard(context: healthContext),
            const SizedBox(height: 12),

            // ── 5. Dinh dưỡng hôm nay ─────────────────────
            _NutritionCard(context: healthContext),
            const SizedBox(height: 12),

            // ── 6. Hoạt động tuần ─────────────────────────
            if (analysis.weeklyActivity.isNotEmpty)
              _WeeklyActivityCard(
                weeklyActivity: analysis.weeklyActivity,
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// LOADING
// ══════════════════════════════════════════════════

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.accent),
          SizedBox(height: 16),
          Text(
            'AI đang phân tích dữ liệu của bạn...',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// ERROR
// ══════════════════════════════════════════════════

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                size: 64),
            const SizedBox(height: 16),
            const Text('Không thể kết nối AI',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Kiểm tra kết nối mạng và thử lại',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// 1. AI SUMMARY CARD
// ══════════════════════════════════════════════════

class _AiSummaryCard extends StatelessWidget {
  final String summary;
  const _AiSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.08),
            AppColors.surface,
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nhận xét từ AI',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(summary,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// 2. FEEDBACK CARD (Tốt / Cần cải thiện)
// ══════════════════════════════════════════════════

class _FeedbackCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> items;
  final bool isPositive;

  const _FeedbackCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isPositive ? AppColors.positiveColor : Colors.orange;
    final bgColor = isPositive
        ? AppColors.positiveColor.withValues(alpha: 0.05)
        : Colors.orange.withValues(alpha: 0.05);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgColor, AppColors.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: iconColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),

          // Items
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.check_circle_rounded
                          : Icons.arrow_right_rounded,
                      color: iconColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              height: 1.4)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// 3. BODY STATUS CARD (Thể trạng)
// ══════════════════════════════════════════════════

class _BodyStatusCard extends StatelessWidget {
  final UserHealthContext context;

  const _BodyStatusCard({required this.context});

  @override
  Widget build(BuildContext buildContext) {
    final bmi = context.bmi;
    final bmiCategory = context.bmiCategory;
    final bmiColor = _getBmiColor(bmiCategory);

    return _SectionCard(
      title: 'Thể trạng',
      icon: Icons.person_rounded,
      child: Column(
        children: [
          // BMI lớn ở trên
          if (bmi != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chỉ số BMI',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(bmi.toStringAsFixed(1),
                        style: TextStyle(
                            color: bmiColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bmiColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: bmiColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(bmiCategory,
                      style: TextStyle(
                          color: bmiColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // BMI bar
            _BmiBar(bmi: bmi),
            const SizedBox(height: 16),
          ],

          // Các chỉ số khác
          Row(
            children: [
              if (context.canNang != null)
                Expanded(
                  child: _StatItem(
                    label: 'Cân nặng',
                    value: '${context.canNang}kg',
                    icon: Icons.monitor_weight_rounded,
                    color: AppColors.accent,
                  ),
                ),
              if (context.chieuCao != null)
                Expanded(
                  child: _StatItem(
                    label: 'Chiều cao',
                    value: '${context.chieuCao}cm',
                    icon: Icons.height_rounded,
                    color: AppColors.waterColor,
                  ),
                ),
              if (context.tuoi != null)
                Expanded(
                  child: _StatItem(
                    label: 'Tuổi',
                    value: '${context.tuoi}',
                    icon: Icons.cake_rounded,
                    color: AppColors.sleepColor,
                  ),
                ),
            ],
          ),

          // Mục tiêu
          if (context.mucTieu != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag_rounded,
                      color: AppColors.accent, size: 16),
                  const SizedBox(width: 8),
                  Text('Mục tiêu: ${context.mucTieu}',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBmiColor(String category) {
    switch (category) {
      case 'Thiếu cân':
        return Colors.blue;
      case 'Bình thường':
        return AppColors.positiveColor;
      case 'Thừa cân':
        return Colors.orange;
      case 'Béo phì':
        return AppColors.negativeColor;
      default:
        return AppColors.textSecondary;
    }
  }
}

// BMI Bar trực quan
class _BmiBar extends StatelessWidget {
  final double bmi;
  const _BmiBar({required this.bmi});

  @override
  Widget build(BuildContext context) {
    // BMI range: 10 - 40
    final percent = ((bmi - 10) / 30).clamp(0.0, 1.0);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              // Gradient bar
              Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.red,
                    ],
                  ),
                ),
              ),
              // Indicator
              Positioned(
                left: percent *
                    (MediaQuery.of(context).size.width - 64) -
                    4,
                child: Container(
                  width: 8,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Thiếu cân',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
            Text('Bình thường',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
            Text('Thừa cân',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
            Text('Béo phì',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════
// 4. HEALTH TODAY CARD
// ══════════════════════════════════════════════════

class _HealthTodayCard extends StatelessWidget {
  final UserHealthContext context;
  const _HealthTodayCard({required this.context});

  @override
  Widget build(BuildContext buildContext) {
    final stepsPercent =
        (context.stepsToday / context.dailyStepsGoal).clamp(0.0, 1.0);

    return _SectionCard(
      title: 'Sức khỏe hôm nay',
      icon: Icons.favorite_rounded,
      child: Column(
        children: [
          // Bước chân với progress
          _ProgressRow(
            icon: Icons.directions_walk_rounded,
            color: AppColors.accent,
            label: 'Bước chân',
            value:
                '${context.stepsToday}/${context.dailyStepsGoal}',
            unit: 'bước',
            percent: stepsPercent,
          ),
          const SizedBox(height: 14),

          // Nhịp tim + Giấc ngủ
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Nhịp tim',
                  value: '${context.heartRateBpm}',
                  unit: 'BPM',
                  icon: Icons.favorite_rounded,
                  color: AppColors.negativeColor,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Giấc ngủ',
                  value: '${context.sleepHours}',
                  unit: 'giờ',
                  icon: Icons.bedtime_rounded,
                  color: AppColors.sleepColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// 5. NUTRITION CARD
// ══════════════════════════════════════════════════

class _NutritionCard extends StatelessWidget {
  final UserHealthContext context;
  const _NutritionCard({required this.context});

  @override
  Widget build(BuildContext buildContext) {
    final caloPercent =
        context.dailyCaloriesGoal > 0
            ? (context.caloriesBurned / context.dailyCaloriesGoal)
                .clamp(0.0, 1.0)
            : 0.0;
    final waterPercent =
        context.dailyWaterGoalMl > 0
            ? (context.waterIntakeMl / context.dailyWaterGoalMl)
                .clamp(0.0, 1.0)
            : 0.0;

    return _SectionCard(
      title: 'Dinh dưỡng hôm nay',
      icon: Icons.restaurant_rounded,
      child: Column(
        children: [
          // Calories nạp vào
          _ProgressRow(
            icon: Icons.fastfood_rounded,
            color: AppColors.caloriesColor,
            label: 'Calo nạp',
            value:
                '${context.caloriesBurned}/${context.dailyCaloriesGoal}',
            unit: 'kcal',
            percent: caloPercent,
          ),
          const SizedBox(height: 14),

          // Calories tiêu hao
          _ProgressRow(
            icon: Icons.local_fire_department_rounded,
            color: Colors.deepOrangeAccent,
            label: 'Calo tiêu hao',
            value: '${context.activeCaloriesBurned}',
            unit: 'kcal',
            percent: (context.activeCaloriesBurned / 500.0).clamp(0.0, 1.0), // Giả sử mục tiêu đốt là 500kcal
          ),
          const SizedBox(height: 14),

          // Nước uống
          _ProgressRow(
            icon: Icons.water_drop_rounded,
            color: AppColors.waterColor,
            label: 'Nước uống',
            value:
                '${(context.waterIntakeMl / 1000).toStringAsFixed(1)}/${(context.dailyWaterGoalMl / 1000).toStringAsFixed(1)}',
            unit: 'L',
            percent: waterPercent,
          ),
          const SizedBox(height: 14),

          // Macro: Protein / Carbs / Fat
          if (context.proteinGram > 0 ||
              context.carbsGram > 0 ||
              context.fatGram > 0) ...[
            const Divider(color: AppColors.cardBorder),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Macros',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _MacroItem(
                    label: 'Protein',
                    value: context.proteinGram,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _MacroItem(
                    label: 'Carbs',
                    value: context.carbsGram,
                    color: Colors.amber,
                  ),
                ),
                Expanded(
                  child: _MacroItem(
                    label: 'Chất béo',
                    value: context.fatGram,
                    color: AppColors.caloriesColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// 6. WEEKLY ACTIVITY CARD
// ══════════════════════════════════════════════════

class _WeeklyActivityCard extends StatelessWidget {
  final Map<String, int> weeklyActivity;
  const _WeeklyActivityCard({required this.weeklyActivity});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Hoạt động tuần này',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: weeklyActivity.entries.map((entry) {
          final percent = entry.value.clamp(0, 100);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(entry.key,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      backgroundColor: AppColors.progressBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _getColor(percent)),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 36,
                  child: Text('$percent%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getColor(int percent) {
    if (percent >= 80) return AppColors.positiveColor;
    if (percent >= 50) return AppColors.accent;
    return AppColors.caloriesColor;
  }
}

// ══════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════

/// Card section tái sử dụng
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Row hiển thị chỉ số với progress bar
class _ProgressRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;
  final double percent;

  const _ProgressRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: value,
                      style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: ' $unit',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: AppColors.progressBackground,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

/// Stat item nhỏ dạng icon + value + label
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          unit != null ? '$value $unit' : value,
          style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

/// Macro item (Protein/Carbs/Fat)
class _MacroItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${value.toStringAsFixed(0)}g',
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}