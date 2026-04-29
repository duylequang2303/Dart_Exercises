import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analysis_plan_provider.dart';
import '../widgets/plan_widgets.dart';
import '../widgets/app_colors.dart';

class PlanTab extends ConsumerWidget {
  const PlanTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planState = ref.watch(coachPlanProvider);

    if (planState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            SizedBox(height: 16),
            Text('AI đang lên kế hoạch cho bạn...',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    if (planState.errorMessage != null && planState.plan == null) {
      return _buildErrorState(ref, planState.errorMessage!);
    }

    if (planState.plan == null) {
      return const Center(
          child: Text('Chưa có kế hoạch',
              style: TextStyle(color: AppColors.textSecondary)));
    }

    final plan = planState.plan!;

    return RefreshIndicator(
      onRefresh: () => ref.read(coachPlanProvider.notifier).fetchPlan(),
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          PlanSectionCard(
            title: 'Kế hoạch hôm nay',
            child: Column(
              children: plan.dailyTasks.asMap().entries.map((entry) {
                final index = entry.key;
                final task = entry.value;
                return Column(
                  children: [
                    TaskItem(
                      task: task,
                      onToggle: () => ref
                          .read(coachPlanProvider.notifier)
                          .toggleTask(task.id),
                    ),
                    if (index < plan.dailyTasks.length - 1)
                      const TaskDivider(),
                  ],
                );
              }).toList(),
            ),
          ),
          PlanSectionCard(
            title: 'Mục tiêu tuần',
            child: Column(
              children: plan.weeklyGoals
                  .map((goal) => GoalProgressBar(goal: goal))
                  .toList(),
            ),
          ),
          if (planState.errorMessage != null)
            _buildInlineError(planState.errorMessage!, ref),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_rounded,
                color: AppColors.textSecondary.withOpacity(0.5), size: 64),
            const SizedBox(height: 16),
            const Text('Không thể tải kế hoạch',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(coachPlanProvider.notifier).fetchPlan(),
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

  Widget _buildInlineError(String message, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: Colors.orange, fontSize: 12))),
          GestureDetector(
            onTap: () =>
                ref.read(coachPlanProvider.notifier).dismissError(),
            child: const Icon(Icons.close_rounded,
                color: Colors.orange, size: 16),
          ),
        ],
      ),
    );
  }
}