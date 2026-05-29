import 'package:flutter/material.dart';

extension ColorValues on Color {
  /// Compatibility helper: use .withValues(alpha: 0.15) in codebase.
  Color withValues({required double alpha}) => withOpacity(alpha);
}
