import 'package:flutter/material.dart';

import '../../core/theme/haptics.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/theme_ext.dart';
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
  });

  final String label;
  final VoidCallback? onPressed;
  final TvButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  State<TvButton> createState() => _TvButtonState();
}

class _TvButtonState extends State<TvButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _c;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _c.reverse();
  void _onTapUp(_) => _c.forward();
  void _onTapCancel() => _c.forward();

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: disabled ? null : _onTapDown,
        onTapUp: disabled ? null : _onTapUp,
        onTapCancel: disabled ? null : _onTapCancel,
        onTap: disabled
            ? null
            : () {
                TvHaptics.tap();
                widget.onPressed?.call();
              },
        child: _buildButton(disabled),
      ),
    );
  }

  Widget _buildButton(bool disabled) {
    final padding = widget.expand
        ? const EdgeInsets.symmetric(horizontal: TvSpacing.lg)
        : const EdgeInsets.symmetric(
            horizontal: TvSpacing.lg,
            vertical: TvSpacing.sm,
          );

    final brand = context.brand;
    final accent = context.accent;
    final brandSoft = context.brandSoft;

    final child = widget.loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: TvTypography.title.copyWith(
                  color: _textColor(disabled, brand),
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: TvSpacing.xs),
                Icon(widget.icon, color: _textColor(disabled, brand), size: 20),
              ],
            ],
          );

    switch (widget.variant) {
      case TvButtonVariant.primary:
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          padding: padding,
          decoration: BoxDecoration(
            color: disabled ? context.inkMuted : brand,
            borderRadius: BorderRadius.circular(TvRadius.md),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: brand.withValues(alpha: 0.32),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Center(child: child),
        );

      case TvButtonVariant.secondary:
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          padding: padding,
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(TvRadius.md),
            border: Border.all(
              color: brand.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Center(child: child),
        );

      case TvButtonVariant.ghost:
        return Container(
          height: 48,
          padding: padding,
          child: Center(child: child),
        );
    }
  }

  Color _textColor(bool disabled, Color brand) {
    if (disabled) return context.inkMuted;
    switch (widget.variant) {
      case TvButtonVariant.primary:
        return Colors.white;
      case TvButtonVariant.secondary:
      case TvButtonVariant.ghost:
        return brand;
    }
  }
}
