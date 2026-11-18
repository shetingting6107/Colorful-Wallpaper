import 'package:flutter/material.dart';

import '../engine/wallpaper_painter.dart';
import '../models/han_color.dart';
import '../models/wallpaper_spec.dart';
import 'gallery_page.dart';

/// 开场展示页：整屏渲染一张招牌壁纸（朱砂点缀），底部标题 + 进入按钮。
class ShowcasePage extends StatelessWidget {
  final ColorRepository repo;
  const ShowcasePage({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final hero = WallpaperSpec(
      colorId: 'bise',
      template: TemplateType.zigzag,
      texture: 0.6,
      intensity: 0.6,
      anchorX: 0.5,
      anchorY: 0.40,
    );
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: WallpaperPainter(hero, repo)),
          // 底部压暗，保证文字可读
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x66000000)],
                stops: [0.55, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Text(
                    '华色',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 8,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '六十种中国传统色，六种东方构图\n为你的屏幕，留一方水墨',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xE6FFFFFF),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE63E21), // 朱砂
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => GalleryPage(repo: repo)),
                      ),
                      child: const Text('进入创作',
                          style: TextStyle(fontSize: 16, letterSpacing: 4)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
