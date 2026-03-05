import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/core/constants/app_constants.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/features/urge/presentation/providers/urge_provider.dart';
import 'package:lock_in/shared/widgets/glow_button.dart';

class UrgeScreen extends ConsumerStatefulWidget {
  const UrgeScreen({super.key});

  @override
  ConsumerState<UrgeScreen> createState() => _UrgeScreenState();
}

class _UrgeScreenState extends ConsumerState<UrgeScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnim;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isActive = false;
  String _message = '';
  String _breathPhase = 'Breathe In';

  @override
  void initState() {
    super.initState();
    _message = AppConstants
        .urgeMessages[Random().nextInt(AppConstants.urgeMessages.length)];

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12), // 4s in + 4s hold + 4s out
    );

    _breathAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.6,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 33.3,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 33.3),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.6,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 33.3,
      ),
    ]).animate(_breathController);

    _breathController.addListener(() {
      final progress = _breathController.value;
      String phase;
      if (progress < 0.333) {
        phase = 'Breathe In';
      } else if (progress < 0.666) {
        phase = 'Hold';
      } else {
        phase = 'Breathe Out';
      }
      if (phase != _breathPhase) {
        setState(() => _breathPhase = phase);
        HapticFeedback.lightImpact();
      }
    });

    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathController.forward(from: 0);
      }
    });
  }

  void _startBreathing() {
    setState(() => _isActive = true);
    _breathController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  void _stopBreathing() {
    _breathController.stop();
    _timer?.cancel();
    ref.read(urgeProvider.notifier).logUrge(_elapsedSeconds);
    setState(() => _isActive = false);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF150D2E), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Top bar
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                      onPressed: () {
                        if (_isActive) _stopBreathing();
                        Navigator.of(context).pop();
                      },
                      color: AppColors.textSecondary,
                    ),
                    const Spacer(),
                    Text(
                      'URGE SUPPORT',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 3,
                        fontSize: 12,
                        color: AppColors.accent,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
                const Spacer(),

                if (!_isActive) ...[
                  // Motivation message
                  const Icon(
                    Icons.shield_rounded,
                    size: 56,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  GlowButton(
                    text: 'START BREATHING',
                    onPressed: _startBreathing,
                    width: 220,
                    height: 56,
                    icon: Icons.air_rounded,
                  ),
                ] else ...[
                  // Breathing animation
                  Text(
                    _breathPhase,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: _breathAnim,
                    builder: (context, child) {
                      return Container(
                        width: 180 * _breathAnim.value,
                        height: 180 * _breathAnim.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.5),
                              AppColors.primary.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 10 * _breathAnim.value,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Timer
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Urge Survival Time',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  GlowButton(
                    text: 'I MADE IT',
                    onPressed: () {
                      _stopBreathing();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'You conquered that urge! 💪',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: AppColors.surface,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    color: AppColors.success,
                    textColor: AppColors.background,
                    width: 200,
                    height: 52,
                    icon: Icons.check_rounded,
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
