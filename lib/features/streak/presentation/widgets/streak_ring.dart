import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lock_in/core/theme/app_theme.dart';

/// Animated circular progress ring for the streak display.
/// Supports two modes:
/// - **Detailed** (default): Shows Days, Hours, Minutes, Seconds
/// - **Minimalist** (on tap): Shows only the Day count
class StreakRing extends StatefulWidget {
  final int currentStreak;
  final int targetDays;
  final IconData icon;
  final DateTime? streakStartDate;
  final bool showDetailed;
  final VoidCallback? onTap;

  const StreakRing({
    super.key,
    required this.currentStreak,
    this.targetDays = 90,
    required this.icon,
    this.streakStartDate,
    this.showDetailed = true,
    this.onTap,
  });

  @override
  State<StreakRing> createState() => _StreakRingState();
}

class _StreakRingState extends State<StreakRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _updateAnimation();
    _controller.forward();
  }

  @override
  void didUpdateWidget(StreakRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStreak != widget.currentStreak) {
      _updateAnimation();
      _controller.forward(from: 0);
    }
  }

  void _updateAnimation() {
    final progress = (widget.currentStreak / widget.targetDays).clamp(0.0, 1.0);
    _progressAnim = Tween<double>(
      begin: 0,
      end: progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration _getElapsed() {
    if (widget.streakStartDate == null) return Duration.zero;
    return DateTime.now().difference(widget.streakStartDate!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _progressAnim,
        builder: (context, child) {
          final elapsed = _getElapsed();

          return SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow behind ring
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: 0.15 + (_progressAnim.value * 0.15),
                        ),
                        blurRadius: 40 + (_progressAnim.value * 20),
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                // Background ring
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _RingPainter(
                    progress: 1.0,
                    color: AppColors.surfaceLight.withValues(alpha: 0.5),
                    strokeWidth: 8,
                  ),
                ),
                // Progress ring
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _RingPainter(
                    progress: _progressAnim.value,
                    color: AppColors.primary,
                    strokeWidth: 8,
                    useGradient: true,
                  ),
                ),
                // Center content — toggle between detailed & minimal
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: widget.showDetailed
                      ? _DetailedView(
                          key: const ValueKey('detailed'),
                          elapsed: elapsed,
                        )
                      : _MinimalView(
                          key: const ValueKey('minimal'),
                          currentStreak: widget.currentStreak,
                          icon: widget.icon,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Detailed View ───
// Layout:    2 Days
//          17 Hrs  11 Mins
//              1 Secs
//          OF SOBRIETY
class _DetailedView extends StatelessWidget {
  final Duration elapsed;

  const _DetailedView({super.key, required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final days = elapsed.inDays;
    final hours = elapsed.inHours % 24;
    final minutes = elapsed.inMinutes % 60;
    final seconds = elapsed.inSeconds % 60;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: Days
        _InlineUnit(value: '$days', label: 'Days', fontSize: 36),
        const SizedBox(height: 2),
        // Row 2: Hours + Minutes
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            _InlineUnit(value: '$hours', label: 'Hrs', fontSize: 28),
            const SizedBox(width: 6),
            _InlineUnit(value: '$minutes', label: 'Mins', fontSize: 28),
          ],
        ),
        const SizedBox(height: 2),
        // Row 3: Seconds
        _InlineUnit(value: '$seconds', label: 'Secs', fontSize: 28),
        const SizedBox(height: 6),
        // Bottom label
        Text(
          'LOCKED IN',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}

/// Number + label inline: "2" bold large, "Days" small muted
class _InlineUnit extends StatelessWidget {
  final String value;
  final String label;
  final double fontSize;

  const _InlineUnit({
    required this.value,
    required this.label,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: fontSize * 0.28,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Minimal View ───
class _MinimalView extends StatelessWidget {
  final int currentStreak;
  final IconData icon;

  const _MinimalView({
    super.key,
    required this.currentStreak,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: AppColors.accent),
        const SizedBox(height: 4),
        Text(
          'Day $currentStreak',
          style: Theme.of(
            context,
          ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          'Current Streak',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ─── Ring Painter ───
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool useGradient;

  _RingPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 8,
    this.useGradient = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (useGradient) {
      paint.shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [AppColors.accent, AppColors.primary, AppColors.primary],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    } else {
      paint.color = color;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
