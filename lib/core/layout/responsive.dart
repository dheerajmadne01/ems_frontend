import 'package:flutter/material.dart';

/// Tiny helpers to keep sizing adaptive across phones/tablets.
class Responsive {
  /// Returns a size scaled against screen width with sane min/max bounds.
  static double sizeByWidth(
    BuildContext context, {
    required double base,
    double min = 12,
    double max = 32,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    // Scale linearly around a 390px reference (typical phone), clamp for extremes.
    final scaled = base * (width / 390).clamp(0.85, 1.25);
    return scaled.clamp(min, max);
  }

  /// Horizontal padding that grows a bit on tablets.
  static EdgeInsets screenPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 600 ? 24.0 : 16.0;
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 20);
  }
}


