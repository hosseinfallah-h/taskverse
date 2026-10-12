import 'package:flutter/material.dart';

import '../../core/theme/haptics.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/theme/typography.dart';

/// Pill-shaped bottom navigation with a center FAB.
/// Colors follow the active season via Theme.of(context).
class TvBottomNav extends StatelessWidget {
  const TvBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
  });

  final int currentIndex; // 0=home, 1=projects, 2=calendar, 3=me
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;

  static const _items = [
    (Icons.home_outlined, Icons.home, 'خانه'),
    (Icons.layers_outlined, Icons.layers, 'پروژه‌ها'),
    (Icons.calendar_today_outlined, Icons.calendar_today, 'تقویم'),
    (Icons.person_outline, Icons.person, 'من'),
  ];

  @override
  Widget build(BuildContext context) {
    final surface = context.surface;
    final brand = context.brand;
    final ink = context.ink;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(TvRadius.xl),
        boxShadow: [
          BoxShadow(
            color: brand.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: TvSpacing.xs,
        vertical: TvSpacing.xs,
      ),
      child: Row(
        children: [
          _tab(context, 0),
          _tab(context, 1),
          _fab(context),
          _tab(context, 2),
          _tab(context, 3),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, int visualIndex) {
    final selected = currentIndex == visualIndex;
    final (iconOut, iconIn, label) = _items[visualIndex];

    final brand = context.brand;
    final accent = context.accent;
    final brandSoft = context.brandSoft;
    final ink = context.ink;
    final inkSoft = context.inkSoft;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          TvHaptics.tap();
          onTap(visualIndex);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? brandSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(TvRadius.md),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? iconIn : iconOut,
                color: selected ? brand : inkSoft,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TvTypography.caption.copyWith(
                  color: selected ? brand : inkSoft,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fab(BuildContext context) {
    final brand = context.brand;
    final accent = context.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TvSpacing.xs),
      child: GestureDetector(
        onTap: () {
          TvHaptics.tap();
          onFabTap();
        },
        child: Container(
          width: 54,
          height: 54,
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
          child: const Icon(Icons.add, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
