
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/haptics.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';

enum TvButtonVariant { primary, secondary, ghost }

class TvButton extends StatefulWidget {
  const TvButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TvButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.enabled = true,
    this.height,
    this.borderRadius,
    this.tooltip,
    this.semanticLabel,
    this.textStyle,
    this.iconPosition = TvButtonIconPosition.end,
  });

  final String label;
  final VoidCallback? onPressed;
  final TvButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  /// Optional controls; existing call sites remain compatible.
  final bool enabled;
  final double? height;
  final double? borderRadius;
  final String? tooltip;
  final String? semanticLabel;
  final TextStyle? textStyle;
  final TvButtonIconPosition iconPosition;

  @override
  State<TvButton> createState() => _TvButtonState();
}

enum TvButtonIconPosition { start, end }

class _TvButtonState extends State<TvButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  bool _pressed = false;

  bool get _disabled =>
      !widget.enabled || widget.onPressed == null || widget.loading;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 160),
      lowerBound: 0.965,
      upperBound: 1,
      value: 1,
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant TvButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_disabled) {
      _pressed = false;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (_disabled) return;
    _pressed = true;
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails _) {
    _pressed = false;
    _controller.forward();
  }

  void _onTapCancel() {
    _pressed = false;
    _controller.forward();
  }

  void _handlePressed() {
    if (_disabled) return;

    TvHaptics.tap();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _disabled || reduceMotion ? null : _onTapDown,
      onTapUp: _disabled || reduceMotion ? null : _onTapUp,
      onTapCancel: _disabled || reduceMotion ? null : _onTapCancel,
      onTap: _disabled ? null : _handlePressed,
      child: AnimatedBuilder(
        animation: _scale,
        child: _buildButton(context),
        builder: (context, child) {
          return Transform.scale(
            scale: reduceMotion ? 1 : _scale.value,
            child: child,
          );
        },
      ),
    );

    final semanticButton = Semantics(
      button: true,
      enabled: !_disabled,
      label: widget.semanticLabel ?? widget.label,
      child: button,
    );

    final result = widget.expand
        ? SizedBox(width: double.infinity, child: semanticButton)
        : semanticButton;

    if (widget.tooltip == null) return result;

    return Tooltip(
      message: widget.tooltip!,
      child: result,
    );
  }

  Widget _buildButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final disabled = _disabled;

    final radius = BorderRadius.circular(
      (widget.borderRadius ?? TvRadius.md).clamp(0.0, 1000.0),
    );

    final height = widget.height ??
        (widget.variant == TvButtonVariant.ghost ? 48.0 : 56.0);

    final horizontalPadding = widget.expand
        ? TvSpacing.lg.toDouble()
        : TvSpacing.md.toDouble();

    final textColor = _textColor(
      variant: widget.variant,
      disabled: disabled,
      isDark: isDark,
    );

    final child = widget.loading
        ? _buildLoadingIndicator(textColor, isDark)
        : _buildLabel(textColor);

    switch (widget.variant) {
      case TvButtonVariant.primary:
        return _buildPrimary(
          context: context,
          radius: radius,
          height: height,
          padding: horizontalPadding,
          disabled: disabled,
          child: child,
        );

      case TvButtonVariant.secondary:
        return _buildSecondary(
          context: context,
          radius: radius,
          height: height,
          padding: horizontalPadding,
          disabled: disabled,
          child: child,
        );

      case TvButtonVariant.ghost:
        return _buildGhost(
          context: context,
          radius: radius,
          height: height,
          padding: horizontalPadding,
          disabled: disabled,
          child: child,
        );
    }
  }

  Widget _buildLabel(Color textColor) {
    final label = Text(
      widget.label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: (widget.textStyle ?? TvTypography.title).copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
    );

    if (widget.icon == null) return label;

    final icon = Icon(
      widget.icon,
      size: 20,
      color: textColor,
    );

    final children = widget.iconPosition == TvButtonIconPosition.start
        ? <Widget>[
            icon,
            const SizedBox(width: TvSpacing.xs),
            Flexible(child: label),
          ]
        : <Widget>[
            Flexible(child: label),
            const SizedBox(width: TvSpacing.xs),
            icon,
          ];

    return Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildLoadingIndicator(Color color, bool isDark) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.3,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: color.withValues(alpha: 0.18),
      ),
    );
  }

  Widget _buildPrimary({
    required BuildContext context,
    required BorderRadius radius,
    required double height,
    required double padding,
    required bool disabled,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        gradient: disabled
            ? null
            : const LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  TvColors.brandPrimary,
                  TvColors.brandPrimaryDeep,
                ],
              ),
        color: disabled
            ? (isDark ? TvColors.nightElevated : TvColors.sandDeep)
            : null,
        borderRadius: radius,
        border: Border.all(
          color: disabled
              ? Theme.of(context).colorScheme.outlineVariant
                  .withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.12),
          width: 0.8,
        ),
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: TvColors.brandPrimary.withValues(
                    alpha: isDark ? 0.24 : 0.15,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: TvColors.mint.withValues(
                    alpha: isDark ? 0.09 : 0.12,
                  ),
                  blurRadius: 22,
                  offset: const Offset(0, 4),
                  spreadRadius: -10,
                ),
              ],
      ),
      child: Center(child: child),
    );
  }

  Widget _buildSecondary({
    required BuildContext context,
    required BorderRadius radius,
    required double height,
    required double padding,
    required bool disabled,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        color: isDark ? TvColors.nightSoft : TvColors.paper,
        borderRadius: radius,
        border: Border.all(
          color: disabled
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.35)
              : TvColors.brandPrimary.withValues(alpha: 0.24),
          width: 1.2,
        ),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildGhost({
    required BuildContext context,
    required BorderRadius radius,
    required double height,
    required double padding,
    required bool disabled,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: radius,
        border: Border.all(
          color: disabled
              ? Colors.transparent
              : TvColors.brandPrimary.withValues(alpha: 0.08),
        ),
      ),
      child: Center(child: child),
    );
  }

  Color _textColor({
    required TvButtonVariant variant,
    required bool disabled,
    required bool isDark,
  }) {
    if (disabled) {
      return isDark ? TvColors.inkMuted : TvColors.inkMuted;
    }

    switch (variant) {
      case TvButtonVariant.primary:
        return Colors.white;
      case TvButtonVariant.secondary:
      case TvButtonVariant.ghost:
        return isDark
            ? TvColors.brandPrimarySoft
            : TvColors.brandPrimary;
    }
  }
}
