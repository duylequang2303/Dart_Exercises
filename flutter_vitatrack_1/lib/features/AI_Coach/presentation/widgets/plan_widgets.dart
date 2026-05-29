import 'package:flutter/material.dart';
import '../../domain/entities/coach_plan.dart';
import 'app_colors.dart';

/// Container section với tiêu đề (dùng cho cả task lẫn goal)
class PlanSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const PlanSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Một task trong kế hoạch ngày - có checkbox + strikethrough
class TaskItem extends StatelessWidget {
  final DailyTask task;
  final VoidCallback onToggle;

  const TaskItem({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            _buildCheckbox(),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  color: task.isCompleted
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontSize: 15,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: task.isCompleted ? AppColors.accent : Colors.transparent,
        shape: BoxShape.circle,
        border: task.isCompleted
            ? null
            : Border.all(color: AppColors.textSecondary, width: 2),
      ),
      child: task.isCompleted
          ? const Icon(Icons.check_rounded, color: Colors.black, size: 14)
          : null,
    );
  }
}

/// Divider mảnh giữa các task
class TaskDivider extends StatelessWidget {
  const TaskDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
        color: AppColors.cardBorder, height: 1, indent: 42);
  }
}

/// Mục tiêu tuần với progress bar có animation
class GoalProgressBar extends StatelessWidget {
  final WeeklyGoal goal;
  const GoalProgressBar({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(goal.title,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14)),
              Text('${goal.progressPercent}%',
                  style: const TextStyle(
                      color: AppColors.goalProgressFill,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: goal.progressPercent / 100),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) => LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.progressBackground,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.goalProgressFill),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}