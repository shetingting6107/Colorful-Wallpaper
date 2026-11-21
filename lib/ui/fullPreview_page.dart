import 'package:flutter/material.dart';
import 'package:han_colors/engine/wallpaper_painter.dart';
import 'package:han_colors/models/han_color.dart';
import 'package:han_colors/models/wallpaper_spec.dart';
//全屏预览页面
class FullPreviewPage extends StatelessWidget {
  final WallpaperSpec spec;
  final ColorRepository repo;
  const FullPreviewPage({super.key, required this.spec, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: SizedBox.expand(
          child: CustomPaint(
            painter: WallpaperPainter(spec, repo),
          ),
        ),
      ),
    );
  }

}