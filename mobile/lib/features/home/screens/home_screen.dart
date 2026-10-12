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
import '../../../shared/widgets/tv_progress_ring.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tasks/models/task.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../../tasks/services/tasks_api.dart';
import '../../tasks/widgets/task_card.dart';
import '../../tasks/widgets/task_editor_sheet.dart';
import '../providers/progress_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;
  int _filterIndex = 0; // 0 = all, 1 = active, 2 = done

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userName = (auth.user?.name ?? '').trim();
    final firstName = userName.isEmpty
        ? 'دوست من'
        : userName.split(RegExp(r'\s+')).first;

    // 60/30/10: dominant background = sand, secondary = paper cards,
    // accent = mint/gold/mint pops.
    final background = isDark ? TvColors.night : TvColors.sand;
    final headerHeight =
        MediaQuery.sizeOf(context).height < 700 ? 320.0 : 360.0;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // ──── Layer 1: Gradient header (60% warm field)
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
                  bottomStart: Radius.circular(40),
                  bottomEnd: Radius.circular(40),
                ),
              ),
            ),
          ),

          // ──── Layer 2: Soft accent glow (depth)
          Positioned(
            top: -80,
            right: -60,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      TvColors.mint.withValues(alpha: isDark ? 0.10 : 0.22),
                      TvColors.mint.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ──── Layer 3: Content
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
                        const SizedBox(height: TvSpacing.lg),
                        _heroCard(isDark),
                        const SizedBox(height: TvSpacing.lg),
                        _sectionRow(
                          title: 'امروز',
                          subtitle: 'کارهای امروزت',
                          isDark: isDark,
                        ),
                        const SizedBox(height: TvSpacing.sm),
                        _filterRow(isDark),
                        const SizedBox(height: TvSpacing.sm),
                        _taskList(isDark),
                        const SizedBox(height: 140),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ──── Layer 4: Floating pill nav
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
              onFabTap: _openEditor,
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

  // ────────────────────────────────────────────────────────
  // Header
  // ────────────────────────────────────────────────────────

  Widget _header(String firstName, bool isDark) {
    final muted = isDark ? TvColors.inkMuted : TvColors.inkSoft;

    return Row(
      children: [
        // Avatar with ring
        Container(
          width: 54,
          height: 54,
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
              color: TvColors.mint.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: TvColors.mint.withValues(alpha: 0.20),
                blurRadius: 16,
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
                _greetingByTime(),
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
                  color: isDark ? Colors.white : TvColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
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
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: TvColors.rose,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: TvColors.rose.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
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

  String _greetingByTime() {
    final h = DateTime.now().hour;
    if (h < 12) return 'صبح بخیر';
    if (h < 17) return 'ظهر بخیر';
    if (h < 20) return 'عصر بخیر';
    return 'شب بخیر';
  }

  // ────────────────────────────────────────────────────────
  // Hero card (ring + stats) — WITH DEPTH
  // ────────────────────────────────────────────────────────

  Widget _heroCard(bool isDark) {
    final p = ref.watch(progressProvider);
    final cardColor = isDark ? TvColors.nightSoft : TvColors.paper;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TvRadius.xl + 4),
        boxShadow: isDark
            ? null
            : [
                // Layered depth: soft brand glow + tight edge
                BoxShadow(
                  color: TvColors.brandPrimary.withValues(alpha: 0.10),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: TvColors.brandPrimary.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Container(
        padding: const EdgeInsets.all(TvSpacing.lg),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(TvRadius.xl + 4),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : TvColors.brandPrimary.withValues(alpha: 0.08),
            width: 1,
          ),
          // Inner subtle gradient for depth
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    TvColors.nightSoft,
                    TvColors.nightSoft.withValues(alpha: 0.85),
                  ]
                : [
                    TvColors.paper,
                    TvColors.paper.withValues(alpha: 0.92),
                  ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank chip top-right
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TvSpacing.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(p.rankColor).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(TvRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p.rankEmoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        p.rankName,
                        style: TvTypography.caption.copyWith(
                          color: Color(p.rankColor),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'سطح ${_fa(p.level.toString())}',
                  style: TvTypography.caption.copyWith(
                    color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TvSpacing.md),

            // Ring + side stats
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TvProgressRing(
                  todayRatio: p.todayRatio,
                  weekRatio: p.weekRatio,
                  size: 130,
                  innerStroke: 9,
                  outerStroke: 6,
                  innerTrack: isDark
                      ? TvColors.nightElevated
                      : TvColors.brandPrimarySoft,
                  outerTrack: isDark
                      ? TvColors.nightElevated
                      : TvColors.sunGoldSoft,
                ),
                const SizedBox(width: TvSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ringLegend(
                        color: TvColors.mint,
                        label: 'امروز',
                        value: '${_fa(p.todayDone.toString())} از ${_fa(p.todayTotal.toString())}',
                        isDark: isDark,
                      ),
                      const SizedBox(height: TvSpacing.sm),
                      _ringLegend(
                        color: TvColors.sunGold,
                        label: 'این هفته',
                        value: '${_fa(p.weekDone.toString())} از ${_fa(p.weekTotal.toString())}',
                        isDark: isDark,
                      ),
                      const SizedBox(height: TvSpacing.md),
                      // XP bar
                      Text(
                        'XP ${_fa(p.xp.toString())}',
                        style: TvTypography.caption.copyWith(
                          color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(TvRadius.full),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: p.levelProgress),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, __) => LinearProgressIndicator(
                            value: v,
                            minHeight: 6,
                            backgroundColor: isDark
                                ? TvColors.nightElevated
                                : TvColors.brandPrimarySoft
                                    .withValues(alpha: 0.5),
                            valueColor: AlwaysStoppedAnimation(
                              TvColors.mint,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: TvSpacing.lg),

            // Stats row
            Container(
              height: 1,
              color: (isDark ? Colors.white : TvColors.ink)
                  .withValues(alpha: 0.06),
            ),
            const SizedBox(height: TvSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _statPill(
                    icon: Icons.eco_rounded,
                    value: _fa(p.sprouts.toString()),
                    label: 'جوانه‌ها',
                    tint: TvColors.mint,
                    isDark: isDark,
                  ),
                ),
                _vDivider(isDark),
                Expanded(
                  child: _statPill(
                    icon: Icons.local_fire_department_rounded,
                    value: _fa(p.streak.toString()),
                    label: 'روزهای متوالی',
                    tint: TvColors.sunGold,
                    isDark: isDark,
                  ),
                ),
                _vDivider(isDark),
                Expanded(
                  child: _statPill(
                    icon: Icons.check_circle_rounded,
                    value: _fa(p.todayDone.toString()),
                    label: 'انجام امروز',
                    tint: TvColors.sky,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 100.ms)
        .slideY(begin: 0.05, end: 0, duration: 500.ms);
  }

  Widget _ringLegend({
    required Color color,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: TvSpacing.xs),
        Text(
          label,
          style: TvTypography.caption.copyWith(
            color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TvTypography.caption.copyWith(
            color: isDark ? Colors.white : TvColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _statPill({
    required IconData icon,
    required String value,
    required String label,
    required Color tint,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: tint, size: 20),
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
          maxLines: 1,
          style: TvTypography.caption.copyWith(
            color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _vDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: TvSpacing.xs),
      color: (isDark ? Colors.white : TvColors.ink).withValues(alpha: 0.06),
    );
  }

  // ────────────────────────────────────────────────────────
  // Section row + filter
  // ────────────────────────────────────────────────────────

  Widget _sectionRow({
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TvTypography.headline.copyWith(
                  color: isDark ? Colors.white : TvColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TvTypography.bodySmall.copyWith(
                  color: isDark ? TvColors.inkMuted : TvColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: _openEditor,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('تسک تازه'),
          style: TextButton.styleFrom(
            foregroundColor: TvColors.brandPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: TvSpacing.sm,
              vertical: 4,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }

  Widget _filterRow(bool isDark) {
    final filters = ['همه', 'در جریان', 'انجام‌شده'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (var i = 0; i < filters.length; i++) ...[
            if (i > 0) const SizedBox(width: TvSpacing.xs),
            _filterChip(
              filters[i],
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
    String label, {
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
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? TvColors.nightElevated : Colors.white)
              : (isDark ? TvColors.nightSoft : TvColors.paper),
          borderRadius: BorderRadius.circular(TvRadius.full),
          border: Border.all(
            color: selected
                ? TvColors.brandPrimary.withValues(alpha: 0.28)
                : (isDark ? Colors.white : TvColors.ink)
                    .withValues(alpha: 0.04),
          ),
          boxShadow: selected && !isDark
              ? [
                  BoxShadow(
                    color:
                        TvColors.brandPrimary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TvTypography.label.copyWith(
            color: foreground,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // Task list
  // ────────────────────────────────────────────────────────

  Widget _taskList(bool isDark) {
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
        // Apply filter
        final filtered = switch (_filterIndex) {
          1 => tasks.where((t) => !t.isDone).toList(),
          2 => tasks.where((t) => t.isDone).toList(),
          _ => tasks,
        };

        if (filtered.isEmpty) {
          return _emptyState(isDark);
        }

        return Column(
          children: [
            for (final t in filtered)
              TaskCard(
                key: ValueKey(t.id),
                task: t,
                onToggleDone: () async {
                  final newStatus = t.isDone ? 'todo' : 'done';
                  try {
                    await TasksApi.instance.setStatus(t.id, newStatus);
                  } catch (_) {}
                  ref.invalidate(todayTasksProvider);
                  ref.invalidate(allTasksProvider);
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

    return Container(
      padding: const EdgeInsets.fromLTRB(
        TvSpacing.lg,
        TvSpacing.xl,
        TvSpacing.lg,
        TvSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(TvRadius.xl),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : TvColors.brandPrimary.withValues(alpha: 0.08),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: TvColors.brandPrimary.withValues(alpha: 0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
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
                    .animate(onPlay: (c) => c.repeat(reverse: true))
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
            onPressed: _openEditor,
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

  // ────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────

  void _openEditor() {
    TvHaptics.tap();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TaskEditorSheet(),
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