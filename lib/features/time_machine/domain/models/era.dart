import 'package:flutter/material.dart';

class Era {
  const Era({
    required this.name,
    required this.subtitle,
    required this.years,
    required this.accent,
    required this.icon,
    required this.video,
  });

  final String name;
  final String subtitle;
  final String years;
  final Color accent;
  final IconData icon;
  final String video;
}
