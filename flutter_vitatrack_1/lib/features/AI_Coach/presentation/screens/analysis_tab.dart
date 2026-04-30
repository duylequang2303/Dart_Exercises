import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analysis_plan_provider.dart';
import '../widgets/analysis_widgets.dart';
import '../widgets/app_colors.dart';

class AnalysisTab extends ConsumerWidget {
  const AnalysisTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(healthAnalysisProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(healthAnalysisProvider.notifier).refresh(),
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      child: analysisAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.accent),
              SizedBox(height: 16),
              Text('AI đang phân tích dữ liệu...',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
        ),
        error: (error, stack) => _buildErrorState(ref),
        data: (analysis) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            AiInsightCard(summary: analysis.summary),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Chỉ số đáng chú ý',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            MetricCard(
              icon: Icons.bedtime_rounded,
              iconBackgroundColor: AppColors.sleepColor.withValues(alpha: 0.2),
              iconColor: AppColors.sleepColor,
              title: 'Chất lượng giấc ngủ',
              subtitle: 'Tốt hơn tuần trước',
              value:
                  '${analysis.sleepQualityChange > 0 ? '+' : ''}${analysis.sleepQualityChange}%',
              valueColor: analysis.sleepQualityChange >= 0
                  ? AppColors.positiveColor
                  : AppColors.negativeColor,
            ),
            MetricCard(
              icon: Icons.water_drop_rounded,
              iconBackgroundColor: AppColors.waterColor.withValues(alpha: 0.2),
              iconColor: AppColors.waterColor,
              title: 'Nạp nước',
              subtitle:
                  'Còn ${analysis.waterRemaining.toStringAsFixed(1)}L nữa',
              value: '${analysis.waterIntake.toStringAsFixed(1)}L',
              valueColor: AppColors.textPrimary,
            ),
            MetricCard(
              icon: Icons.local_fire_department_rounded,
              iconBackgroundColor: AppColors.caloriesColor.withValues(alpha: 0.2),
              iconColor: AppColors.caloriesColor,
              title: 'Calories đốt cháy',
              subtitle: 'Đạt ${analysis.caloriesGoalPercent}% mục tiêu',
              value: '${analysis.caloriesBurned}',
              valueColor: AppColors.caloriesColor,
            ),
            const SizedBox(height: 8),
            if (analysis.weeklyActivity.isNotEmpty)
              WeeklyActivityChart(weeklyActivity: analysis.weeklyActivity),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.5), size: 64),
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
              onPressed: () =>
                  ref.read(healthAnalysisProvider.notifier).refresh(),
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