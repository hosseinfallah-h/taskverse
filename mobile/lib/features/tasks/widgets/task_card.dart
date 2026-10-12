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
    this.onToggleDone,
  });

  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleDone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = TvColors.priority[task.priority] ?? TvColors.sky;

    return Padding(
      padding: const EdgeInsets.only(bottom: TvSpacing.sm),
      child: TvCard(
        padding: const EdgeInsets.all(TvSpacing.md),
        borderRadius: TvRadius.lg,
        color: isDark ? TvColors.nightSoft : TvColors.paper,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circle checkbox
            GestureDetector(
              onTap: () {
                TvHaptics.tap();
                _confirmToggle(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: task.isDone ? TvColors.mint : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isDone
                        ? TvColors.mint
                        : priorityColor.withValues(alpha: 0.55),
                    width: 2,
                  ),
                ),
                child: task.isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: TvSpacing.sm),

            // Title + meta
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
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  if (task.dueTime != null || task.subtasksCount > 0) ...[
                    const SizedBox(height: TvSpacing.xs),
                    Row(
                      children: [
                        if (task.dueTime != null)
                          _meta(
                            Icons.access_time_rounded,
                            _fa(task.dueTime!),
                            isDark,
                          ),
                        if (task.dueTime != null &&
                            task.subtasksCount > 0)
                          const SizedBox(width: TvSpacing.sm),
                        if (task.subtasksCount > 0)
                          _meta(
                            Icons.checklist_rounded,
                            '${_fa(task.subtasksDone.toString())} از ${_fa(task.subtasksCount.toString())}',
                            isDark,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: TvSpacing.xs),

            // Priority dot
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
      ),
    );
  }

  Future<void> _confirmToggle(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goingDone = !task.isDone;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(
          TvSpacing.lg,
          TvSpacing.md,
          TvSpacing.lg,
          TvSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: isDark ? TvColors.nightSoft : TvColors.paper,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(TvRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: TvColors.inkMuted.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(TvRadius.full),
                ),
              ),
            ),
            const SizedBox(height: TvSpacing.lg),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: goingDone
                    ? TvColors.mintSoft
                    : TvColors.brandPrimarySoft,
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
              ),
              child: Icon(
                goingDone
                    ? Icons.check_circle_outline_rounded
                    : Icons.undo_rounded,
                size: 30,
                color: goingDone
                    ? TvColors.brandPrimary
                    : TvColors.brandPrimary,
              ),
            ),
            const SizedBox(height: TvSpacing.md),
            Text(
              goingDone ? 'تسک را انجام‌شده کنم؟' : 'برگردانی به حالت فعال؟',
              textAlign: TextAlign.center,
              style: TvTypography.title.copyWith(
                color: isDark ? Colors.white : TvColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: TvSpacing.xs),
            Text(
              task.title,
              textAlign: TextAlign.center,
              style: TvTypography.bodySmall.copyWith(
                color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
              ),
            ),
            const SizedBox(height: TvSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(TvRadius.md),
                        side: BorderSide(
                          color: TvColors.inkMuted.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Text(
                      'لغو',
                      style: TvTypography.label.copyWith(
                        color: TvColors.inkMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: TvSpacing.sm),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: goingDone
                          ? TvColors.brandPrimary
                          : TvColors.sky,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(TvRadius.md),
                      ),
                    ),
                    child: Text(
                      goingDone ? 'بله، انجام شد' : 'بله، برگردان',
                      style: TvTypography.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      TvHaptics.taskComplete();
      onToggleDone?.call();
    }
  }

  Widget _meta(IconData icon, String text, bool isDark) {
    return Row(
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