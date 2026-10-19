import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/tv_card.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleRequested,
  });

  final Task task;
  final VoidCallback? onTap;

  /// Parent (HomeScreen / Calendar) owns the confirm sheet + toggle.
  /// This widget just fires the intent when the checkbox is tapped.
  final VoidCallback? onToggleRequested;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor =
        TvColors.priority[task.priority] ?? TvColors.sky;
    final hasSubtasks = task.subtasksCount > 0;
    final ratio = hasSubtasks
        ? (task.subtasksDone / task.subtasksCount).clamp(0.0, 1.0)
        : 0.0;
    final allSubtasksDone =
        hasSubtasks && task.subtasksDone == task.subtasksCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: TvSpacing.sm),
      child: TvCard(
        padding: const EdgeInsets.all(TvSpacing.md),
        borderRadius: TvRadius.lg,
        color: isDark ? TvColors.nightSoft : TvColors.paper,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    TvHaptics.tap();
                    onToggleRequested?.call();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color:
                          task.isDone ? TvColors.mint : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.isDone
                            ? TvColors.mint
                            : priorityColor.withValues(alpha: 0.55),
                        width: 2,
                      ),
                    ),
                    child: task.isDone
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: TvSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        textAlign: TextAlign.right,
                        style: TvTypography.title.copyWith(
                          color: task.isDone
                              ? TvColors.inkMuted
                              : (isDark ? Colors.white : TvColors.ink),
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      if (task.dueTime != null || hasSubtasks) ...[
                        const SizedBox(height: TvSpacing.xs),
                        Row(
                          children: [
                            if (task.dueTime != null)
                              _meta(
                                Icons.access_time_rounded,
                                _fa(task.dueTime!),
                                isDark,
                              ),
                            if (task.dueTime != null && hasSubtasks)
                              const SizedBox(width: TvSpacing.sm),
                            if (hasSubtasks)
                              _meta(
                                Icons.checklist_rounded,
                                '${_fa(task.subtasksDone.toString())} از ${_fa(task.subtasksCount.toString())}',
                                isDark,
                                trailing: allSubtasksDone
                                    ? Icons.check_circle_rounded
                                    : null,
                                trailingColor: TvColors.mint,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: TvSpacing.xs),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: priorityColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasSubtasks) ...[
              const SizedBox(height: TvSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(TvRadius.full),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: ratio),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) =>
                            LinearProgressIndicator(
                          value: v,
                          minHeight: 5,
                          backgroundColor: isDark
                              ? TvColors.nightElevated
                              : TvColors.brandPrimarySoft
                                  .withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation(
                            allSubtasksDone
                                ? TvColors.mint
                                : TvColors.brandPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: TvSpacing.sm),
                  Text(
                    '${_fa((ratio * 100).round().toString())}٪',
                    style: TvTypography.caption.copyWith(
                      color: allSubtasksDone
                          ? TvColors.mint
                          : TvColors.brandPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _meta(
    IconData icon,
    String text,
    bool isDark, {
    IconData? trailing,
    Color? trailingColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TvTypography.caption.copyWith(
            color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 4),
          Icon(
            trailing,
            size: 13,
            color: trailingColor ?? TvColors.mint,
          ),
        ],
      ],
    );
  }

  String _fa(String s) {
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return s.split('').map((c) {
      final d = int.tryParse(c);
      return d == null ? c : fa[d];
    }).join();
  }
}