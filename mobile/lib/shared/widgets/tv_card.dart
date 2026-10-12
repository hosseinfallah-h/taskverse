
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';

/// Premium surface card for TaskVerse.
///
/// Designed for Garden at Dawn:
/// - Theme-aware surface colors.
/// - Restrained elevation and subtle borders.
/// - Smooth press feedback for interactive cards.
/// - Optional gradient hero treatment.
/// - Accessible semantics and reduced-motion support.
///
/// Existing usage remains valid:
/// TvCard(child: ...)
/// TvCard(onTap: ..., child: ...)
/// TvCard.gradient(child: ...)
class TvCard extends StatelessWidget {
  const TvCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(TvSpacing.md),
    this.onTap,
    this.elevated = true,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.gradient,
    this.margin = EdgeInsets.zero,
    this.clipBehavior = Clip.antiAlias,
    this.semanticLabel,
    this.enablePressScale = true,
  }) : _isGradient = false;

  const TvCard.gradient({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(TvSpacing.lg),
    this.onTap,
    this.elevated = true,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.gradient,
    this.margin = EdgeInsets.zero,
    this.clipBehavior = Clip.antiAlias,
    this.semanticLabel,
    this.enablePressScale = true,
  }) : _isGradient = true;

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool elevated;
  final double? borderRadius;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;
  final EdgeInsetsGeometry margin;
  final Clip clipBehavior;
  final String? semanticLabel;
  final bool enablePressScale;
  final bool _isGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final radius = BorderRadius.circular(
      (borderRadius ?? TvRadius.lg).clamp(0.0, 1000.0),
    );

    final isHero = _isGradient;
    final surfaceColor = color ??
        (isHero
            ? TvColors.brandPrimary
            : scheme.surfaceContainerHigh);

    final outlineColor = borderColor ??
        scheme.outlineVariant.withValues(
          alpha: isDark ? 0.42 : 0.62,
        );

    final effectiveGradient = isHero
        ? (gradient ??
            LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                TvColors.brandPrimary,
                TvColors.brandPrimaryDeep,
                Color.lerp(
                  TvColors.brandPrimaryDeep,
                  TvColors.mint,
                  0.12,
                )!,
              ],
              stops: const [0.0, 0.66, 1.0],
            ))
        : gradient;

    final shadow = elevated
        ? [
            BoxShadow(
              color: (isHero ? TvColors.brandPrimary : Colors.black)
                  .withValues(
                alpha: isHero
                    ? (isDark ? 0.24 : 0.15)
                    : (isDark ? 0.13 : 0.035),
              ),
              blurRadius: isHero ? 28 : 22,
              spreadRadius: isHero ? -3 : -6,
              offset: Offset(0, isHero ? 12 : 7),
            ),
            if (isHero)
              BoxShadow(
                color: TvColors.mint.withValues(
                  alpha: isDark ? 0.09 : 0.12,
                ),
                blurRadius: 32,
                spreadRadius: -10,
                offset: const Offset(0, 8),
              ),
          ]
        : null;

    final content = Container(
      decoration: BoxDecoration(
        color: effectiveGradient == null ? surfaceColor : null,
        gradient: effectiveGradient,
        borderRadius: radius,
        border: Border.all(
          color: isHero
              ? Colors.white.withValues(alpha: 0.15)
              : outlineColor,
          width: 0.8,
        ),
        boxShadow: shadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: clipBehavior,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: (isHero ? Colors.white : TvColors.mint)
              .withValues(alpha: isHero ? 0.09 : 0.075),
          highlightColor: (isHero ? Colors.white : TvColors.mint)
              .withValues(alpha: isHero ? 0.045 : 0.035),
          hoverColor: (isHero ? Colors.white : TvColors.mint)
              .withValues(alpha: 0.035),
          focusColor: TvColors.mint.withValues(alpha: 0.08),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    return Padding(
      padding: margin,
      child: Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: _PressFeedback(
          enabled: onTap != null && enablePressScale && !reduceMotion,
          child: content,
        ),
      ),
    );
  }
}

class _PressFeedback extends StatefulWidget {
  const _PressFeedback({
    required this.child,
    required this.enabled,
  });

  final Widget child;
  final bool enabled;

  @override
  State<_PressFeedback> createState() => _PressFeedbackState();
}

class _PressFeedbackState extends State<_PressFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _scale = Tween<double>(
      begin: 1,
      end: 0.985,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _PressFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enabled && !widget.enabled) {
      _pressed = false;
      _controller.reverse();
    }
  }

  void _setPressed(bool pressed) {
    if (!widget.enabled || _pressed == pressed) return;

    _pressed = pressed;

    if (pressed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedBuilder(
        animation: _scale,
        child: widget.child,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            alignment: Alignment.center,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
