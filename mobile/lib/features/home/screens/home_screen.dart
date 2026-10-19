import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../tasks/widgets/confirm_toggle_sheet.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/haptics.dart';
import '../../../core/theme/seasons/season_provider.dart';
import '../../../core/theme/seasons/tv_season.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/theme_ext.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_progress_ring.dart';
import '../../auth/providers/auth_provider.dart';
import '../../projects/models/project.dart';
import '../../projects/providers/projects_provider.dart';
import '../../projects/services/projects_api.dart';
import '../../tags/services/tags_api.dart';
import '../../tasks/models/task.dart' show TagBrief, Task;
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

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
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

  final Map<int, String> _optimisticStatus = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(dayTasksProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(allTasksProvider);
      ref.invalidate(projectsProvider);
      ref.invalidate(tagsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isDark = context.isDark;
    final bg = context.bg;
    final palette = ref.watch(activePaletteProvider);

    final userName = (auth.user?.name ?? '').trim();
    final firstName = userName.isEmpty
        ? 'دوست من'
        : userName.split(RegExp(r'\s+')).first;

    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Season gradient header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight < 700 ? 320 : 380,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: palette.headerGradient,
                borderRadius: const BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(36),
                  bottomEnd: Radius.circular(36),
                ),
              ),
            ),
          ),

          // Soft accent glow
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
                      palette.heroGlow.withValues(
                        alpha: isDark ? 0.14 : 0.28,
                      ),
                      palette.heroGlow.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: palette.brandPrimary,
              backgroundColor: context.surface,
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
                        const SizedBox(height: 160),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshDashboard() async {
    TvHaptics.tap();
    _optimisticStatus.clear();
    ref.invalidate(dayTasksProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(allTasksProvider);
    await Future<void>.delayed(const Duration(milliseconds: 300));
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
                  Icon(
                    _greetingIcon(),
                    size: 17,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: TvSpacing.xs),
                  Text(
                    _greetingByTime(),
                    style: TvTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.86),
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
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TvSpacing.xs),
              Text(
                'هر قدم کوچیک، یک رشد بزرگه.',
                style: TvTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
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
    final season = ref.watch(activeSeasonProvider);
    return GestureDetector(
      onTap: () => _showSeasonPicker(season),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
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
            Icon(season.icon, size: 31, color: Colors.white),
          ],
        ),
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
    final textColor = context.ink;
    final mutedColor = context.inkSoft;
    final brand = context.brand;
    final accent = context.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TvSpacing.lg),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(TvRadius.xl + 2),
        border: Border.all(color: brand.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: brand.withValues(alpha: 0.10),
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
                      style: TvTypography.caption
                          .copyWith(color: mutedColor),
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
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(TvRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.eco_rounded, color: brand, size: 16),
                    const SizedBox(width: TvSpacing.xxs),
                    Text(
                      'سطح ${_fa(progress.level.toString())}',
                      style: TvTypography.caption.copyWith(
                        color: brand,
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
                todayColor: accent,
                weekColor: TvColors.sunGold,
                innerTrack: isDark
                    ? TvColors.nightElevated
                    : context.brandSoft,
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
                      color: accent,
                      label: 'امروز',
                      value:
                          '${_fa(progress.todayDone.toString())} از ${_fa(progress.todayTotal.toString())}',
                    ),
                    const SizedBox(height: TvSpacing.md),
                    _buildLegend(
                      color: TvColors.sunGold,
                      label: 'این هفته',
                      value:
                          '${_fa(progress.weekDone.toString())} از ${_fa(progress.weekTotal.toString())}',
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
          Container(height: 1, color: context.ink.withValues(alpha: 0.08)),
          const SizedBox(height: TvSpacing.md),

          Row(
            children: [
              Expanded(
                child: _buildStat(
                  icon: Icons.eco_rounded,
                  value: _fa(progress.sprouts.toString()),
                  label: 'جوانه‌ها',
                  tint: accent,
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
  }) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.30),
                blurRadius: 7,
              ),
            ],
          ),
        ),
        const SizedBox(width: TvSpacing.xs),
        Text(
          label,
          style: TvTypography.bodySmall.copyWith(
            color: context.inkSoft,
          ),
        ),
        const Spacer(),
        Text(
          value,
          textDirection: TextDirection.rtl,
          style: TvTypography.label.copyWith(
            color: context.ink,
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
    final v = levelProgress.clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.bolt_rounded,
              size: 17,
              color: TvColors.sunGold,
            ),
            const SizedBox(width: TvSpacing.xxs),
            Text(
              'امتیاز تجربه',
              style: TvTypography.caption.copyWith(
                color: context.inkSoft,
              ),
            ),
            const Spacer(),
            Text(
              _fa(xp.toString()),
              style: TvTypography.label.copyWith(
                color: context.ink,
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
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: isDark
                  ? TvColors.nightElevated
                  : context.brandSoft,
              valueColor: AlwaysStoppedAnimation(context.accent),
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
            color: tint.withValues(alpha: isDark ? 0.12 : 0.18),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 19, color: tint),
        ),
        const SizedBox(height: TvSpacing.xs),
        Text(
          value,
          style: TvTypography.numericSmall.copyWith(color: context.ink),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TvTypography.caption.copyWith(
            color: context.inkSoft,
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
      color: context.ink.withValues(alpha: 0.08),
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
    final brand = context.brand;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TvSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: context.accentSoft,
            borderRadius: BorderRadius.circular(TvRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: brand),
              const SizedBox(width: 6),
              Text(
                '${_fa(j.day.toString())} $monthName',
                style: TvTypography.caption.copyWith(
                  color: brand,
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
          style: TextButton.styleFrom(foregroundColor: brand),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms, delay: 100.ms);
  }

  // ---------------------------------------------------------------------------
  // Task section heading + filters + list
  // ---------------------------------------------------------------------------

  Widget _buildTaskSectionHeading(bool isDark) {
    final brand = context.brand;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'کارهای این روز',
                style: TvTypography.headline.copyWith(
                  color: context.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: TvSpacing.xxs),
              Text(
                'با یک قدم کوچیک شروع کن',
                style: TvTypography.bodySmall.copyWith(
                  color: context.inkSoft,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: brand,
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
                  const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
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
    final brand = context.brand;
    final fg = selected ? Colors.white : context.inkSoft;

    return Material(
      color: selected ? brand : context.surface,
      borderRadius: BorderRadius.circular(TvRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TvRadius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: TvSpacing.md,
            vertical: TvSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TvRadius.full),
            border: Border.all(
              color: selected
                  ? context.accent.withValues(alpha: 0.4)
                  : context.ink.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(
                  Icons.check_rounded,
                  size: 15,
                  color: context.accentSoft,
                ),
                const SizedBox(width: TvSpacing.xs),
              ],
              Text(
                label,
                style: TvTypography.label.copyWith(
                  color: fg,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
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
      data: (rawTasks) {
        final tasks = rawTasks.map((t) {
          final override = _optimisticStatus[t.id];
          if (override == null || override == t.status) return t;
          return t.copyWithStatus(override);
        }).toList();

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
                  key: ValueKey('${t.id}-${t.status}'),
                  task: t,
                  onToggleRequested: () async {
                    final confirmed =
                        await showConfirmToggleSheet(context, task: t);
                    if (!mounted || !confirmed) return;
                    // One extra frame to ensure sheet teardown is done.
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) {
                      if (!mounted) return;
                      _optimisticToggle(t);
                    });
                  },
                  onTap: () async {
                    TvHaptics.tap();
                    await context.push('/task', extra: t);
                    if (!mounted) return;
                    ref.invalidate(dayTasksProvider);
                    ref.invalidate(todayTasksProvider);
                    ref.invalidate(allTasksProvider);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _optimisticToggle(Task t) async {
    final newStatus = t.isDone ? 'todo' : 'done';
    setState(() => _optimisticStatus[t.id] = newStatus);

    try {
      await TasksApi.instance.setStatus(t.id, newStatus);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() => _optimisticStatus.remove(t.id));
      ref.invalidate(dayTasksProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(allTasksProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() => _optimisticStatus.remove(t.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تغییر وضعیت انجام نشد'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: TvColors.rose,
        ),
      );
    }
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
              color: context.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: context.brand,
              ),
            ),
          ),
          const SizedBox(height: TvSpacing.md),
          Text(
            'داریم باغت رو مرتب می‌کنیم…',
            style: TvTypography.bodySmall.copyWith(
              color: context.inkSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return _buildMessageSurface(
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
      icon: isAll
          ? Icons.spa_rounded
          : isDone
              ? Icons.park_rounded
              : Icons.self_improvement_rounded,
      iconColor: context.brand,
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
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    Widget? action,
    bool showDecorativeDots = false,
  }) {
    final brand = context.brand;
    final accent = context.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TvSpacing.lg),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(TvRadius.xl),
        border: Border.all(color: brand.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: brand.withValues(alpha: 0.06),
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
                        accent.withValues(alpha: 0.24),
                        accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                if (showDecorativeDots) ...[
                  const Positioned(
                    top: 10,
                    right: 15,
                    child: _AccentDot(
                      color: TvColors.sunGold,
                      size: 7,
                    ),
                  ),
                  const Positioned(
                    left: 11,
                    top: 31,
                    child: _AccentDot(
                      color: TvColors.rose,
                      size: 6,
                    ),
                  ),
                  const Positioned(
                    right: 11,
                    bottom: 15,
                    child: _AccentDot(
                      color: TvColors.sky,
                      size: 7,
                    ),
                  ),
                ],
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: context.brandSoft,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(icon, color: brand, size: 34),
                ),
              ],
            ),
          ),
          const SizedBox(height: TvSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TvTypography.title.copyWith(
              color: context.ink,
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
                color: context.inkSoft,
                height: 1.8,
              ),
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: TvSpacing.lg),
            action,
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Season picker
  // ---------------------------------------------------------------------------

  Future<void> _showSeasonPicker(TvSeason current) async {
    TvHaptics.tap();
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(TvRadius.xl),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              TvSpacing.lg,
              TvSpacing.md,
              TvSpacing.lg,
              TvSpacing.xl,
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
                Text(
                  'فصل باغت',
                  textAlign: TextAlign.right,
                  style: TvTypography.headline.copyWith(
                    color: context.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: TvSpacing.xs),
                Text(
                  'رنگ‌بندی اپ با فصل عوض می‌شه',
                  textAlign: TextAlign.right,
                  style: TvTypography.bodySmall.copyWith(
                    color: context.inkSoft,
                  ),
                ),
                const SizedBox(height: TvSpacing.lg),
                for (final s in TvSeason.values)
                  _seasonTile(s, current: current),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _seasonTile(TvSeason s, {required TvSeason current}) {
    final selected = s == current;
    final palette = TvSeasonPalette.of(s);

    return Padding(
      padding: const EdgeInsets.only(bottom: TvSpacing.sm),
      child: GestureDetector(
        onTap: () {
          TvHaptics.tap();
          ref.read(seasonOverrideProvider.notifier).state = s;
          Navigator.of(context).pop();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(TvSpacing.md),
          decoration: BoxDecoration(
            color: selected ? palette.brandPrimarySoft : context.bg,
            borderRadius: BorderRadius.circular(TvRadius.lg),
            border: Border.all(
              color: selected
                  ? palette.brandPrimary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: palette.headerGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(s.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: TvSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.faLabel,
                      style: TvTypography.title.copyWith(
                        color: context.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.faTagline,
                      style: TvTypography.caption.copyWith(
                        color: context.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: palette.brandPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

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