import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

/// Two-layer animated progress ring:
/// - Inner ring: today's tasks
/// - Outer ring: this week's tasks
class TvProgressRing extends StatefulWidget {
  const TvProgressRing({
    super.key,
    required this.todayRatio,
    required this.weekRatio,
    this.size = 130,
    this.innerStroke = 8,
    this.outerStroke = 5,
    this.todayColor = TvColors.mint,
    this.weekColor = TvColors.sunGold,
    this.innerTrack,
    this.outerTrack,
    this.centerLabel = 'امروز',
    this.showPercent = true,
  });

  final double todayRatio; // 0..1
  final double weekRatio; // 0..1
  final double size;
  final double innerStroke;
  final double outerStroke;
  final Color todayColor;
  final Color weekColor;
  final Color? innerTrack;
  final Color? outerTrack;
  final String centerLabel;
  final bool showPercent;

  @override
  State<TvProgressRing> createState() => _TvProgressRingState();
}

class _TvProgressRingState extends State<TvProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late Animation<double> _todayAnim;
  late Animation<double> _weekAnim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _todayAnim = Tween<double>(
      begin: 0,
      end: widget.todayRatio.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _weekAnim = Tween<double>(
      begin: 0,
      end: widget.weekRatio.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _c.forward();
  }

  @override
  void didUpdateWidget(covariant TvProgressRing old) {
    super.didUpdateWidget(old);
    if (old.todayRatio != widget.todayRatio ||
        old.weekRatio != widget.weekRatio) {
      _todayAnim = Tween<double>(
        begin: _todayAnim.value,
        end: widget.todayRatio.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
      _weekAnim = Tween<double>(
        begin: _weekAnim.value,
        end: widget.weekRatio.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _fa(double percent) {
    final digits = percent.toStringAsFixed(0);
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return digits
        .split('')
        .map((c) => int.tryParse(c) != null ? fa[int.parse(c)] : c)
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          return CustomPaint(
            painter: _DoubleRingPainter(
              todayProgress: _todayAnim.value,
              weekProgress: _weekAnim.value,
              todayColor: widget.todayColor,
              weekColor: widget.weekColor,
              innerTrack:
                  widget.innerTrack ?? TvColors.brandPrimarySoft,
              outerTrack: widget.outerTrack ?? TvColors.sunGoldSoft,
              innerStroke: widget.innerStroke,
              outerStroke: widget.outerStroke,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showPercent)
                    Text(
                      '${_fa(_todayAnim.value * 100)}٪',
                      style: TvTypography.numericDisplay.copyWith(
                        fontSize: widget.size * 0.24,
                        color: TvColors.brandPrimary,
                        height: 1.0,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    widget.centerLabel,
                    style: TvTypography.caption.copyWith(
                      color: TvColors.inkMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DoubleRingPainter extends CustomPainter {
  _DoubleRingPainter({
    required this.todayProgress,
    required this.weekProgress,
    required this.todayColor,
    required this.weekColor,
    required this.innerTrack,
    required this.outerTrack,
    required this.innerStroke,
    required this.outerStroke,
  });

  final double todayProgress;
  final double weekProgress;
  final Color todayColor;
  final Color weekColor;
  final Color innerTrack;
  final Color outerTrack;
  final double innerStroke;
  final double outerStroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // ---- OUTER RING (week) ----
    final outerRadius = (size.width - outerStroke) / 2;
    final outerTrackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerStroke
      ..strokeCap = StrokeCap.round
      ..color = outerTrack;
    canvas.drawCircle(center, outerRadius, outerTrackPaint);

    if (weekProgress > 0) {
      final outerFg = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerStroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [weekColor, TvColors.rose],
        ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        -math.pi / 2,
        2 * math.pi * weekProgress,
        false,
        outerFg,
      );
    }

    // ---- INNER RING (today) ----
    final innerRadius = outerRadius - outerStroke - 4 - (innerStroke / 2);
    final innerTrackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerStroke
      ..strokeCap = StrokeCap.round
      ..color = innerTrack;
    canvas.drawCircle(center, innerRadius, innerTrackPaint);

    if (todayProgress > 0) {
      final innerFg = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = innerStroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [todayColor, TvColors.brandPrimary],
        ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        -math.pi / 2,
        2 * math.pi * todayProgress,
        false,
        innerFg,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DoubleRingPainter old) =>
      old.todayProgress != todayProgress ||
      old.weekProgress != weekProgress ||
      old.todayColor != todayColor ||
      old.weekColor != weekColor;
}