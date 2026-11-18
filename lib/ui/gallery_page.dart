import 'package:flutter/material.dart';

import '../data/presets.dart';
import '../engine/wallpaper_painter.dart';
import '../models/han_color.dart';
import '../models/wallpaper_spec.dart';
import 'editor_page.dart';
import 'home_page.dart';

/// 首页：精选壁纸网格。点单张进入「设为壁纸」页；
/// 右下角「自定义」进入华色集，从 60 色自由创作。
class GalleryPage extends StatelessWidget {
  final ColorRepository repo;
  const GalleryPage({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('精选', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,//一行2列
          mainAxisSpacing: 14,//行间距
          crossAxisSpacing: 14,//列间距
          childAspectRatio: 1170 / 2532,//宽高比，竖长壁纸比例
        ),
        itemCount: kPresets.length,
        itemBuilder: (context, i) {
          final spec = kPresets[i];
          final color = repo.byId(spec.colorId);
          return GestureDetector(//等价与点击事件
            onTap: () => Navigator.push(//push是入栈，可以用返回键回到此页
              context,
              MaterialPageRoute(
                builder: (_) => EditorPage(repo: repo, initialSpec: spec),
              ),
            ),
            child: Column(//单个item结构
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),//外层圆角
                      boxShadow: [//阴影
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(//裁剪圆角
                      borderRadius: BorderRadius.circular(14),
                      child: CustomPaint(//每个预览图都是实时绘制的
                        painter: WallpaperPainter(spec, repo),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(//底部文字
                    '${color.nameZh} · ${kTemplateLabels[spec.template.index]}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B6B6B)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2A2626),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.palette_outlined),
        label: const Text('自定义'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HomePage(repo: repo)),
        ),
      ),
    );
  }
}
