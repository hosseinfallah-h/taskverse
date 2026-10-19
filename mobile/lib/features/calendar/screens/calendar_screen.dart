import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/theme_ext.dart';
import '../../../core/theme/typography.dart';
import '../../tasks/providers/tasks_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late Jalali _month;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = Jalali.now();
    _month = Jalali(now.year, now.month, 1);
    final t = DateTime.now();
    _selectedDay = DateTime(t.year, t.month, t.day);
  }

  static const _faMonths = [
    '',
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static const _faWeekdays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  void _prevMonth() {
    TvHaptics.tap();
    final prev = _month.addMonths(-1);
    setState(() => _month = Jalali(prev.year, prev.month, 1));
  }

  void _nextMonth() {
    TvHaptics.tap();
    final next = _month.addMonths(1);
    setState(() => _month = Jalali(next.year, next.month, 1));
  }

  void _selectDay(DateTime d) {
    TvHaptics.tap();
    setState(() => _selectedDay = d);
    ref.read(selectedDayProvider.notifier).state = d;
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final asyncTasks = ref.watch(allTasksProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TvSpacing.md,
                TvSpacing.lg,
                TvSpacing.md,
                TvSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تقویم',
                          style: TvTypography.headline.copyWith(
                            color: context.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'همه‌ی تسک‌ها یک نگاه',
                          style: TvTypography.bodySmall.copyWith(
                            color: context.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Today button
                  Material(
                    color: context.brandSoft,
                    borderRadius: BorderRadius.circular(TvRadius.full),
                    child: InkWell(
                      onTap: () {
                        TvHaptics.tap();
                        final t = DateTime.now();
                        final today = DateTime(t.year, t.month, t.day);
                        final now = Jalali.now();
                        setState(() {
                          _selectedDay = today;
                          _month = Jalali(now.year, now.month, 1);
                        });
                        ref.read(selectedDayProvider.notifier).state = today;
                      },
                      borderRadius: BorderRadius.circular(TvRadius.full),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TvSpacing.sm,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.today_rounded, size: 16, color: brand),
                            const SizedBox(width: 4),
                            Text(
                              'امروز',
                              style: TvTypography.caption.copyWith(
                                color: brand,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            // Month header + nav
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TvSpacing.md),
              child: Row(
                children: [
                  _navBtn(Icons.chevron_right_rounded, _prevMonth),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_faMonths[_month.month]} ${_fa(_month.year.toString())}',
                        style: TvTypography.title.copyWith(
                          color: context.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  _navBtn(Icons.chevron_left_rounded, _nextMonth),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 50.ms),

            const SizedBox(height: TvSpacing.md),

            // Weekday headers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TvSpacing.md),
              child: Row(
                children: [
                  for (final w in _faWeekdays)
                    Expanded(
                      child: Center(
                        child: Text(
                          w,
                          style: TvTypography.caption.copyWith(
                            color: context.inkSoft,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: TvSpacing.xs),

            // Calendar grid
            Expanded(
              child: asyncTasks.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Text(
                    'ارتباط برقرار نشد',
                    style: TvTypography.bodySmall.copyWith(
                      color: context.inkSoft,
                    ),
                  ),
                ),
                data: (tasks) {
                  final taskDays = <String>{};
                  for (final t in tasks) {
                    final d = t.dueDate ?? t.createdAt;
                    taskDays.add('${d.year}-${d.month}-${d.day}');
                  }
                  return _buildGrid(taskDays);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: context.brand),
    );
  }

  Widget _buildGrid(Set<String> taskDays) {
    final daysInMonth = _month.monthLength;
    // Jalali month starts on specific weekday. `weekDay` returns 1..7 where
    // 1=Saturday, 2=Sunday, ... 7=Friday (per shamsi_date docs).
    final firstWeekday = _month.weekDay; // 1..7
    final startOffset = firstWeekday - 1; // 0..6

    final totalCells = ((startOffset + daysInMonth + 6) ~/ 7) * 7;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TvSpacing.md),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalCells,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, i) {
          final dayIndex = i - startOffset + 1;
          if (dayIndex < 1 || dayIndex > daysInMonth) {
            return const SizedBox.shrink();
          }

          final jd = Jalali(_month.year, _month.month, dayIndex);
          final gd = jd.toDateTime();
          final isSelected =
              gd.year == _selectedDay.year &&
              gd.month == _selectedDay.month &&
              gd.day == _selectedDay.day;
          final isToday =
              gd.year == todayStart.year &&
              gd.month == todayStart.month &&
              gd.day == todayStart.day;
          final hasTasks = taskDays.contains(
            '${gd.year}-${gd.month}-${gd.day}',
          );

          return _DayCell(
            day: dayIndex,
            isSelected: isSelected,
            isToday: isToday,
            hasTasks: hasTasks,
            onTap: () => _selectDay(gd),
          );
        },
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

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasTasks,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool hasTasks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final accent = context.accent;

    final bg = isSelected
        ? brand
        : (isToday ? context.brandSoft : Colors.transparent);

    final fg = isSelected ? Colors.white : (isToday ? brand : context.ink);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              _fa(day.toString()),
              style: TvTypography.label.copyWith(
                color: fg,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (hasTasks && !isSelected)
              Positioned(
                bottom: 6,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isToday ? brand : accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
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
