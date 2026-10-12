import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_input.dart';
import '../../projects/providers/projects_provider.dart';
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
  final _newSubtaskTitle = TextEditingController();
  bool _addingSubtask = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  void dispose() {
    _newSubtaskTitle.dispose();
    super.dispose();
  }

  Future<void> _refreshTask() async {
    try {
      final fresh = await TasksApi.instance.getTask(_task.id);
      if (mounted) setState(() => _task = fresh);
    } catch (_) {}
  }

  Future<void> _toggleStatus() async {
    final newStatus = _task.isDone ? 'todo' : 'done';
    TvHaptics.taskComplete();
    try {
      final updated = await TasksApi.instance.setStatus(_task.id, newStatus);
      if (!mounted) return;
      setState(() => _task = updated);
      _invalidateEverything();
    } catch (_) {
      if (!mounted) return;
      TvHaptics.error();
      _showError('تغییر وضعیت انجام نشد');
    }
  }

  Future<void> _toggleSubtask(Subtask s) async {
    final newStatus = s.isDone ? 'todo' : 'done';
    TvHaptics.taskComplete();
    try {
      await TasksApi.instance.setStatus(s.id, newStatus);
      if (!mounted) return;
      ref.invalidate(subtasksProvider(_task.id));

      final fresh = await TasksApi.instance.listSubtasks(_task.id);
      if (fresh.isNotEmpty && fresh.every((x) => x.isDone)) {
        final updated = await TasksApi.instance.setStatus(_task.id, 'done');
        if (mounted) setState(() => _task = updated);
      } else if (_task.isDone && !fresh.every((x) => x.isDone)) {
        final updated = await TasksApi.instance.setStatus(_task.id, 'todo');
        if (mounted) setState(() => _task = updated);
      } else {
        await _refreshTask();
      }

      _invalidateEverything();
    } catch (_) {
      if (!mounted) return;
      TvHaptics.error();
      _showError('تغییر وضعیت زیرتسک انجام نشد');
    }
  }

  Future<void> _addSubtask() async {
    final title = _newSubtaskTitle.text.trim();
    if (title.isEmpty) return;

    setState(() => _addingSubtask = true);
    try {
      await TasksApi.instance.createSubtask(parentId: _task.id, title: title);
      _newSubtaskTitle.clear();
      ref.invalidate(subtasksProvider(_task.id));
      await _refreshTask();
      _invalidateEverything();
    } catch (_) {
      if (mounted) _showError('خطا در ساخت زیرتسک');
    } finally {
      if (mounted) setState(() => _addingSubtask = false);
    }
  }

  Future<void> _deleteSubtask(Subtask s) async {
    try {
      await TasksApi.instance.delete(s.id);
      ref.invalidate(subtasksProvider(_task.id));
      await _refreshTask();
      _invalidateEverything();
    } catch (_) {
      if (mounted) _showError('خطا در حذف زیرتسک');
    }
  }

  Future<void> _delete() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
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
                    onPressed: () => Navigator.of(context).pop<bool>(false),
                    child: const Text('لغو'),
                  ),
                ),
                const SizedBox(width: TvSpacing.sm),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop<bool>(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: TvColors.rose,
                    ),
                    child: const Text('پاک کن'),
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
        _invalidateEverything();
        if (mounted) context.pop();
      } catch (_) {
        if (mounted) _showError('خطا در حذف');
      }
    }
  }

  void _invalidateEverything() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(todayTasksProvider);
      ref.invalidate(allTasksProvider);
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: TvColors.rose,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? TvColors.night : TvColors.sand;
    final cardColor = isDark ? TvColors.nightSoft : TvColors.paper;
    final priorityColor = TvColors.priority[_task.priority] ?? TvColors.sky;
    final subtasksAsync = ref.watch(subtasksProvider(_task.id));
    final project = _task.projectId == null
        ? null
        : ref.watch(projectByIdProvider(_task.projectId!));

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
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
                _topBar(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TvSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: TvSpacing.sm),
                        _chipRow(isDark, priorityColor),
                        const SizedBox(height: TvSpacing.lg),
                        _titleBlock(isDark),
                        const SizedBox(height: TvSpacing.lg),

                        // Description
                        if (_task.description != null &&
                            _task.description!.isNotEmpty) ...[
                          _card(
                            isDark: isDark,
                            cardColor: cardColor,
                            icon: Icons.notes_rounded,
                            title: 'توضیحات',
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
                          const SizedBox(height: TvSpacing.md),
                        ],

                        // Subtasks
                        subtasksAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: TvSpacing.lg,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: TvColors.mint,
                                ),
                              ),
                            ),
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (subs) => _subtasksSection(
                            isDark: isDark,
                            cardColor: cardColor,
                            subtasks: subs,
                          ),
                        ),
                        const SizedBox(height: TvSpacing.md),

                        // Full details
                        _card(
                          isDark: isDark,
                          cardColor: cardColor,
                          icon: Icons.info_outline_rounded,
                          title: 'جزئیات کامل',
                          child: Column(
                            children: [
                              _detailRow(
                                label: 'وضعیت',
                                value: _statusLabel(_task.status),
                                color: _task.isDone
                                    ? TvColors.mint
                                    : _task.isDoing
                                    ? TvColors.sky
                                    : TvColors.inkMuted,
                                isDark: isDark,
                              ),
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
                              if (project != null)
                                _detailRow(
                                  label: 'پروژه',
                                  value: project.name,
                                  isDark: isDark,
                                ),
                              if (_task.dueDate != null)
                                _detailRow(
                                  label: 'تاریخ سررسید',
                                  value: _formatJalali(_task.dueDate!),
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
                              if (_task.actualMin > 0)
                                _detailRow(
                                  label: 'زمان صرف‌شده',
                                  value:
                                      '${_fa(_task.actualMin.toString())} دقیقه',
                                  isDark: isDark,
                                ),
                              if (_task.rrule != null)
                                _detailRow(
                                  label: 'تکرار',
                                  value: _rruleLabel(_task.rrule!),
                                  isDark: isDark,
                                ),
                              if (_task.completedAt != null)
                                _detailRow(
                                  label: 'تاریخ تکمیل',
                                  value: _formatJalaliDateTime(
                                    _task.completedAt!,
                                  ),
                                  isDark: isDark,
                                ),
                              _detailRow(
                                label: 'تاریخ ساخت',
                                value: _formatJalaliDateTime(_task.createdAt),
                                isDark: isDark,
                              ),
                              if (project == null && _task.projectId != null)
                                _detailRow(
                                  label: 'پروژه',
                                  value:
                                      'پروژه #${_fa(_task.projectId!.toString())}',
                                  isDark: isDark,
                                ),
                            ],
                          ),
                        ),

                        // Tags
                        if (_task.tags.isNotEmpty) ...[
                          const SizedBox(height: TvSpacing.md),
                          _card(
                            isDark: isDark,
                            cardColor: cardColor,
                            icon: Icons.label_outline_rounded,
                            title: 'برچسب‌ها',
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

  Widget _topBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TvSpacing.md,
        TvSpacing.sm,
        TvSpacing.md,
        TvSpacing.md,
      ),
      child: Row(
        children: [
          Material(
            color: isDark ? TvColors.nightElevated : Colors.white,
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
                  color: isDark ? Colors.white : TvColors.ink,
                  size: 22,
                ),
              ),
            ),
          ),
          const Spacer(),
          Material(
            color: isDark ? TvColors.nightElevated : Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _delete,
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
    );
  }

  Widget _chipRow(bool isDark, Color priorityColor) {
    return Wrap(
      spacing: TvSpacing.xs,
      runSpacing: TvSpacing.xs,
      children: [
        _chip(label: _priorityLabel(_task.priority), color: priorityColor),
        _chip(
          label: _task.isDone ? 'انجام‌شده' : 'در جریان',
          color: _task.isDone ? TvColors.mint : TvColors.sky,
        ),
        if (_task.energy != null)
          _chip(label: _energyLabel(_task.energy!), color: TvColors.sunGold),
      ],
    );
  }

  Widget _titleBlock(bool isDark) {
    return Text(
      _task.title,
      textAlign: TextAlign.right,
      style: TvTypography.display.copyWith(
        color: isDark ? Colors.white : TvColors.ink,
        fontWeight: FontWeight.w700,
        fontSize: 26,
        height: 1.5,
        decoration: _task.isDone ? TextDecoration.lineThrough : null,
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _subtasksSection({
    required bool isDark,
    required Color cardColor,
    required List<Subtask> subtasks,
  }) {
    final done = subtasks.where((s) => s.isDone).length;
    final total = subtasks.length;
    final ratio = total == 0 ? 0.0 : done / total;

    return _card(
      isDark: isDark,
      cardColor: cardColor,
      icon: Icons.checklist_rounded,
      title: 'زیرتسک‌ها',
      trailing: total > 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_fa(done.toString())} از ${_fa(total.toString())}',
                  style: TvTypography.caption.copyWith(
                    color: TvColors.brandPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${_fa((ratio * 100).round().toString())}٪)',
                  style: TvTypography.caption.copyWith(
                    color: ratio >= 1.0 ? TvColors.mint : TvColors.inkMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (total > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(TvRadius.full),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: ratio),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? TvColors.nightElevated
                      : TvColors.brandPrimarySoft.withValues(alpha: 0.5),
                  valueColor: AlwaysStoppedAnimation(
                    ratio >= 1.0 ? TvColors.mint : TvColors.brandPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: TvSpacing.md),
          ],
          for (final s in subtasks) _subtaskRow(s, isDark),
          if (subtasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TvSpacing.sm),
              child: Text(
                'هنوز زیرتسکی نداری',
                style: TvTypography.caption.copyWith(
                  color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
                ),
              ),
            ),
          const SizedBox(height: TvSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TvInput(
                  controller: _newSubtaskTitle,
                  label: '',
                  hint: 'زیرتسک تازه...',
                ),
              ),
              const SizedBox(width: TvSpacing.xs),
              IconButton(
                onPressed: _addingSubtask ? null : _addSubtask,
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: TvColors.brandPrimary,
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _subtaskRow(Subtask s, bool isDark) {
    final priorityColor = TvColors.priority[s.priority] ?? TvColors.sky;

    return Padding(
      padding: const EdgeInsets.only(bottom: TvSpacing.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSubtask(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: s.isDone ? TvColors.mint : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: s.isDone
                      ? TvColors.mint
                      : priorityColor.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: s.isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: TvSpacing.sm),
          Expanded(
            child: Text(
              s.title,
              textAlign: TextAlign.right,
              style: TvTypography.bodySmall.copyWith(
                color: s.isDone
                    ? TvColors.inkMuted
                    : (isDark ? Colors.white : TvColors.ink),
                decoration: s.isDone ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _deleteSubtask(s),
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: TvColors.inkMuted,
            ),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(6),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required bool isDark,
    required Color cardColor,
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
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
              const Spacer(),
              if (trailing != null) trailing,
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              style: TvTypography.bodySmall.copyWith(
                color: color ?? (isDark ? Colors.white : TvColors.ink),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({required String label, required Color color}) {
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

  String _statusLabel(String s) {
    switch (s) {
      case 'todo':
        return 'انجام‌نشده';
      case 'doing':
        return 'در جریان';
      case 'done':
        return 'انجام‌شده';
      case 'cancelled':
        return 'لغو‌شده';
      default:
        return s;
    }
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

  String _rruleLabel(String r) {
    if (r.contains('DAILY')) return 'هر روز';
    if (r.contains('WEEKLY')) return 'هر هفته';
    if (r.contains('MONTHLY')) return 'هر ماه';
    return 'دارد';
  }

  String _formatJalali(DateTime dt) {
    final j = Jalali.fromDateTime(dt);
    return '${_fa(j.year.toString())}/${_fa(j.month.toString())}/${_fa(j.day.toString())}';
  }

  String _formatJalaliDateTime(DateTime dt) {
    final j = Jalali.fromDateTime(dt);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${_fa(j.year.toString())}/${_fa(j.month.toString())}/${_fa(j.day.toString())} - ${_fa(h)}:${_fa(m)}';
  }

  String _fa(String s) {
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return s.split('').map((c) {
      final d = int.tryParse(c);
      return d == null ? c : fa[d];
    }).join();
  }
}
