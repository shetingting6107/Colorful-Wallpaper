import 'package:flutter/material.dart';

import '../models/han_color.dart';
import '../models/wallpaper_spec.dart';
import 'wallpaper_engine.dart';

/// Bridges WallpaperEngine into the widget tree (preview + thumbnails).
class WallpaperPainter extends CustomPainter {
  final WallpaperSpec spec;
  final ColorRepository repo;

  WallpaperPainter(this.spec, this.repo);

  @override
  void paint(Canvas canvas, Size size) =>
      WallpaperEngine.paint(canvas, size, spec, repo);

  @override
  bool shouldRepaint(WallpaperPainter oldDelegate) => true;
}
