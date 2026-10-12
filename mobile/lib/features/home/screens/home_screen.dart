import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/tv_bottom_nav.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_progress_ring.dart';
import '../../auth/providers/auth_provider.dart';
import '../../projects/models/project.dart';
import '../../projects/providers/projects_provider.dart';
import '../../projects/services/projects_api.dart';
import '../../tags/services/tags_api.dart';
import '../../tasks/models/task.dart' show TagBrief;
import '../../tasks/providers/tasks_provider.dart';
import '../../tasks/services/tasks_api.dart';
import '../../tasks/widgets/task_card.dart';
import '../../tasks/widgets/task_editor_sheet.dart';
import '../providers/progress_provider.dart';
import '../widgets/week_strip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;
  int _filterIndex = 0;

  static const List<String> _filters = ['همه', 'در جریان', 'انجام‌شده'];

  static const List<String> _jalaliMonths = [
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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final userName = (auth.user?.name ?? '').trim();
    final firstName = userName.isEmpty
        ? 'دوست من'
        : userName.split(RegExp(r'\s+')).first;

    final background = isDark ? TvColors.night : TvColors.sand;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Gradient header backdrop
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight < 700 ? 320 : 380,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [TvColors.brandPrimaryDeep, TvColors.night],
                      )
                    : const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          TvColors.brandPrimary,
                          TvColors.brandPrimaryDeep,
                        ],
                      ),
                borderRadius: const BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(36),
                  bottomEnd: Radius.circular(36),
                ),
              ),
            ),
          ),

          // Glow
          Positioned(
            top: -100,
            right: -80,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      TvColors.mint.withValues(alpha: isDark ? 0.14 : 0.20),
                      TvColors.mint.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: TvColors.brandPrimary,
              backgroundColor: isDark ? TvColors.nightSoft : TvColors.paper,
              onRefresh: _refreshDashboard,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      TvSpacing.md,
                      TvSpacing.sm,
                      TvSpacing.md,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHeader(firstName, isDark),
                        const SizedBox(height: TvSpacing.lg),
                        _buildProgressCard(isDark),
                        const SizedBox(height: TvSpacing.lg),
                        _buildWeekStripHeader(isDark),
                        const SizedBox(height: TvSpacing.sm),
                        const WeekStrip(),
                        const SizedBox(height: TvSpacing.lg),
                        _buildTaskSectionHeading(isDark),
                        const SizedBox(height: TvSpacing.md),
                        _buildFilters(isDark),
                        const SizedBox(height: TvSpacing.md),
                        _buildTaskList(isDark),
                        const SizedBox(height: 150),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: TvSpacing.md,
            right: TvSpacing.md,
            bottom: TvSpacing.md,
            child:
                TvBottomNav(
                      currentIndex: _tab,
                      onTap: (index) {
                        if (index == _tab) return;
                        TvHaptics.tap();
                        setState(() => _tab = index);
                      },
                      onFabTap: _openEditor,
                    )
                    .animate()
                    .fadeIn(duration: 450.ms)
                    .slideY(
                      begin: 0.18,
                      end: 0,
                      duration: 450.ms,
                      curve: Curves.easeOutCubic,
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshDashboard() async {
    TvHaptics.tap();
    ref.invalidate(dayTasksProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(allTasksProvider);
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader(String firstName, bool isDark) {
    return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_greetingIcon(), size: 17, color: TvColors.mint),
                      const SizedBox(width: TvSpacing.xs),
                      Text(
                        _greetingByTime(),
                        style: TvTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.76),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TvSpacing.xs),
                  Text(
                    firstName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TvTypography.headline.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: TvSpacing.xs),
                  Text(
                    'هر قدم کوچیک، یک رشد بزرگه.',
                    style: TvTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: TvSpacing.md),
            _buildGardenMark(),
          ],
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(
          begin: -0.025,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildGardenMark() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 9,
            right: 10,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: TvColors.sunGold,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Icon(Icons.spa_rounded, size: 31, color: TvColors.mint),
        ],
      ),
    );
  }

  IconData _greetingIcon() {
    final h = DateTime.now().hour;
    if (h < 12) return Icons.wb_sunny_outlined;
    if (h < 17) return Icons.wb_sunny_rounded;
    if (h < 20) return Icons.wb_twilight_rounded;
    return Icons.nightlight_round;
  }

  String _greetingByTime() {
    final h = DateTime.now().hour;
    if (h < 12) return 'صبح بخیر';
    if (h < 17) return 'ظهر بخیر';
    if (h < 20) return 'عصر بخیر';
    return 'شب بخیر';
  }

  // ---------------------------------------------------------------------------
  // Progress card
  // ---------------------------------------------------------------------------

  Widget _buildProgressCard(bool isDark) {
    final progress = ref.watch(progressProvider);
    final textColor = isDark ? Colors.white : TvColors.ink;
    final mutedColor = isDark ? TvColors.inkMuted : TvColors.inkSoft;

    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TvSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? TvColors.nightSoft : TvColors.paper,
            borderRadius: BorderRadius.circular(TvRadius.xl + 2),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : TvColors.brandPrimary.withValues(alpha: 0.09),
            ),
            boxShadow: [
              BoxShadow(
                color: TvColors.brandPrimary.withValues(
                  alpha: isDark ? 0.08 : 0.09,
                ),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'باغت چطور پیش می‌ره؟',
                          style: TvTypography.title.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: TvSpacing.xxs),
                        Text(
                          'رشدت رو قدم‌به‌قدم دنبال کن',
                          style: TvTypography.caption.copyWith(
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TvSpacing.sm,
                      vertical: TvSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: TvColors.mint.withValues(
                        alpha: isDark ? 0.13 : 0.18,
                      ),
                      borderRadius: BorderRadius.circular(TvRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.eco_rounded,
                          color: TvColors.brandPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: TvSpacing.xxs),
                        Text(
                          'سطح ${_fa(progress.level.toString())}',
                          style: TvTypography.caption.copyWith(
                            color: TvColors.brandPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TvSpacing.lg),

              Row(
                children: [
                  TvProgressRing(
                    todayRatio: progress.todayRatio,
                    weekRatio: progress.weekRatio,
                    size: 124,
                    innerStroke: 8,
                    outerStroke: 5,
                    innerTrack: isDark
                        ? TvColors.nightElevated
                        : TvColors.brandPrimarySoft,
                    outerTrack: isDark
                        ? TvColors.nightElevated
                        : TvColors.sunGoldSoft,
                  ),
                  const SizedBox(width: TvSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLegend(
                          color: TvColors.mint,
                          label: 'امروز',
                          value:
                              '${_fa(progress.todayDone.toString())} از ${_fa(progress.todayTotal.toString())}',
                          isDark: isDark,
                        ),
                        const SizedBox(height: TvSpacing.md),
                        _buildLegend(
                          color: TvColors.sunGold,
                          label: 'این هفته',
                          value:
                              '${_fa(progress.weekDone.toString())} از ${_fa(progress.weekTotal.toString())}',
                          isDark: isDark,
                        ),
                        const SizedBox(height: TvSpacing.lg),
                        _buildXpBar(
                          xp: progress.xp,
                          levelProgress: progress.levelProgress,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: TvSpacing.lg),
              Container(
                height: 1,
                color: (isDark ? Colors.white : TvColors.ink).withValues(
                  alpha: 0.08,
                ),
              ),
              const SizedBox(height: TvSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: _buildStat(
                      icon: Icons.eco_rounded,
                      value: _fa(progress.sprouts.toString()),
                      label: 'جوانه‌ها',
                      tint: TvColors.mint,
                      isDark: isDark,
                    ),
                  ),
                  _statDivider(isDark),
                  Expanded(
                    child: _buildStat(
                      icon: Icons.local_fire_department_rounded,
                      value: _fa(progress.streak.toString()),
                      label: 'روز متوالی',
                      tint: TvColors.sunGold,
                      isDark: isDark,
                    ),
                  ),
                  _statDivider(isDark),
                  Expanded(
                    child: _buildStat(
                      icon: Icons.check_circle_outline_rounded,
                      value: _fa(progress.todayDone.toString()),
                      label: 'انجام امروز',
                      tint: TvColors.sky,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 80.ms)
        .slideY(
          begin: 0.035,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildLegend({
    required Color color,
    required String label,
    required String value,
    required bool isDark,
  }) {
    final muted = isDark ? TvColors.inkMuted : TvColors.inkSoft;
    final text = isDark ? Colors.white : TvColors.ink;
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 7),
            ],
          ),
        ),
        const SizedBox(width: TvSpacing.xs),
        Text(label, style: TvTypography.bodySmall.copyWith(color: muted)),
        const Spacer(),
        Text(
          value,
          textDirection: TextDirection.rtl,
          style: TvTypography.label.copyWith(
            color: text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildXpBar({
    required int xp,
    required double levelProgress,
    required bool isDark,
  }) {
    final muted = isDark ? TvColors.inkMuted : TvColors.inkSoft;
    final v = levelProgress.clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt_rounded, size: 17, color: TvColors.sunGold),
            const SizedBox(width: TvSpacing.xxs),
            Text(
              'امتیاز تجربه',
              style: TvTypography.caption.copyWith(color: muted),
            ),
            const Spacer(),
            Text(
              _fa(xp.toString()),
              style: TvTypography.label.copyWith(
                color: isDark ? Colors.white : TvColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: TvSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(TvRadius.full),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: v),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: isDark
                  ? TvColors.nightElevated
                  : TvColors.brandPrimarySoft.withValues(alpha: 0.65),
              valueColor: const AlwaysStoppedAnimation(TvColors.mint),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color tint,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: isDark ? 0.12 : 0.17),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 19, color: tint),
        ),
        const SizedBox(height: TvSpacing.xs),
        Text(
          value,
          style: TvTypography.numericSmall.copyWith(
            color: isDark ? Colors.white : TvColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TvTypography.caption.copyWith(
            color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _statDivider(bool isDark) {
    return Container(
      width: 1,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: TvSpacing.xs),
      color: (isDark ? Colors.white : TvColors.ink).withValues(alpha: 0.08),
    );
  }

  // ---------------------------------------------------------------------------
  // Week strip header
  // ---------------------------------------------------------------------------

  Widget _buildWeekStripHeader(bool isDark) {
    final selected = ref.watch(selectedDayProvider);
    final j = Jalali.fromDateTime(selected);
    final monthName = (j.month >= 1 && j.month <= 12)
        ? _jalaliMonths[j.month]
        : '';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TvSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: TvColors.mint.withValues(alpha: isDark ? 0.15 : 0.22),
            borderRadius: BorderRadius.circular(TvRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: TvColors.brandPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                '${_fa(j.day.toString())} $monthName',
                style: TvTypography.caption.copyWith(
                  color: TvColors.brandPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () {
            TvHaptics.tap();
            final now = DateTime.now();
            ref.read(selectedDayProvider.notifier).state = DateTime(
              now.year,
              now.month,
              now.day,
            );
          },
          icon: const Icon(Icons.today_rounded, size: 16),
          label: const Text('امروز'),
          style: TextButton.styleFrom(
            foregroundColor: TvColors.brandPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: TvSpacing.sm,
              vertical: 2,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms, delay: 100.ms);
  }

  // ---------------------------------------------------------------------------
  // Task section heading + filters + list
  // ---------------------------------------------------------------------------

  Widget _buildTaskSectionHeading(bool isDark) {
    final text = isDark ? Colors.white : TvColors.ink;
    final muted = isDark ? TvColors.inkMuted : TvColors.inkSoft;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'کارهای این روز',
                style: TvTypography.headline.copyWith(
                  color: text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: TvSpacing.xxs),
              Text(
                'با یک قدم کوچیک شروع کن',
                style: TvTypography.bodySmall.copyWith(color: muted),
              ),
            ],
          ),
        ),
        Material(
          color: TvColors.brandPrimary,
          borderRadius: BorderRadius.circular(TvRadius.full),
          child: InkWell(
            borderRadius: BorderRadius.circular(TvRadius.full),
            onTap: _openEditor,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TvSpacing.md,
                vertical: TvSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 19),
                  const SizedBox(width: TvSpacing.xs),
                  Text(
                    'تسک تازه',
                    style: TvTypography.label.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms, delay: 100.ms);
  }

  Widget _buildFilters(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (var i = 0; i < _filters.length; i++) ...[
            if (i > 0) const SizedBox(width: TvSpacing.xs),
            _buildFilterChip(
              label: _filters[i],
              selected: _filterIndex == i,
              isDark: isDark,
              onTap: () {
                if (_filterIndex == i) return;
                TvHaptics.tap();
                setState(() => _filterIndex = i);
              },
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 150.ms);
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final fg = selected
        ? Colors.white
        : (isDark ? TvColors.inkMuted : TvColors.inkSoft);

    return Material(
      color: selected
          ? TvColors.brandPrimary
          : (isDark ? TvColors.nightSoft : TvColors.paper),
      borderRadius: BorderRadius.circular(TvRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TvRadius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: TvSpacing.md,
            vertical: TvSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TvRadius.full),
            border: Border.all(
              color: selected
                  ? TvColors.mint.withValues(alpha: 0.35)
                  : (isDark ? Colors.white : TvColors.ink).withValues(
                      alpha: 0.07,
                    ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check_rounded, size: 15, color: TvColors.mint),
                const SizedBox(width: TvSpacing.xs),
              ],
              Text(
                label,
                style: TvTypography.label.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(bool isDark) {
    final asyncTasks = ref.watch(dayTasksProvider);

    return asyncTasks.when(
      loading: () => _buildLoadingState(isDark),
      error: (_, __) => _buildErrorState(isDark),
      data: (tasks) {
        final filtered = switch (_filterIndex) {
          1 => tasks.where((t) => !t.isDone).toList(),
          2 => tasks.where((t) => t.isDone).toList(),
          _ => tasks,
        };

        if (filtered.isEmpty) return _buildEmptyState(isDark);

        return Column(
          children: [
            for (final t in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: TvSpacing.sm),
                child: TaskCard(
                  key: ValueKey(t.id),
                  task: t,
                  onToggleDone: () async {
                    final newStatus = t.isDone ? 'todo' : 'done';
                    try {
                      await TasksApi.instance.setStatus(t.id, newStatus);
                    } catch (_) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تغییر وضعیت انجام نشد. دوباره تلاش کن.',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: TvColors.rose,
                          ),
                        );
                      }
                      return;
                    }
                    if (!mounted) return;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      ref.invalidate(dayTasksProvider);
                      ref.invalidate(todayTasksProvider);
                      ref.invalidate(allTasksProvider);
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
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TvSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: TvColors.mint.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: TvColors.brandPrimary,
              ),
            ),
          ),
          const SizedBox(height: TvSpacing.md),
          Text(
            'داریم باغت رو مرتب می‌کنیم…',
            style: TvTypography.bodySmall.copyWith(
              color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return _buildMessageSurface(
      isDark: isDark,
      icon: Icons.cloud_off_rounded,
      iconColor: TvColors.rose,
      title: 'ارتباط با باغ برقرار نشد',
      message: 'اتصال رو بررسی کن و دوباره امتحان کن.',
      action: TvButton(
        label: 'تلاش دوباره',
        icon: Icons.refresh_rounded,
        variant: TvButtonVariant.secondary,
        expand: false,
        onPressed: () {
          TvHaptics.tap();
          ref.invalidate(dayTasksProvider);
          ref.invalidate(todayTasksProvider);
          ref.invalidate(allTasksProvider);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final isAll = _filterIndex == 0;
    final isDone = _filterIndex == 2;

    final title = isAll
        ? 'باغت آماده‌ی کاشت است'
        : isDone
        ? 'هنوز کاری کامل نشده'
        : 'همه‌چیز رو به راهه';

    final message = isAll
        ? 'یه کار کوچیک تعریف کن و اولین جوانه‌ی مسیرت رو بکار.'
        : isDone
        ? 'وقتی اولین کارت رو انجام بدی، اینجا می‌بینیش.'
        : 'فعلاً کاری در جریان نیست؛ می‌تونی کمی استراحت کنی یا کار تازه‌ای بسازی.';

    return _buildMessageSurface(
          isDark: isDark,
          icon: isAll
              ? Icons.spa_rounded
              : isDone
              ? Icons.park_rounded
              : Icons.self_improvement_rounded,
          iconColor: TvColors.brandPrimary,
          title: title,
          message: message,
          action: (isAll || !isDone)
              ? TvButton(
                  label: isAll ? 'ساخت اولین تسک' : 'ساخت تسک تازه',
                  icon: Icons.add_rounded,
                  onPressed: _openEditor,
                )
              : null,
          showDecorativeDots: true,
        )
        .animate()
        .fadeIn(duration: 450.ms, delay: 100.ms)
        .slideY(
          begin: 0.025,
          end: 0,
          duration: 450.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildMessageSurface({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    Widget? action,
    bool showDecorativeDots = false,
  }) {
    final titleColor = isDark ? Colors.white : TvColors.ink;
    final msgColor = isDark ? TvColors.inkMuted : TvColors.inkSoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TvSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? TvColors.nightSoft : TvColors.paper,
        borderRadius: BorderRadius.circular(TvRadius.xl),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : TvColors.brandPrimary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: TvColors.brandPrimary.withValues(
              alpha: isDark ? 0.04 : 0.06,
            ),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 116,
            height: 104,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        TvColors.mint.withValues(alpha: isDark ? 0.15 : 0.24),
                        TvColors.mint.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                if (showDecorativeDots) ...[
                  const Positioned(
                    top: 10,
                    right: 15,
                    child: _AccentDot(color: TvColors.sunGold, size: 7),
                  ),
                  const Positioned(
                    left: 11,
                    top: 31,
                    child: _AccentDot(color: TvColors.rose, size: 6),
                  ),
                  const Positioned(
                    right: 11,
                    bottom: 15,
                    child: _AccentDot(color: TvColors.sky, size: 7),
                  ),
                ],
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [TvColors.nightElevated, TvColors.brandPrimaryDeep]
                          : [TvColors.brandPrimarySoft, TvColors.mintSoft],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: TvColors.mint.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? TvColors.mint : iconColor,
                    size: 34,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TvSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TvTypography.title.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TvSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TvTypography.bodySmall.copyWith(
                color: msgColor,
                height: 1.8,
              ),
            ),
          ),
          if (action != null) ...[const SizedBox(height: TvSpacing.lg), action],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _openEditor() {
    TvHaptics.tap();

    final projects = ref.read(projectsProvider).value ?? const <Project>[];
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

  String _fa(String value) {
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return value.split('').map((c) {
      final d = int.tryParse(c);
      return d == null ? c : fa[d];
    }).join();
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 9,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
