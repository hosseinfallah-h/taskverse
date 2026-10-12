import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/haptics.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/tv_bottom_nav.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_card.dart';
import '../../../shared/widgets/tv_progress_ring.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tasks/models/task.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../../tasks/services/tasks_api.dart';
import '../../tasks/widgets/task_card.dart';
import '../../tasks/widgets/task_editor_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;
  int _filterIndex = 0;

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
    final headerHeight =
        MediaQuery.sizeOf(context).height < 700 ? 300.0 : 340.0;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Gradient header backdrop
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
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

          // Scrollable content with pull-to-refresh
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: TvColors.brandPrimary,
              backgroundColor:
                  isDark ? TvColors.nightSoft : TvColors.paper,
              strokeWidth: 2.5,
              onRefresh: () async {
                TvHaptics.tap();
                ref.invalidate(todayTasksProvider);
                ref.invalidate(allTasksProvider);
                await Future<void>.delayed(
                  const Duration(milliseconds: 400),
                );
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      TvSpacing.md,
                      TvSpacing.md,
                      TvSpacing.md,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _header(firstName, isDark),
                        const SizedBox(height: TvSpacing.xl),
                        _sectionHeading(
                          eyebrow: 'GARDEN OVERVIEW',
                          title: 'باغ امروزت',
                          subtitle: 'قدم‌های کوچک، نتیجه‌های بزرگ',
                          isDark: isDark,
                        ),
                        const SizedBox(height: TvSpacing.md),
                        _heroCard(isDark),
                        const SizedBox(height: TvSpacing.xl),
                        _taskSectionHeading(isDark),
                        const SizedBox(height: TvSpacing.md),
                        _filterRow(isDark),
                        const SizedBox(height: TvSpacing.md),
                        _taskListOrEmpty(isDark),
                        const SizedBox(height: 132),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating pill nav
          Positioned(
            left: TvSpacing.md,
            right: TvSpacing.md,
            bottom: TvSpacing.md,
            child: TvBottomNav(
              currentIndex: _tab,
              onTap: (index) {
                if (index == _tab) return;
                TvHaptics.tap();
                setState(() => _tab = index);
              },
              onFabTap: _showAddTaskSheet,
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(
                  begin: 0.25,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
        ],
      ),
    );
  }

  // ---------- Header ----------

  Widget _header(String firstName, bool isDark) {
    final foreground = isDark ? Colors.white : TvColors.ink;
    final muted = isDark ? TvColors.inkMuted : TvColors.inkSoft;

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      TvColors.brandPrimary,
                      TvColors.brandPrimaryDeep,
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, TvColors.brandPrimarySoft],
                  ),
            border: Border.all(
              color: TvColors.brandPrimary.withValues(alpha: 0.12),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color:
                          TvColors.brandPrimary.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              firstName.characters.first,
              style: TvTypography.title.copyWith(
                color: isDark ? Colors.white : TvColors.brandPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: TvSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'صبح بخیر',
                style: TvTypography.caption.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TvTypography.title.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: TvSpacing.sm),
        Material(
          color: isDark ? TvColors.nightElevated : Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => TvHaptics.tap(),
            child: SizedBox(
              width: 46,
              height: 46,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 24,
                    color: muted,
                  ),
                  Positioned(
                    top: 11,
                    right: 12,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: TvColors.rose,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.035, end: 0, duration: 400.ms);
  }

  // ---------- Section headings ----------

  Widget _sectionHeading({
    required String eyebrow,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 2,
              decoration: BoxDecoration(
                color: TvColors.mint,
                borderRadius: BorderRadius.circular(TvRadius.full),
              ),
            ),
            const SizedBox(width: TvSpacing.xs),
            Text(
              eyebrow,
              style: TvTypography.caption.copyWith(
                color: isDark ? TvColors.mint : TvColors.brandPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: TvSpacing.xs),
        Text(
          title,
          style: TvTypography.headline.copyWith(
            color: isDark ? Colors.white : TvColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TvTypography.bodySmall.copyWith(
            color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 60.ms);
  }

  Widget _taskSectionHeading(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مراقبت از باغ',
                style: TvTypography.headline.copyWith(
                  color: isDark ? Colors.white : TvColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'تسک‌هایت را با آرامش مدیریت کن',
                style: TvTypography.bodySmall.copyWith(
                  color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
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
            color: isDark
                ? TvColors.nightElevated
                : TvColors.brandPrimarySoft,
            borderRadius: BorderRadius.circular(TvRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 15,
                color: isDark ? TvColors.mint : TvColors.brandPrimary,
              ),
              const SizedBox(width: TvSpacing.xxs),
              Text(
                '۰ تسک',
                style: TvTypography.caption.copyWith(
                  color: isDark ? TvColors.mint : TvColors.brandPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  // ---------- Hero card ----------

  Widget _heroCard(bool isDark) {
    return TvCard(
      elevated: true,
      padding: const EdgeInsets.all(TvSpacing.lg),
      borderRadius: TvRadius.xl,
      color: isDark ? TvColors.nightSoft : TvColors.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TvProgressRing(
                value: 0,
                size: 92,
                strokeWidth: 8,
                label: 'امروز',
              ),
              const SizedBox(width: TvSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'پیشرفت روزانه',
                      style: TvTypography.caption.copyWith(
                        color: isDark
                            ? TvColors.inkMuted
                            : TvColors.inkSoft,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: TvSpacing.xxs),
                    Text(
                      'شروع یک روز تازه',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TvTypography.title.copyWith(
                        color: isDark ? Colors.white : TvColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: TvSpacing.xxs),
                    Text(
                      'هنوز تسکی برای امروز ثبت نشده',
                      style: TvTypography.bodySmall.copyWith(
                        color: isDark
                            ? TvColors.inkMuted
                            : TvColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TvSpacing.lg),
          Container(
            height: 1,
            color: (isDark ? Colors.white : TvColors.ink)
                .withValues(alpha: 0.07),
          ),
          const SizedBox(height: TvSpacing.md),
          Row(
            children: [
              Expanded(
                child: _statItem(
                  icon: Icons.eco_rounded,
                  label: 'جوانه‌ها',
                  value: '۰',
                  tint: TvColors.mint,
                  isDark: isDark,
                ),
              ),
              _statDivider(isDark),
              Expanded(
                child: _statItem(
                  icon: Icons.bolt_rounded,
                  label: 'امتیاز XP',
                  value: '۰',
                  tint: TvColors.sunGold,
                  isDark: isDark,
                ),
              ),
              _statDivider(isDark),
              Expanded(
                child: _statItem(
                  icon: Icons.local_fire_department_rounded,
                  label: 'روزهای متوالی',
                  value: '۰',
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
        .fadeIn(duration: 500.ms, delay: 100.ms)
        .slideY(begin: 0.045, end: 0, duration: 500.ms);
  }

  Widget _statItem({
    required IconData icon,
    required String label,
    required String value,
    required Color tint,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: tint, size: 19),
        const SizedBox(height: TvSpacing.xxs),
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
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _statDivider(bool isDark) {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: TvSpacing.xs),
      color: (isDark ? Colors.white : TvColors.ink).withValues(alpha: 0.08),
    );
  }

  // ---------- Filters ----------

  Widget _filterRow(bool isDark) {
    final filters = ['انجام‌نشده', 'فعال', 'انجام‌شده'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (var i = 0; i < filters.length; i++) ...[
            if (i > 0) const SizedBox(width: TvSpacing.xs),
            _filterChip(
              filters[i],
              0,
              selected: _filterIndex == i,
              isDark: isDark,
              onTap: () {
                TvHaptics.tap();
                setState(() => _filterIndex = i);
              },
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _filterChip(
    String label,
    int count, {
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final foreground = selected
        ? (isDark ? TvColors.mint : TvColors.brandPrimary)
        : (isDark ? TvColors.inkMuted : TvColors.inkSoft);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: TvSpacing.md,
          vertical: TvSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? TvColors.nightElevated : Colors.white)
              : (isDark ? TvColors.nightSoft : TvColors.paper),
          borderRadius: BorderRadius.circular(TvRadius.full),
          border: Border.all(
            color: selected
                ? TvColors.brandPrimary.withValues(alpha: 0.24)
                : (isDark ? Colors.white : TvColors.ink)
                    .withValues(alpha: 0.045),
          ),
          boxShadow: selected && !isDark
              ? [
                  BoxShadow(
                    color:
                        TvColors.brandPrimary.withValues(alpha: 0.055),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TvTypography.label.copyWith(
                color: foreground,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: TvSpacing.xs),
            Container(
              constraints: const BoxConstraints(minWidth: 22),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? TvColors.brandPrimarySoft
                    : (isDark
                        ? TvColors.nightElevated
                        : TvColors.sandDeep),
                borderRadius: BorderRadius.circular(TvRadius.full),
              ),
              child: Text(
                _fa(count),
                textAlign: TextAlign.center,
                style: TvTypography.caption.copyWith(
                  color: TvColors.brandPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Task list / empty ----------

  Widget _taskListOrEmpty(bool isDark) {
    final async = ref.watch(todayTasksProvider);

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: TvSpacing.xl),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: TvColors.mint,
            ),
          ),
        ),
      ),
      error: (e, _) => _errorState(isDark),
      data: (tasks) {
        if (tasks.isEmpty) return _emptyState(isDark);
        return Column(
          children: [
            for (final t in tasks)
              TaskCard(
                key: ValueKey(t.id),
                task: t,
                onToggleDone: () async {
                  final newStatus = t.isDone ? 'todo' : 'done';
                  try {
                    await TasksApi.instance.setStatus(t.id, newStatus);
                  } catch (e) {
                    // ignore: avoid_print
                    print('=== TOGGLE FAIL: $e ===');
                  }
                  ref.invalidate(todayTasksProvider);
                },
                onTap: () {
                  TvHaptics.tap();
                  context.push('/task', extra: t);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _errorState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TvSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
          ),
          const SizedBox(height: TvSpacing.md),
          Text(
            'اتصال به باغ برقرار نشد',
            style: TvTypography.title.copyWith(
              color: isDark ? Colors.white : TvColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TvSpacing.xs),
          Text(
            'اینترنت یا سرور رو بررسی کن و دوباره تلاش کن',
            textAlign: TextAlign.center,
            style: TvTypography.bodySmall.copyWith(
              color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
            ),
          ),
          const SizedBox(height: TvSpacing.lg),
          TvButton(
            label: 'تلاش دوباره',
            icon: Icons.refresh_rounded,
            variant: TvButtonVariant.secondary,
            expand: false,
            onPressed: () {
              TvHaptics.tap();
              ref.invalidate(todayTasksProvider);
              ref.invalidate(allTasksProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyState(bool isDark) {
    final cardColor = isDark ? TvColors.nightSoft : TvColors.paper;
    final textColor = isDark ? Colors.white : TvColors.ink;
    final mutedColor = isDark ? TvColors.inkMuted : TvColors.inkSoft;

    return TvCard(
      padding: const EdgeInsets.fromLTRB(
        TvSpacing.lg,
        TvSpacing.xl,
        TvSpacing.lg,
        TvSpacing.lg,
      ),
      borderRadius: TvRadius.xl,
      color: cardColor,
      child: Column(
        children: [
          SizedBox(
            width: 148,
            height: 132,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        TvColors.mint
                            .withValues(alpha: isDark ? 0.18 : 0.24),
                        TvColors.mint.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 24,
                  child:
                      _decorativeDot(color: TvColors.sunGold, size: 8),
                ),
                Positioned(
                  left: 18,
                  top: 35,
                  child: _decorativeDot(color: TvColors.rose, size: 6),
                ),
                Positioned(
                  right: 16,
                  bottom: 23,
                  child: _decorativeDot(color: TvColors.sky, size: 7),
                ),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: isDark
                        ? TvColors.nightElevated
                        : TvColors.brandPrimarySoft,
                    borderRadius: BorderRadius.circular(27),
                    border: Border.all(
                      color: TvColors.mint.withValues(alpha: 0.22),
                    ),
                  ),
                  child: const Icon(
                    Icons.spa_rounded,
                    size: 39,
                    color: TvColors.brandPrimary,
                  ),
                )
                    .animate(
                      onPlay: (c) => c.repeat(reverse: true),
                    )
                    .moveY(
                      begin: 0,
                      end: -4,
                      duration: 1800.ms,
                      curve: Curves.easeInOut,
                    ),
              ],
            ),
          ),
          const SizedBox(height: TvSpacing.md),
          Text(
            'باغت آماده‌ی کاشت است',
            textAlign: TextAlign.center,
            style: TvTypography.title.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TvSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              'یه تسک کوچیک بساز و اولین جوانه‌ی مسیرت رو ببین.',
              textAlign: TextAlign.center,
              style: TvTypography.bodySmall.copyWith(
                color: mutedColor,
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(height: TvSpacing.lg),
          TvButton(
            label: 'ساخت اولین تسک',
            icon: Icons.add_rounded,
            onPressed: _showAddTaskSheet,
          ),
          const SizedBox(height: TvSpacing.sm),
          Text(
            'هر تغییر بزرگ، از یک قدم کوچک شروع می‌شه.',
            textAlign: TextAlign.center,
            style: TvTypography.caption.copyWith(
              color: mutedColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 250.ms)
        .slideY(begin: 0.045, end: 0, duration: 500.ms);
  }

  Widget _decorativeDot({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.24),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  // ---------- Helpers ----------

  void _showAddTaskSheet() {
    TvHaptics.tap();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TaskEditorSheet(),
    );
  }

  String _fa(int number) {
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return number.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d == null ? c : fa[d];
    }).join();
  }
}