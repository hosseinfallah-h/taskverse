import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/haptics.dart';
import '../../../core/theme/seasons/season_provider.dart';
import '../../../core/theme/seasons/tv_season.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/theme_ext.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/progress_provider.dart';
import '../../tasks/providers/tasks_provider.dart';

class MeScreen extends ConsumerStatefulWidget {
  const MeScreen({super.key});

  @override
  ConsumerState<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends ConsumerState<MeScreen> {
  Future<void> _pickSeason() async {
    TvHaptics.tap();
    final current = ref.read(activeSeasonProvider);
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
                Icon(Icons.check_circle_rounded, color: palette.brandPrimary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    TvHaptics.tap();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(
          TvSpacing.lg,
          TvSpacing.md,
          TvSpacing.lg,
          TvSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: context.surface,
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
            Icon(Icons.logout_rounded, size: 40, color: TvColors.rose),
            const SizedBox(height: TvSpacing.sm),
            Text(
              'از حساب خارج شی؟',
              textAlign: TextAlign.center,
              style: TvTypography.title.copyWith(
                color: context.ink,
                fontWeight: FontWeight.w700,
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
                    child: const Text('خروج'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final progress = ref.watch(progressProvider);
    final season = ref.watch(activeSeasonProvider);
    final user = auth.user;
    final name = (user?.name ?? '').trim();
    final initial = name.isEmpty ? '؟' : name.characters.first;
    final brand = context.brand;

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            TvSpacing.md,
            TvSpacing.lg,
            TvSpacing.md,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'پروفایل',
                style: TvTypography.headline.copyWith(
                  color: context.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'باغ شخصی‌ت در یک نگاه',
                style: TvTypography.bodySmall.copyWith(color: context.inkSoft),
              ),
              const SizedBox(height: TvSpacing.lg),

              // Avatar + name card
              Container(
                padding: const EdgeInsets.all(TvSpacing.lg),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(TvRadius.xl),
                  border: Border.all(color: brand.withValues(alpha: 0.10)),
                  boxShadow: [
                    BoxShadow(
                      color: brand.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: brand,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: brand.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: TvTypography.headline.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: TvSpacing.md),
                    Text(
                      name.isEmpty ? 'کاربر' : name,
                      textAlign: TextAlign.center,
                      style: TvTypography.title.copyWith(
                        color: context.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _fa(user?.phone ?? ''),
                      textAlign: TextAlign.center,
                      style: TvTypography.bodySmall.copyWith(
                        color: context.inkSoft,
                      ),
                    ),
                    const SizedBox(height: TvSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TvSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.brandSoft,
                        borderRadius: BorderRadius.circular(TvRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(progress.rankEmoji),
                          const SizedBox(width: 6),
                          Text(
                            progress.rankName,
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
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: TvSpacing.md),

              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: TvSpacing.sm,
                crossAxisSpacing: TvSpacing.sm,
                childAspectRatio: 1.65,
                children: [
                  _statCard(
                    icon: Icons.bolt_rounded,
                    value: _fa(progress.xp.toString()),
                    label: 'امتیاز XP',
                    tint: TvColors.sunGold,
                  ),
                  _statCard(
                    icon: Icons.eco_rounded,
                    value: _fa(progress.sprouts.toString()),
                    label: 'جوانه‌ها',
                    tint: context.accent,
                  ),
                  _statCard(
                    icon: Icons.local_fire_department_rounded,
                    value: _fa(progress.streak.toString()),
                    label: 'روز متوالی',
                    tint: TvColors.rose,
                  ),
                  _statCard(
                    icon: Icons.check_circle_rounded,
                    value: _fa(progress.todayDone.toString()),
                    label: 'انجام امروز',
                    tint: TvColors.sky,
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

              const SizedBox(height: TvSpacing.lg),

              // Settings
              _sectionTitle('تنظیمات'),
              const SizedBox(height: TvSpacing.sm),

              _tile(
                icon: Icons.palette_outlined,
                label: 'فصل',
                value: season.faLabel,
                onTap: _pickSeason,
              ),
              _tile(
                icon: Icons.palette_outlined,
                label: 'پوسته',
                value: 'روشن',
                onTap: () {},
              ),
              _tile(
                icon: Icons.notifications_none_rounded,
                label: 'اعلان‌ها',
                value: 'روشن',
                onTap: () {},
              ),
              _tile(
                icon: Icons.download_outlined,
                label: 'خروجی داده',
                value: 'به‌زودی',
                onTap: () {},
              ),

              const SizedBox(height: TvSpacing.lg),
              TvButton(
                label: 'خروج از حساب',
                icon: Icons.logout_rounded,
                variant: TvButtonVariant.secondary,
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.all(TvSpacing.md),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(TvRadius.lg),
        border: Border.all(color: context.brand.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tint, size: 22),
          ),
          const SizedBox(width: TvSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TvTypography.numericSmall.copyWith(
                    color: context.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: TvTypography.caption.copyWith(color: context.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String label) {
    return Text(
      label,
      style: TvTypography.caption.copyWith(
        color: context.inkSoft,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TvSpacing.xs),
      child: Material(
        color: context.surface,
        borderRadius: BorderRadius.circular(TvRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(TvRadius.lg),
          onTap: () {
            TvHaptics.tap();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TvSpacing.md,
              vertical: TvSpacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, color: context.brand, size: 22),
                const SizedBox(width: TvSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: TvTypography.body.copyWith(
                      color: context.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: TvTypography.bodySmall.copyWith(
                    color: context.inkSoft,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_left_rounded,
                  color: context.inkSoft,
                  size: 20,
                ),
              ],
            ),
          ),
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
