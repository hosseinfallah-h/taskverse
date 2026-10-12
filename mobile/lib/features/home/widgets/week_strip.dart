import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/theme_ext.dart';
import '../../../core/theme/typography.dart';
import '../../tasks/providers/tasks_provider.dart';

/// Horizontal Jalali week strip. Tap a day → filters Home.
/// Colors follow the active season via Theme.of(context).
class WeekStrip extends ConsumerWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDayProvider);

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final jsWeekday = _jalaliWeekdayStart(today);
    final weekStart = todayStart.subtract(Duration(days: jsWeekday));
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TvSpacing.md),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: TvSpacing.xs),
        itemBuilder: (_, i) => _DayChip(
          date: days[i],
          selected: _isSameDay(days[i], selected),
          isToday: _isSameDay(days[i], todayStart),
          onTap: () {
            TvHaptics.tap();
            ref.read(selectedDayProvider.notifier).state = days[i];
          },
        ),
      ),
    );
  }

  static int _jalaliWeekdayStart(DateTime d) {
    switch (d.weekday) {
      case DateTime.saturday:
        return 0;
      case DateTime.sunday:
        return 1;
      case DateTime.monday:
        return 2;
      case DateTime.tuesday:
        return 3;
      case DateTime.wednesday:
        return 4;
      case DateTime.thursday:
        return 5;
      case DateTime.friday:
        return 6;
      default:
        return 0;
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.date,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  static const _faWeekdays = [
    'شنبه',
    'یک‌شنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه',
  ];

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final accent = context.accent;
    final surface = context.surface;
    final ink = context.ink;
    final inkSoft = context.inkSoft;

    final j = Jalali.fromDateTime(date);
    final weekdayIndex = WeekStrip._jalaliWeekdayStart(date);
    final weekday = _faWeekdays[weekdayIndex];
    final dayNum = _fa(j.day.toString());

    final bg = selected ? brand : surface;
    final labelColor = selected ? Colors.white : inkSoft;
    final numColor = selected ? Colors.white : ink;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 62,
        padding: const EdgeInsets.symmetric(
          horizontal: TvSpacing.xs,
          vertical: TvSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(TvRadius.lg),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.5)
                : (isToday
                      ? accent.withValues(alpha: 0.6)
                      : ink.withValues(alpha: 0.06)),
            width: isToday && !selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: brand.withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekday,
              style: TvTypography.caption.copyWith(
                color: labelColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNum,
              style: TvTypography.numericSmall.copyWith(
                color: numColor,
                fontSize: 20,
              ),
            ),
            if (isToday) ...[
              const SizedBox(height: 3),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
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
