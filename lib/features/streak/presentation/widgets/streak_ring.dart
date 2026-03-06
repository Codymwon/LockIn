import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/core/utils/date_utils.dart';

/// Animated circular progress ring for the streak display.
/// Shows:
/// - Icon
/// - Day X
/// - Current Streak (label)
/// - [Hours Mins Secs] (mini live timer)
class StreakRing extends StatefulWidget {
  final int currentStreak;
  final int targetDays;
  final int previousMilestone;
  final IconData icon;
  final DateTime? streakStartDate;

  const StreakRing({
    super.key,
    required this.currentStreak,
    this.targetDays = 90,
    this.previousMilestone = 0,
    required this.icon,
    this.streakStartDate,
  });

  @override
  State<StreakRing> createState() => _StreakRingState();
}

class _StreakRingState extends State<StreakRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _updateAnimation();
    _controller.forward();
    // Tick every second to update the live h:m:s display
    if (widget.streakStartDate != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(StreakRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStreak != widget.currentStreak ||
        oldWidget.streakStartDate != widget.streakStartDate) {
      _updateAnimation();
      _controller.forward(from: 0);
    }
    // Start/stop timer when streak state changes
    if (widget.streakStartDate != null && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (widget.streakStartDate == null && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _updateAnimation() {
    double elapsed = widget.currentStreak.toDouble();
    if (widget.streakStartDate != null) {
      elapsed =
          DateTime.now().difference(widget.streakStartDate!).inSeconds /
          86400.0; // seconds in a day
    }

    final progress = widget.targetDays > 0
        ? (elapsed / widget.targetDays).clamp(0.0, 1.0)
        : 0.0;

    _progressAnim = Tween<double>(
      begin: 0,
      end: progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Duration _getElapsed() {
    if (widget.streakStartDate == null) return Duration.zero;
    return DateTime.now().difference(widget.streakStartDate!);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (context, child) {
        final elapsed = _getElapsed();
        final hours = elapsed.inHours % 24;
        final minutes = elapsed.inMinutes % 60;
        final seconds = elapsed.inSeconds % 60;

        final liveDays = widget.streakStartDate != null
            ? AppDateUtils.calculateStreak(widget.streakStartDate!)
            : widget.currentStreak;

        double liveElapsed = liveDays.toDouble();
        if (widget.streakStartDate != null && !elapsed.isNegative) {
          liveElapsed = elapsed.inSeconds / 86400.0;
        }
        final liveProgress = widget.targetDays > 0
            ? (liveElapsed / widget.targetDays).clamp(0.0, 1.0)
            : 0.0;
        final currentRingValue = _controller.isAnimating
            ? _progressAnim.value
            : liveProgress;

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
                        alpha: 0.15 + (currentRingValue * 0.15),
                      ),
                      blurRadius: 40 + (currentRingValue * 20),
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
                  progress: currentRingValue,
                  color: AppColors.primary,
                  strokeWidth: 8,
                  useGradient: true,
                ),
              ),
              // Center content — Combined Layout
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Icon
                  Icon(widget.icon, size: 28, color: AppColors.accent),
                  const SizedBox(height: 8),

                  // 2. Day X
                  Text(
                    'Day $liveDays',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 48,
                      height: 1.1,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3. Mini Timer (Hours Mins Secs)
                  if (widget.streakStartDate != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _MiniTimeUnit(
                          value: hours.toString().padLeft(2, '0'),
                          label: 'h',
                        ),
                        const SizedBox(width: 8),
                        _MiniTimeUnit(
                          value: minutes.toString().padLeft(2, '0'),
                          label: 'm',
                        ),
                        const SizedBox(width: 8),
                        _MiniTimeUnit(
                          value: seconds.toString().padLeft(2, '0'),
                          label: 's',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // 4. "Current Streak" Label
                  Text(
                    'Current Streak',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A tiny inline time unit for the live timer (e.g. "17 h")
class _MiniTimeUnit extends StatelessWidget {
  final String value;
  final String label;

  const _MiniTimeUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
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
