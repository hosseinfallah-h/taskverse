import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/tv_button.dart';
import '../models/task.dart';
import '../providers/tasks_provider.dart';
import '../services/tasks_api.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({super.key, required this.task});

  final Task task;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _toggleStatus() async {
    final newStatus = _task.isDone ? 'todo' : 'done';
    TvHaptics.taskComplete();
    try {
      final updated = await TasksApi.instance.setStatus(_task.id, newStatus);
      setState(() => _task = updated);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(allTasksProvider);
    } catch (e) {
      if (!mounted) return;
      TvHaptics.error();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: $e'), backgroundColor: TvColors.rose),
      );
    }
  }

  Future<void> _delete() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
            const Icon(
              Icons.delete_outline_rounded,
              size: 40,
              color: TvColors.rose,
            ),
            const SizedBox(height: TvSpacing.sm),
            Text(
              'این تسک را پاک کنم؟',
              textAlign: TextAlign.center,
              style: TvTypography.title.copyWith(
                color: isDark ? Colors.white : TvColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: TvSpacing.xs),
            Text(
              'برای ۳۰ روز در سبد بازیافت می‌ماند',
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
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TvRadius.md),
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
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: TvColors.rose,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TvRadius.md),
                      ),
                    ),
                    child: Text(
                      'پاک کن',
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
      try {
        await TasksApi.instance.delete(_task.id);
        ref.invalidate(todayTasksProvider);
        ref.invalidate(allTasksProvider);
        if (mounted) context.pop();
      } catch (e) {
        if (!mounted) return;
        TvHaptics.error();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا: $e'),
            backgroundColor: TvColors.rose,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? TvColors.night : TvColors.sand;
    final cardColor = isDark ? TvColors.nightSoft : TvColors.paper;
    final priorityColor = TvColors.priority[_task.priority] ?? TvColors.sky;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Gradient header backdrop
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [TvColors.nightSoft, TvColors.night],
                      )
                    : TvColors.dawnGradient,
                borderRadius: const BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(36),
                  bottomEnd: Radius.circular(36),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TvSpacing.md,
                    TvSpacing.sm,
                    TvSpacing.md,
                    TvSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Material(
                        color: isDark
                            ? TvColors.nightElevated
                            : Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            TvHaptics.tap();
                            context.pop();
                          },
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: isDark
                                  ? Colors.white
                                  : TvColors.ink,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: isDark
                            ? TvColors.nightElevated
                            : Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            TvHaptics.tap();
                            _delete();
                          },
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: TvColors.rose,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TvSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: TvSpacing.sm),

                        // Priority chip + status badge
                        Row(
                          children: [
                            _chip(
                              label: _priorityLabel(_task.priority),
                              color: priorityColor,
                              isDark: isDark,
                            ),
                            const SizedBox(width: TvSpacing.xs),
                            _chip(
                              label: _task.isDone ? 'انجام‌شده' : 'در جریان',
                              color: _task.isDone
                                  ? TvColors.mint
                                  : TvColors.sky,
                              isDark: isDark,
                            ),
                            if (_task.energy != null) ...[
                              const SizedBox(width: TvSpacing.xs),
                              _chip(
                                label: _energyLabel(_task.energy!),
                                color: TvColors.sunGold,
                                isDark: isDark,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: TvSpacing.lg),

                        // Title
                        Text(
                          _task.title,
                          textAlign: TextAlign.right,
                          style: TvTypography.display.copyWith(
                            color: isDark ? Colors.white : TvColors.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 28,
                            height: 1.5,
                            decoration: _task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ).animate().fadeIn(duration: 400.ms),

                        const SizedBox(height: TvSpacing.lg),

                        // Description card
                        if (_task.description != null &&
                            _task.description!.isNotEmpty)
                          _detailCard(
                            icon: Icons.notes_rounded,
                            title: 'توضیحات',
                            isDark: isDark,
                            cardColor: cardColor,
                            child: Text(
                              _task.description!,
                              textAlign: TextAlign.right,
                              style: TvTypography.body.copyWith(
                                color: isDark
                                    ? TvColors.inkMuted
                                    : TvColors.inkSoft,
                                height: 1.9,
                              ),
                            ),
                          ),

                        if (_task.description != null &&
                            _task.description!.isNotEmpty)
                          const SizedBox(height: TvSpacing.md),

                        // Details grid
                        _detailCard(
                          icon: Icons.info_outline_rounded,
                          title: 'جزئیات',
                          isDark: isDark,
                          cardColor: cardColor,
                          child: Column(
                            children: [
                              _detailRow(
                                label: 'اولویت',
                                value: _priorityLabel(_task.priority),
                                color: priorityColor,
                                isDark: isDark,
                              ),
                              if (_task.energy != null)
                                _detailRow(
                                  label: 'انرژی',
                                  value: _energyLabel(_task.energy!),
                                  isDark: isDark,
                                ),
                              if (_task.dueDate != null)
                                _detailRow(
                                  label: 'تاریخ سررسید',
                                  value: _fa(_task.dueDate
                                      .toString()
                                      .split(' ')[0]),
                                  isDark: isDark,
                                ),
                              if (_task.dueTime != null)
                                _detailRow(
                                  label: 'ساعت',
                                  value: _fa(_task.dueTime!),
                                  isDark: isDark,
                                ),
                              if (_task.estimatedMin != null)
                                _detailRow(
                                  label: 'زمان تخمینی',
                                  value:
                                      '${_fa(_task.estimatedMin!.toString())} دقیقه',
                                  isDark: isDark,
                                ),
                              if (_task.subtasksCount > 0)
                                _detailRow(
                                  label: 'زیرتسک‌ها',
                                  value:
                                      '${_fa(_task.subtasksDone.toString())} از ${_fa(_task.subtasksCount.toString())}',
                                  isDark: isDark,
                                ),
                              if (_task.rrule != null)
                                _detailRow(
                                  label: 'تکرار',
                                  value: 'دارد',
                                  isDark: isDark,
                                ),
                            ],
                          ),
                        ),

                        // Tags
                        if (_task.tags.isNotEmpty) ...[
                          const SizedBox(height: TvSpacing.md),
                          _detailCard(
                            icon: Icons.label_outline_rounded,
                            title: 'برچسب‌ها',
                            isDark: isDark,
                            cardColor: cardColor,
                            child: Wrap(
                              spacing: TvSpacing.xs,
                              runSpacing: TvSpacing.xs,
                              children: [
                                for (final t in _task.tags)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: TvSpacing.sm,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TvColors.brandPrimarySoft,
                                      borderRadius: BorderRadius.circular(
                                        TvRadius.full,
                                      ),
                                    ),
                                    child: Text(
                                      t.name,
                                      style: TvTypography.caption.copyWith(
                                        color: TvColors.brandPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: TvSpacing.xl),

                        // Action button
                        TvButton(
                          label: _task.isDone
                              ? 'برگردان به حالت فعال'
                              : 'انجام شد',
                          icon: _task.isDone
                              ? Icons.undo_rounded
                              : Icons.check_rounded,
                          variant: _task.isDone
                              ? TvButtonVariant.secondary
                              : TvButtonVariant.primary,
                          onPressed: _toggleStatus,
                        ),

                        const SizedBox(height: TvSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailCard({
    required IconData icon,
    required String title,
    required bool isDark,
    required Color cardColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(TvSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(TvRadius.xl),
        boxShadow: isDark ? null : TvColors.cardGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: TvColors.brandPrimary),
              const SizedBox(width: TvSpacing.xs),
              Text(
                title,
                style: TvTypography.label.copyWith(
                  color: isDark ? Colors.white : TvColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: TvSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _detailRow({
    required String label,
    required String value,
    required bool isDark,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TvTypography.bodySmall.copyWith(
              color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TvTypography.bodySmall.copyWith(
              color: color ??
                  (isDark ? Colors.white : TvColors.ink),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TvSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(TvRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TvTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _priorityLabel(int p) {
    switch (p) {
      case 0:
        return 'فوری';
      case 1:
        return 'بالا';
      case 2:
        return 'معمولی';
      case 3:
        return 'کم';
      default:
        return 'معمولی';
    }
  }

  String _energyLabel(String e) {
    switch (e) {
      case 'high':
        return 'پرانرژی';
      case 'low':
        return 'کم‌انرژی';
      case 'neutral':
        return 'معمولی';
      default:
        return e;
    }
  }

  String _fa(String s) {
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return s.split('').map((c) {
      final d = int.tryParse(c);
      return d == null ? c : fa[d];
    }).join();
  }
}