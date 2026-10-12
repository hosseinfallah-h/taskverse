
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

/// Premium animated circular progress indicator for TaskVerse.
///
/// Features:
/// - Smooth animated progress transitions.
/// - Gradient progress arc with rounded caps.
/// - Theme-aware colors and track.
/// - Persian percentage numerals by default.
/// - Optional center label and percentage.
/// - Reduced-motion accessibility support.
/// - Repaints only when painter inputs change.
class TvProgressRing extends StatefulWidget {
  const TvProgressRing({
    super.key,
    required this.value,
    this.size = 120,
    this.strokeWidth = 10,
    this.color = TvColors.mint,
    this.backgroundColor,
    this.label,
    this.showPercent = true,
    this.showPersianNumerals = true,
  });

  /// Progress value in the range 0..1.
  ///
  /// Values outside the range are clamped automatically.
  final double value;

  /// Width and height of the ring.
  final double size;

  /// Thickness of the circular track and progress arc.
  final double strokeWidth;

  /// Leading color of the progress gradient.
  final Color color;

  /// Optional track color. Defaults to a theme-aware subtle surface.
  final Color? backgroundColor;

  /// Optional caption displayed below the percentage.
  final String? label;

  /// Whether to show the percentage in the center.
  final bool showPercent;

  /// Whether to format the percentage using Persian numerals.
  final bool showPersianNumerals;

  @override
  State<TvProgressRing> createState() => _TvProgressRingState();
}

class _TvProgressRingState extends State<TvProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  double get _targetValue => widget.value.clamp(0.0, 1.0).toDouble();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animation = AlwaysStoppedAnimation<double>(_targetValue);
    _updateAnimation(begin: 0, end: _targetValue, animate: true);
  }

  @override
  void didUpdateWidget(covariant TvProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _updateAnimation(
        begin: _animation.value,
        end: _targetValue,
        animate: true,
      );
    }
  }

  void _updateAnimation({
    required double begin,
    required double end,
    required bool animate,
  }) {
    final reduceMotion =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations;

    _animation = Tween<double>(
      begin: begin.clamp(0.0, 1.0).toDouble(),
      end: end,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    if (!animate || reduceMotion) {
      _controller.value = 1;
      return;
    }

    _controller
      ..duration = const Duration(milliseconds: 900)
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatPersianNumber(double percent) {
    final digits = percent.round().toString();

    if (!widget.showPersianNumerals) return digits;

    const persianDigits = <String>[
      '۰',
      '۱',
      '۲',
      '۳',
      '۴',
      '۵',
      '۶',
      '۷',
      '۸',
      '۹',
    ];

    return digits.split('').map((character) {
      final digit = int.tryParse(character);
      return digit == null ? character : persianDigits[digit];
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trackColor = widget.backgroundColor ??
        (isDark
            ? theme.colorScheme.surfaceContainerHighest
            : TvColors.brandPrimarySoft.withValues(alpha: 0.72));

    final centerColor = isDark ? TvColors.mint : TvColors.brandPrimary;
    final labelColor = theme.colorScheme.onSurfaceVariant;

    final safeSize = widget.size.clamp(24.0, 1000.0).toDouble();
    final safeStroke = widget.strokeWidth
        .clamp(1.0, math.max(1.0, safeSize / 3))
        .toDouble();

    final percentStyle = TvTypography.numericDisplay.copyWith(
      fontSize: safeSize * 0.27,
      height: 1.12,
      color: centerColor,
      fontWeight: FontWeight.w700,
    );

    final labelStyle = TvTypography.caption.copyWith(
      fontSize: (safeSize * 0.105).clamp(10.0, 14.0).toDouble(),
      height: 1.35,
      color: labelColor,
      fontWeight: FontWeight.w500,
    );

    return Semantics(
      label: widget.label == null
          ? 'درصد پیشرفت'
          : 'پیشرفت ${widget.label}',
      value: '${_formatPersianNumber(_targetValue * 100)} درصد',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: safeSize,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = _animation.value.clamp(0.0, 1.0).toDouble();

              return CustomPaint(
                painter: _RingPainter(
                  progress: progress,
                  color: widget.color,
                  endColor: TvColors.brandPrimary,
                  backgroundColor: trackColor,
                  strokeWidth: safeStroke,
                  glow: isDark,
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(safeStroke + 3),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.showPercent)
                            Text(
                              '${_formatPersianNumber(progress * 100)}٪',
                              maxLines: 1,
                              style: percentStyle,
                            ),
                          if (widget.label != null &&
                              widget.label!.trim().isNotEmpty) ...[
                            SizedBox(height: safeSize * 0.015),
                            Text(
                              widget.label!,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: labelStyle,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.endColor,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.glow,
  });

  final double progress;
  final Color color;
  final Color endColor;
  final Color backgroundColor;
  final double strokeWidth;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(0.0, (math.min(size.width, size.height) - strokeWidth) / 2);
    if (radius <= 0) return;

    final bounds = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    // Subtle track with a consistent, clean circular silhouette.
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = backgroundColor
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweepAngle = 2 * math.pi * progress;

    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: [
        color,
        Color.lerp(color, endColor, 0.45)!,
        endColor,
      ],
      stops: const [0.0, 0.58, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    );

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(bounds)
      ..isAntiAlias = true;

    if (glow) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.8
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..isAntiAlias = true;

      canvas.drawArc(
        bounds,
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    canvas.drawArc(
      bounds,
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.endColor != endColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.glow != glow;
  }
}
