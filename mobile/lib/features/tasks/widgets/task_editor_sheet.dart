import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_input.dart';
import '../../projects/models/project.dart';
import '../../projects/providers/projects_provider.dart';
import '../../projects/services/projects_api.dart';
import '../../tags/services/tags_api.dart';
import '../models/task.dart' show TagBrief;
import '../providers/tasks_provider.dart';
import '../services/tasks_api.dart';

class TaskEditorSheet extends ConsumerStatefulWidget {
  const TaskEditorSheet({super.key});

  @override
  ConsumerState<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends ConsumerState<TaskEditorSheet> {
  // Basics
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _notes = TextEditingController();
  final _estimate = TextEditingController();

  // Choices
  int _priority = 2;
  String? _energy;
  int? _projectId;
  List<int> _tagIds = [];

  // Schedule
  DateTime? _dueDate; // stored as Gregorian for API
  TimeOfDay? _dueTime;

  // Recurrence
  String? _rrule; // null = none

  // Subtasks
  final List<TextEditingController> _subtaskControllers = [];

  // UI state
  bool _saving = false;
  bool _showAdvanced = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _notes.dispose();
    _estimate.dispose();
    for (final c in _subtaskControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    TvHaptics.tap();

    // Convert Gregorian to Jalali for display, but use Material picker on Gregorian under the hood.
    // We show a Jalali-formatted label to the user.
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
      locale: const Locale('fa', 'IR'),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickTime() async {
    TvHaptics.tap();
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      locale: const Locale('fa', 'IR'),
    );
    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  void _addSubtask() {
    TvHaptics.tap();
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _removeSubtask(int index) {
    TvHaptics.tap();
    final c = _subtaskControllers.removeAt(index);
    c.dispose();
    setState(() {});
  }

  Future<void> _createProject() async {
    TvHaptics.tap();
    final name = await _promptText(title: 'پروژه تازه', hint: 'اسم پروژه...');
    if (name == null || name.trim().isEmpty) return;
    try {
      final p = await ProjectsApi.instance.create(name: name.trim());
      ref.invalidate(projectsProvider);
      if (mounted) setState(() => _projectId = p.id);
    } catch (e) {
      _showError('خطا در ساخت پروژه');
    }
  }

  Future<void> _createTag() async {
    TvHaptics.tap();
    final name = await _promptText(
      title: 'برچسب تازه',
      hint: 'مثلاً: کار، خانه...',
    );
    if (name == null || name.trim().isEmpty) return;
    try {
      final t = await TagsApi.instance.create(name: name.trim());
      ref.invalidate(tagsProvider);
      if (mounted) setState(() => _tagIds = [..._tagIds, t.id]);
    } catch (e) {
      _showError('خطا در ساخت برچسب');
    }
  }

  Future<String?> _promptText({
    required String title,
    required String hint,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('ساخت'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      TvHaptics.error();
      _showError('عنوان تسک را وارد کن');
      return;
    }

    setState(() => _saving = true);

    try {
      // Parse estimate
      int? estimatedMin;
      if (_estimate.text.trim().isNotEmpty) {
        estimatedMin = int.tryParse(_estimate.text.trim());
      }

      // Format due time
      String? dueTimeStr;
      if (_dueTime != null) {
        final h = _dueTime!.hour.toString().padLeft(2, '0');
        final m = _dueTime!.minute.toString().padLeft(2, '0');
        dueTimeStr = '$h:$m:00';
      }

      final task = await TasksApi.instance.create(
        title: _title.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        projectId: _projectId,
        priority: _priority,
        energy: _energy,
        dueDate: _dueDate,
        dueTime: dueTimeStr,
        estimatedMin: estimatedMin,
        tagIds: _tagIds,
        rrule: _rrule,
      );

      // Add subtasks (non-empty ones)
      for (final c in _subtaskControllers) {
        final t = c.text.trim();
        if (t.isEmpty) continue;
        try {
          await TasksApi.instance.create(
            title: t,
            parentId: task.id,
            priority: 2,
          );
        } catch (_) {}
      }

      if (!mounted) return;
      TvHaptics.celebrate();
      ref.invalidate(todayTasksProvider);
      ref.invalidate(allTasksProvider);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      TvHaptics.error();
      setState(() => _saving = false);
      _showError('خطا در ذخیره‌سازی: $e');
    }
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
    final projectsAsync = ref.watch(projectsProvider);
    final tagsAsync = ref.watch(tagsProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? TvColors.nightSoft : TvColors.paper,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(TvRadius.xl),
        ),
      ),
      padding: EdgeInsets.only(
        left: TvSpacing.lg,
        right: TvSpacing.lg,
        top: TvSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + TvSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
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

            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: TvColors.mintSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.add_task_rounded,
                    color: TvColors.brandPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: TvSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تسک تازه',
                        style: TvTypography.headline.copyWith(
                          color: isDark ? Colors.white : TvColors.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'بذری برای باغ امروزت',
                        style: TvTypography.caption.copyWith(
                          color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: TvSpacing.lg),

            // ============ BASICS ============
            TvInput(
              controller: _title,
              label: 'عنوان',
              hint: 'مثلاً: طراحی صفحه فرود',
              autofocus: true,
            ),
            const SizedBox(height: TvSpacing.md),

            TvInput(
              controller: _description,
              label: 'توضیحات',
              hint: 'جزئیات تسک...',
              maxLines: 3,
            ),
            const SizedBox(height: TvSpacing.lg),

            // ============ PRIORITY ============
            _sectionLabel('اولویت', isDark),
            const SizedBox(height: TvSpacing.xs),
            Row(
              children: [
                _priorityChip(0, 'فوری', TvColors.rose),
                const SizedBox(width: TvSpacing.xs),
                _priorityChip(1, 'بالا', TvColors.sunGold),
                const SizedBox(width: TvSpacing.xs),
                _priorityChip(2, 'معمولی', TvColors.sky),
                const SizedBox(width: TvSpacing.xs),
                _priorityChip(3, 'کم', TvColors.inkMuted),
              ],
            ),
            const SizedBox(height: TvSpacing.md),

            // ============ ENERGY ============
            _sectionLabel('انرژی مورد نیاز', isDark),
            const SizedBox(height: TvSpacing.xs),
            Row(
              children: [
                _energyChip('high', 'پرانرژی', Icons.bolt_rounded),
                const SizedBox(width: TvSpacing.xs),
                _energyChip('neutral', 'معمولی', Icons.balance_rounded),
                const SizedBox(width: TvSpacing.xs),
                _energyChip('low', 'کم‌انرژی', Icons.nightlight_round),
              ],
            ),
            const SizedBox(height: TvSpacing.lg),

            // ============ PROJECT ============
            _sectionLabel('پروژه', isDark),
            const SizedBox(height: TvSpacing.xs),
            projectsAsync.when(
              loading: () => const _MiniLoader(),
              error: (_, __) => _inlineError('خطا در بارگیری پروژه‌ها'),
              data: (projects) => _projectPicker(projects, isDark),
            ),
            const SizedBox(height: TvSpacing.lg),

            // ============ TAGS ============
            _sectionLabel('برچسب‌ها', isDark),
            const SizedBox(height: TvSpacing.xs),
            tagsAsync.when(
              loading: () => const _MiniLoader(),
              error: (_, __) => _inlineError('خطا در بارگیری برچسب‌ها'),
              data: (tags) => _tagsPicker(tags, isDark),
            ),
            const SizedBox(height: TvSpacing.lg),

            // ============ SCHEDULE ============
            _sectionLabel('زمان‌بندی', isDark),
            const SizedBox(height: TvSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: _dateTimeTile(
                    icon: Icons.calendar_today_rounded,
                    label: _dueDate == null
                        ? 'تاریخ سررسید'
                        : _formatJalali(_dueDate!),
                    onTap: _pickDate,
                    active: _dueDate != null,
                    isDark: isDark,
                    onClear: _dueDate == null
                        ? null
                        : () => setState(() => _dueDate = null),
                  ),
                ),
                const SizedBox(width: TvSpacing.sm),
                Expanded(
                  child: _dateTimeTile(
                    icon: Icons.access_time_rounded,
                    label: _dueTime == null ? 'ساعت' : _formatTime(_dueTime!),
                    onTap: _pickTime,
                    active: _dueTime != null,
                    isDark: isDark,
                    onClear: _dueTime == null
                        ? null
                        : () => setState(() => _dueTime = null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TvSpacing.md),

            TvInput(
              controller: _estimate,
              label: 'زمان تخمینی (دقیقه)',
              hint: 'مثلاً 60',
              keyboardType: TextInputType.number,
              digitsOnly: true,
            ),
            const SizedBox(height: TvSpacing.lg),

            // ============ SUBTASKS ============
            Row(
              children: [
                _sectionLabel('زیرتسک‌ها', isDark),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('افزودن'),
                  style: TextButton.styleFrom(
                    foregroundColor: TvColors.brandPrimary,
                  ),
                ),
              ],
            ),
            if (_subtaskControllers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: TvSpacing.sm),
                child: Text(
                  'می‌تونی این تسک رو به زیرتسک‌ها بشکنی',
                  style: TvTypography.caption.copyWith(
                    color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (var i = 0; i < _subtaskControllers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: TvSpacing.xs),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subtaskControllers[i],
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: 'زیرتسک ${_fa((i + 1).toString())}',
                                fillColor: isDark
                                    ? TvColors.nightElevated
                                    : TvColors.sand,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: TvSpacing.md,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeSubtask(i),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: TvColors.rose,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            const SizedBox(height: TvSpacing.lg),

            // ============ ADVANCED TOGGLE ============
            InkWell(
              onTap: () {
                TvHaptics.tap();
                setState(() => _showAdvanced = !_showAdvanced);
              },
              borderRadius: BorderRadius.circular(TvRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: TvSpacing.xs),
                child: Row(
                  children: [
                    Text(
                      'تنظیمات پیشرفته',
                      style: TvTypography.label.copyWith(
                        color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _showAdvanced
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
                    ),
                  ],
                ),
              ),
            ),

            if (_showAdvanced) ...[
              const SizedBox(height: TvSpacing.md),
              _sectionLabel('تکرار', isDark),
              const SizedBox(height: TvSpacing.xs),
              Wrap(
                spacing: TvSpacing.xs,
                runSpacing: TvSpacing.xs,
                children: [
                  _rruleChip(null, 'بدون تکرار'),
                  _rruleChip('FREQ=DAILY', 'هر روز'),
                  _rruleChip('FREQ=WEEKLY', 'هر هفته'),
                  _rruleChip('FREQ=MONTHLY', 'هر ماه'),
                ],
              ),
              const SizedBox(height: TvSpacing.md),
              TvInput(
                controller: _notes,
                label: 'یادداشت (Markdown)',
                hint: 'نکات، لینک‌ها، جزئیات...',
                maxLines: 4,
              ),
            ],

            const SizedBox(height: TvSpacing.xl),

            // ============ SAVE ============
            TvButton(
              label: 'کاشتن تسک',
              icon: Icons.check_rounded,
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
            const SizedBox(height: TvSpacing.sm),
          ],
        ),
      ),
    );
  }

  // ---------- Pickers ----------

  Widget _projectPicker(List<Project> projects, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: TvSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? TvColors.nightElevated : TvColors.sand,
              borderRadius: BorderRadius.circular(TvRadius.md),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: _projectId,
                isExpanded: true,
                hint: Text(
                  'بدون پروژه',
                  style: TvTypography.bodySmall.copyWith(
                    color: TvColors.inkMuted,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('بدون پروژه', style: TvTypography.bodySmall),
                  ),
                  for (final p in projects)
                    DropdownMenuItem(
                      value: p.id,
                      child: Row(
                        children: [
                          if (p.color != null) ...[
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _hexColor(p.color!),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(p.name, style: TvTypography.bodySmall),
                        ],
                      ),
                    ),
                ],
                onChanged: (v) {
                  TvHaptics.tap();
                  setState(() => _projectId = v);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: TvSpacing.xs),
        IconButton(
          onPressed: _createProject,
          icon: const Icon(
            Icons.add_circle_outline_rounded,
            color: TvColors.brandPrimary,
          ),
        ),
      ],
    );
  }

  Widget _tagsPicker(List<TagBrief> tags, bool isDark) {
    return Wrap(
      spacing: TvSpacing.xs,
      runSpacing: TvSpacing.xs,
      children: [
        for (final t in tags)
          _tagChip(
            label: t.name,
            selected: _tagIds.contains(t.id),
            onTap: () {
              TvHaptics.tap();
              setState(() {
                if (_tagIds.contains(t.id)) {
                  _tagIds = _tagIds.where((x) => x != t.id).toList();
                } else {
                  _tagIds = [..._tagIds, t.id];
                }
              });
            },
            isDark: isDark,
          ),
        GestureDetector(
          onTap: _createTag,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TvSpacing.sm,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: TvColors.brandPrimary.withValues(alpha: 0.4),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(TvRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: TvColors.brandPrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  'برچسب تازه',
                  style: TvTypography.caption.copyWith(
                    color: TvColors.brandPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tagChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: TvSpacing.sm,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? TvColors.brandPrimary
              : (isDark ? TvColors.nightElevated : TvColors.sand),
          borderRadius: BorderRadius.circular(TvRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TvTypography.caption.copyWith(
                color: selected
                    ? Colors.white
                    : (isDark ? TvColors.inkMuted : TvColors.inkSoft),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool active,
    required bool isDark,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TvSpacing.md,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: active
              ? TvColors.brandPrimarySoft
              : (isDark ? TvColors.nightElevated : TvColors.sand),
          borderRadius: BorderRadius.circular(TvRadius.md),
          border: Border.all(
            color: active
                ? TvColors.brandPrimary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: active
                  ? TvColors.brandPrimary
                  : (isDark ? TvColors.inkMuted : TvColors.inkSoft),
            ),
            const SizedBox(width: TvSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: TvTypography.label.copyWith(
                  color: active
                      ? TvColors.brandPrimary
                      : (isDark ? TvColors.inkMuted : TvColors.inkSoft),
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: TvColors.inkMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _priorityChip(int value, String label, Color color) {
    final selected = _priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          TvHaptics.tap();
          setState(() => _priority = value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.18)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.6)
                  : TvColors.inkMuted.withValues(alpha: 0.2),
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(TvRadius.md),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TvTypography.caption.copyWith(
              color: selected ? color : TvColors.inkMuted,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _energyChip(String value, String label, IconData icon) {
    final selected = _energy == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          TvHaptics.tap();
          setState(() => _energy = selected ? null : value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? TvColors.mintSoft : Colors.transparent,
            border: Border.all(
              color: selected
                  ? TvColors.mint
                  : TvColors.inkMuted.withValues(alpha: 0.2),
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(TvRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? TvColors.brandPrimary : TvColors.inkMuted,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TvTypography.caption.copyWith(
                  color: selected ? TvColors.brandPrimary : TvColors.inkMuted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rruleChip(String? value, String label) {
    final selected = _rrule == value;
    return GestureDetector(
      onTap: () {
        TvHaptics.tap();
        setState(() => _rrule = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: TvSpacing.md,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? TvColors.brandPrimary : Colors.transparent,
          border: Border.all(
            color: selected
                ? TvColors.brandPrimary
                : TvColors.inkMuted.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(TvRadius.full),
        ),
        child: Text(
          label,
          style: TvTypography.caption.copyWith(
            color: selected ? Colors.white : TvColors.inkMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Text(
      text,
      style: TvTypography.label.copyWith(
        color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _inlineError(String text) {
    return Text(
      text,
      style: TvTypography.caption.copyWith(color: TvColors.rose),
    );
  }

  // ---------- Utilities ----------

  String _formatJalali(DateTime dt) {
    final j = Jalali.fromDateTime(dt);
    return '${j.year}/${j.month}/${j.day}';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Color _hexColor(String hex) {
    try {
      final h = hex.replaceFirst('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return TvColors.brandPrimary;
    }
  }

  String _fa(String value) {
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return value.split('').map((c) {
      final d = int.tryParse(c);
      return d == null ? c : fa[d];
    }).join();
  }
}

// ---------- Small helpers ----------

class _MiniLoader extends StatelessWidget {
  const _MiniLoader();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(TvSpacing.md),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: TvColors.mint),
      ),
    );
  }
}
