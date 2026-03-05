import 'dart:ui';
import 'package:flutter/material.dart';

/// A glassmorphism-styled card with optional blur, transparency, and a subtle border.
/// By default blur is OFF for performance. Enable with [useBlur] when content
/// behind the card actually needs to show through.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color? borderColor;
  final bool useBlur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.blur = 10,
    this.borderColor,
    this.useBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final decoration = BoxDecoration(
      color: cs.surface.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? cs.primary.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: cs.primary.withValues(alpha: 0.05),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
    );

    if (useBlur) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: decoration,
            child: child,
          ),
        ),
      );
    }

    return Container(padding: padding, decoration: decoration, child: child);
  }
}
