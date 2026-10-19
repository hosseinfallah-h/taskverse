import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../../tasks/widgets/confirm_toggle_sheet.dart';
import '../../tasks/services/tasks_api.dart';
import '../../../core/theme/theme_ext.dart';
import '../../../core/theme/typography.dart';
import '../../projects/models/project.dart';
import '../../projects/providers/projects_provider.dart';
import '../../projects/services/projects_api.dart';
import '../../tags/services/tags_api.dart';
import '../../tasks/models/task.dart' show TagBrief, Task;
import '../../tasks/providers/tasks_provider.dart';
import '../../tasks/widgets/task_card.dart';
import '../../tasks/widgets/task_editor_sheet.dart';
import 'package:go_router/go_router.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late Jalali _month;
  late DateTime _selectedDay;

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

  static const _faWeekdaysShort = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
  static const _faWeekdaysFull = [
    'شنبه',
    'یک‌شنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه',
  ];

  @override
  void initState() {
    super.initState();
    final now = Jalali.now();
    _month = Jalali(now.year, now.month, 1);
    final t = DateTime.now();
    _selectedDay = DateTime(t.year, t.month, t.day);
  }

  void _prevMonth() {
    TvHaptics.tap();
    final p = _month.addMonths(-1);
    setState(() => _month = Jalali(p.year, p.month, 1));
  }

  void _nextMonth() {
    TvHaptics.tap();
    final n = _month.addMonths(1);
    setState(() => _month = Jalali(n.year, n.month, 1));
  }

  void _jumpToToday() {
    TvHaptics.tap();
    final t = DateTime.now();
    final today = DateTime(t.year, t.month, t.day);
    final now = Jalali.now();
    setState(() {
      _selectedDay = today;
      _month = Jalali(now.year, now.month, 1);
    });
    ref.read(selectedDayProvider.notifier).state = today;
  }

  void _selectDay(DateTime d) {
    TvHaptics.tap();
    setState(() => _selectedDay = d);
    ref.read(selectedDayProvider.notifier).state = d;
  }

  void _openEditor() {
    TvHaptics.tap();

    final projects =
        ref.read(projectsProvider).value ?? const <Project>[];
    final tags = ref.read(tagsProvider).value ?? const <TagBrief>[];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskEditorSheet(
        initialProjects: projects,
        initialTags: tags,
        onCreateProject: (name) async {
          try {
            return await ProjectsApi.instance.create(name: name);
          } catch (_) {
            return null;
          }
        },
        onCreateTag: (name) async {
          try {
            return await TagsApi.instance.create(name: name);
          } catch (_) {
            return null;
          }
        },
        onSaved: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ref.invalidate(projectsProvider);
            ref.invalidate(tagsProvider);
            ref.invalidate(dayTasksProvider);
            ref.invalidate(todayTasksProvider);
            ref.invalidate(allTasksProvider);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final asyncTasks = ref.watch(allTasksProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: brand,
          backgroundColor: context.surface,
          onRefresh: () async {
            TvHaptics.tap();
            ref.invalidate(allTasksProvider);
            await Future<void>.delayed(
              const Duration(milliseconds: 300),
            );
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              TvSpacing.md,
              TvSpacing.lg,
              TvSpacing.md,
              160,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                const SizedBox(height: TvSpacing.lg),
                _monthCard(asyncTasks),
                const SizedBox(height: TvSpacing.lg),
                _dayTasksSection(asyncTasks),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
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
                'باغت رو در طول زمان ببین',
                style: TvTypography.bodySmall.copyWith(
                  color: context.inkSoft,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: context.brandSoft,
          borderRadius: BorderRadius.circular(TvRadius.full),
          child: InkWell(
            onTap: _jumpToToday,
            borderRadius: BorderRadius.circular(TvRadius.full),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TvSpacing.sm,
                vertical: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.today_rounded,
                    size: 16,
                    color: context.brand,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'امروز',
                    style: TvTypography.caption.copyWith(
                      color: context.brand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _monthCard(AsyncValue<List<Task>> asyncTasks) {
    final taskDays = <String>{};
    asyncTasks.whenData((tasks) {
      for (final t in tasks) {
        final d = t.dueDate ?? t.createdAt;
        taskDays.add('${d.year}-${d.month}-${d.day}');
      }
    });

    return Container(
      padding: const EdgeInsets.all(TvSpacing.md),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(TvRadius.xl),
        border: Border.all(
          color: context.brand.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: context.brand.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: context.brand,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_faMonths[_month.month]} ${_fa(_month.year.toString())}',
                    style: TvTypography.title.copyWith(
                      color: context.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: context.brand,
                ),
              ),
            ],
          ),
          const SizedBox(height: TvSpacing.sm),
          Row(
            children: [
              for (final w in _faWeekdaysShort)
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
          const SizedBox(height: TvSpacing.xs),
          _buildGrid(taskDays),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms, delay: 80.ms);
  }

  Widget _buildGrid(Set<String> taskDays) {
    final daysInMonth = _month.monthLength;
    final firstWeekday = _month.weekDay;
    final startOffset = firstWeekday - 1;
    final totalCells = ((startOffset + daysInMonth + 6) ~/ 7) * 7;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, i) {
        final dayIndex = i - startOffset + 1;
        if (dayIndex < 1 || dayIndex > daysInMonth) {
          return const SizedBox.shrink();
        }

        final jd = Jalali(_month.year, _month.month, dayIndex);
        final gd = jd.toDateTime();
        final isSelected = gd.year == _selectedDay.year &&
            gd.month == _selectedDay.month &&
            gd.day == _selectedDay.day;
        final isToday = gd.year == todayStart.year &&
            gd.month == todayStart.month &&
            gd.day == todayStart.day;
        final hasTasks =
            taskDays.contains('${gd.year}-${gd.month}-${gd.day}');

        return _DayCell(
          day: dayIndex,
          isSelected: isSelected,
          isToday: isToday,
          hasTasks: hasTasks,
          onTap: () => _selectDay(gd),
        );
      },
    );
  }

  Widget _dayTasksSection(AsyncValue<List<Task>> asyncTasks) {
    final j = Jalali.fromDateTime(_selectedDay);
    final weekdayName = _faWeekdaysFull[(j.weekDay - 1) % 7];
    final monthName = _faMonths[j.month];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تسک‌های $weekdayName',
                    style: TvTypography.headline.copyWith(
                      color: context.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${_fa(j.day.toString())} $monthName ${_fa(j.year.toString())}',
                    style: TvTypography.caption.copyWith(
                      color: context.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: context.brand,
              borderRadius: BorderRadius.circular(TvRadius.full),
              child: InkWell(
                borderRadius: BorderRadius.circular(TvRadius.full),
                onTap: _openEditor,
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: TvSpacing.md,
                    vertical: 8,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: TvSpacing.md),
        asyncTasks.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(TvSpacing.xl),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.all(TvSpacing.md),
            child: Text(
              'ارتباط برقرار نشد',
              textAlign: TextAlign.center,
              style: TvTypography.bodySmall.copyWith(
                color: context.inkSoft,
              ),
            ),
          ),
          data: (tasks) {
            final dayTasks = tasks.where((t) {
              final d = t.dueDate ?? t.createdAt;
              return d.year == _selectedDay.year &&
                  d.month == _selectedDay.month &&
                  d.day == _selectedDay.day;
            }).toList();

            if (dayTasks.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(TvSpacing.xl),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(TvRadius.xl),
                  border: Border.all(
                    color: context.brand.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 40,
                      color: context.brand,
                    ),
                    const SizedBox(height: TvSpacing.sm),
                    Text(
                      'این روز خالیه',
                      style: TvTypography.title.copyWith(
                        color: context.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'می‌تونی یه تسک تازه بسازی یا استراحت کنی.',
                      textAlign: TextAlign.center,
                      style: TvTypography.bodySmall.copyWith(
                        color: context.inkSoft,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                for (final t in dayTasks)
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: TvSpacing.sm),
                    child: TaskCard(
                      task: t,
                      onToggleRequested: () async {
                        final confirmed = await showConfirmToggleSheet(
                          context,
                          task: t,
                        );
                        if (!mounted || !confirmed) return;
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) async {
                          if (!mounted) return;
                          try {
                            await TasksApi.instance.setStatus(
                              t.id,
                              t.isDone ? 'todo' : 'done',
                            );
                          } catch (_) {}
                          if (!mounted) return;
                          ref.invalidate(allTasksProvider);
                          ref.invalidate(todayTasksProvider);
                          ref.invalidate(dayTasksProvider);
                        });
                      },
                      onTap: () {
                        TvHaptics.tap();
                        context.push('/task', extra: t);
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    ).animate().fadeIn(duration: 450.ms, delay: 150.ms);
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
    final fg = isSelected
        ? Colors.white
        : (isToday ? brand : context.ink);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              _fa(day.toString()),
              style: TvTypography.label.copyWith(
                color: fg,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (hasTasks && !isSelected)
              Positioned(
                bottom: 4,
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