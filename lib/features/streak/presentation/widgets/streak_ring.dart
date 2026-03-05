import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lock_in/core/theme/app_theme.dart';

/// Animated circular progress ring for the streak display.
class StreakRing extends StatefulWidget {
  final int currentStreak;
  final int targetDays;
  final IconData icon;

  const StreakRing({
    super.key,
    required this.currentStreak,
    this.targetDays = 90,
    required this.icon,
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (context, child) {
        return SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow behind the ring
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
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 32, color: AppColors.accent),
                  const SizedBox(height: 4),
                  Text(
                    'Day ${widget.currentStreak}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Current Streak',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
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
