
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/haptics.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';

class TvBottomNav extends StatelessWidget {
  const TvBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
  });

  /// 0 = home, 1 = projects, 2 = calendar, 3 = me.
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;

  static const _items = <_NavItem>[
    _NavItem(
      outlineIcon: Icons.home_outlined,
      filledIcon: Icons.home_rounded,
      label: 'خانه',
    ),
    _NavItem(
      outlineIcon: Icons.dashboard_outlined,
      filledIcon: Icons.dashboard_rounded,
      label: 'پروژه‌ها',
    ),
    _NavItem(
      outlineIcon: Icons.calendar_month_outlined,
      filledIcon: Icons.calendar_month_rounded,
      label: 'تقویم',
    ),
    _NavItem(
      outlineIcon: Icons.person_outline_rounded,
      filledIcon: Icons.person_rounded,
      label: 'من',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final background = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outlineVariant;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          TvSpacing.md,
          TvSpacing.xs,
          TvSpacing.md,
          TvSpacing.sm,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: TvColors.brandPrimary.withValues(
                  alpha: isDark ? 0.12 : 0.075,
                ),
                blurRadius: 36,
                spreadRadius: -8,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.18 : 0.035,
                ),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: background.withValues(
                    alpha: isDark ? 0.96 : 0.97,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: borderColor.withValues(
                      alpha: isDark ? 0.38 : 0.65,
                    ),
                    width: 0.8,
                  ),
                ),
                padding: const EdgeInsetsDirectional.fromSTEB(
                  TvSpacing.xs,
                  TvSpacing.sm,
                  TvSpacing.xs,
                  TvSpacing.sm,
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < 2; i++)
                      Expanded(
                        child: _buildDestination(
                          context: context,
                          index: i,
                          inactiveColor: inactiveColor,
                          reduceMotion: reduceMotion,
                        ),
                      ),
                    _buildCreateButton(
                      context: context,
                      reduceMotion: reduceMotion,
                    ),
                    for (var i = 2; i < 4; i++)
                      Expanded(
                        child: _buildDestination(
                          context: context,
                          index: i,
                          inactiveColor: inactiveColor,
                          reduceMotion: reduceMotion,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestination({
    required BuildContext context,
    required int index,
    required Color inactiveColor,
    required bool reduceMotion,
  }) {
    final item = _items[index];
    final selected = currentIndex == index;
    final theme = Theme.of(context);

    final selectedColor = theme.brightness == Brightness.dark
        ? TvColors.mint
        : TvColors.brandPrimary;

    final duration = reduceMotion
        ? Duration.zero
        : TvMotionDuration.standard;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Tooltip(
        message: item.label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (selected) {
                TvHaptics.selection();
                return;
              }

              TvHaptics.selection();
              onTap(index);
            },
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? selectedColor.withValues(
                        alpha: theme.brightness == Brightness.dark
                            ? 0.13
                            : 0.085,
                      )
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? selectedColor.withValues(alpha: 0.12)
                      : Colors.transparent,
                  width: 0.7,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 27,
                    child: AnimatedSwitcher(
                      duration: reduceMotion
                          ? Duration.zero
                          : TvMotionDuration.quick,
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.82,
                              end: 1,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        selected ? item.filledIcon : item.outlineIcon,
                        key: ValueKey<bool>(selected),
                        size: selected ? 24 : 23,
                        color: selected ? selectedColor : inactiveColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    style: TvTypography.caption.copyWith(
                      fontSize: 10.5,
                      height: 1.35,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? selectedColor : inactiveColor,
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    width: selected ? 14 : 4,
                    height: 3,
                    decoration: BoxDecoration(
                      color: selected
                          ? selectedColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton({
    required BuildContext context,
    required bool reduceMotion,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final duration = reduceMotion
        ? Duration.zero
        : TvMotionDuration.quick;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 7),
      child: Semantics(
        button: true,
        label: 'ساخت تسک جدید',
        child: Tooltip(
          message: 'تسک جدید',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                TvHaptics.tap();
                onFabTap();
              },
              child: SizedBox(
                width: 58,
                height: 58,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Soft outer halo.
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: TvColors.mint.withValues(
                              alpha: isDark ? 0.13 : 0.18,
                            ),
                            blurRadius: 20,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                    ),

                    // Premium gradient surface.
                    AnimatedContainer(
                      duration: duration,
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: TvColors.gardenGradient,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: TvColors.brandPrimary.withValues(
                              alpha: isDark ? 0.30 : 0.20,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: TvColors.mint.withValues(alpha: 0.16),
                            blurRadius: 24,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.outlineIcon,
    required this.filledIcon,
    required this.label,
  });

  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;
}

/// Centralized durations for this navigation component.
///
/// Keeps the component self-contained without introducing a new dependency.
abstract final class TvMotionDuration {
  static const quick = Duration(milliseconds: 200);
  static const standard = Duration(milliseconds: 300);
}
