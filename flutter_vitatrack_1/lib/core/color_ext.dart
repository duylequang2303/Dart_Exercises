import 'package:flutter/material.dart';

extension ColorValues on Color {
  /// Compatibility helper: Flutter's built-in withValues() is used everywhere.
  /// This extension is kept for any legacy call sites.
  Color withAlpha255(int alpha) => withAlpha(alpha);
}
