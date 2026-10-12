import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_input.dart';
import '../providers/tasks_provider.dart';
import '../services/tasks_api.dart';

class TaskEditorSheet extends ConsumerStatefulWidget {
  const TaskEditorSheet({super.key});

  @override
  ConsumerState<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends ConsumerState<TaskEditorSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  int _priority = 2;
  String? _energy;
  DateTime? _dueDate;
  String? _dueTime;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      TvHaptics.error();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عنوان تسک را وارد کن')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await TasksApi.instance.create(
        title: _title.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        priority: _priority,
        energy: _energy,
        dueDate: _dueDate,
        dueTime: _dueTime,
      );

      if (!mounted) return;
      TvHaptics.celebrate();
      ref.invalidate(todayTasksProvider);
      ref.invalidate(allTasksProvider);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      TvHaptics.error();
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            // Drag handle
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

            Text(
              'تسک تازه',
              textAlign: TextAlign.right,
              style: TvTypography.headline.copyWith(
                color: isDark ? Colors.white : TvColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: TvSpacing.lg),

            // Title
            TvInput(
              controller: _title,
              label: 'عنوان',
              hint: 'مثلاً طراحی صفحه فرود',
              autofocus: true,
            ),
            const SizedBox(height: TvSpacing.md),

            // Description
            TvInput(
              controller: _description,
              label: 'توضیحات (اختیاری)',
              hint: 'جزئیات...',
            ),
            const SizedBox(height: TvSpacing.md),

            // Priority
            Text(
              'اولویت',
              style: TvTypography.label.copyWith(
                color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
              ),
            ),
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

            // Energy
            Text(
              'انرژی',
              style: TvTypography.label.copyWith(
                color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
              ),
            ),
            const SizedBox(height: TvSpacing.xs),
            Row(
              children: [
                _energyChip('high', 'پرانرژی'),
                const SizedBox(width: TvSpacing.xs),
                _energyChip('neutral', 'معمولی'),
                const SizedBox(width: TvSpacing.xs),
                _energyChip('low', 'کم‌انرژی'),
              ],
            ),
            const SizedBox(height: TvSpacing.lg),

            // Save button
            TvButton(
              label: 'ذخیره تسک',
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
            style: TvTypography.label.copyWith(
              color: selected ? color : TvColors.inkMuted,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _energyChip(String value, String label) {
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
            color: selected
                ? TvColors.mintSoft
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? TvColors.mint
                  : TvColors.inkMuted.withValues(alpha: 0.2),
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(TvRadius.md),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TvTypography.label.copyWith(
              color: selected
                  ? TvColors.brandPrimary
                  : TvColors.inkMuted,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}