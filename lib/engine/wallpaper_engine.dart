import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/han_color.dart';
import '../models/wallpaper_spec.dart';
import 'engine_assets.dart';

/// Parametric renderer for all six wallpaper templates.
///
/// The same [paint] drives both the live preview (via WallpaperPainter) and
/// high-resolution PNG export ([renderPng]); every coordinate is relative to
/// the canvas size, so output is resolution independent. Reference frame:
/// 1170 x 2532 (iPhone), scale factor `s = size.width / 1170`.
class WallpaperEngine {
  static const Color kPaper = Color(0xFFF5F1E8); // 米白
  static const Color kInkDark = Color(0xFF2A2626); // 玄色
  static const double refWidth = 1170.0;
  static const double refHeight = 2532.0;
  static const double aspect = refWidth / refHeight;

  static void paint(
      Canvas canvas, Size size, WallpaperSpec spec, ColorRepository repo) {
    final Color primary = repo.byId(spec.colorId).color;
    final Color secondary = repo.byId(spec.secondaryColorId).color;
    final Color third = repo.byId(spec.thirdColorId).color;
    switch (spec.template) {
      case TemplateType.solidGrain:
        _solidGrain(canvas, size, spec, primary, secondary);
        break;
      case TemplateType.duoGradient:
        _duoGradient(canvas, size, spec, primary, secondary);
        break;
      case TemplateType.pine:
        _pine(canvas, size, spec, primary, secondary);
        break;
      case TemplateType.cloudDye:
        _cloudDye(canvas, size, spec, primary, secondary, third);
        break;
      case TemplateType.zigzag:
        _zigzag(canvas, size, spec, primary, secondary);
        break;
      case TemplateType.frames:
        _frames(canvas, size, spec, primary, secondary, third);
        break;
    }
  }

  /// Renders a shareable PNG. Defaults to 1440 x 3116 (QHD-class).
  static Future<Uint8List> renderPng(
      WallpaperSpec spec, ColorRepository repo,
      {double width = 1440}) async {
    final double height = width * refHeight / refWidth;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paint(canvas, Size(width, height), spec, repo);
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.round(), height.round());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    picture.dispose();
    return data!.buffer.asUint8List();
  }

  // ---------------------------------------------------------------- helpers

  static double _s(Size size) => size.width / refWidth;

  static void _paper(Canvas canvas, Size size, double texture) {
    canvas.drawRect(Offset.zero & size, Paint()..color = kPaper);
    _grain(canvas, size, texture);
  }

  /// Paper grain: two tiled speckle passes (dark + light) baked at startup.
  static void _grain(Canvas canvas, Size size, double strength) {
    if (strength <= 0.01) return;
    final a = EngineAssets.instance;
    final double tileSize = 256.0 * _s(size);
    final double opacity = 0.18 + 0.45 * strength;
    final paint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, opacity)
      ..filterQuality = FilterQuality.low;
    final src = Rect.fromLTWH(0, 0, 256, 256);
    for (double y = 0; y < size.height; y += tileSize) {
      for (double x = 0; x < size.width; x += tileSize) {
        final dst = Rect.fromLTWH(x, y, tileSize, tileSize);
        canvas.drawImageRect(a.grainDark, src, dst, paint);
        canvas.drawImageRect(a.grainLight, src, dst, paint);
      }
    }
  }


  static double _smoothstep(double t) => t * t * (3 - 2 * t);

  // --------------------------------------------------------------- template 1

  static void _solidGrain(
      Canvas canvas, Size size, WallpaperSpec spec, Color primary,
      Color secondary) {
    canvas.drawRect(Offset.zero & size, Paint()..color = primary);
    _grain(canvas, size, spec.texture);
    // 十芒星：两个正五边形交叠（错开 36°）
    final double r = size.width * (0.10 + 0.20 * spec.intensity);
    final center =
        Offset(spec.anchorX * size.width, spec.anchorY * size.height);
    final starPaint = Paint()..color = secondary;
    canvas.drawPath(_polygonPath(center, r, 5, -90), starPaint);
    canvas.drawPath(_polygonPath(center, r, 5, -54), starPaint);
  }

  /// 以 center 为心、r 为外接圆半径的正多边形，rotationDeg 为首顶点角度。
  static Path _polygonPath(
      Offset center, double r, int sides, double rotationDeg) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final double a =
          rotationDeg * math.pi / 180 + i * 2 * math.pi / sides;
      final x = center.dx + r * math.cos(a);
      final y = center.dy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  // --------------------------------------------------------------- template 2

  static void _duoGradient(Canvas canvas, Size size, WallpaperSpec spec,
      Color primary, Color secondary) {
    const int stops = 9;
    final colors = <Color>[];
    final stopsList = <double>[];
    for (int i = 0; i <= stops; i++) {
      final t = i / stops;
      colors.add(Color.lerp(secondary, primary, _smoothstep(t))!);
      stopsList.add(t);
    }
    final rect = Offset.zero & size;
    // 方案：0 竖向 / 1 对角 / 2 横向
    final (begin, end) = switch (spec.scheme) {
      1 => (Alignment.topLeft, Alignment.bottomRight),
      2 => (Alignment.centerLeft, Alignment.centerRight),
      _ => (Alignment.topCenter, Alignment.bottomCenter),
    };
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          stops: stopsList,
        ).createShader(rect),
    );
    _grain(canvas, size, spec.texture);
  }

  // --------------------------------------------------------------- template 3
  // 松：三层叠塔三角 + 一截树干，东方松的极简轮廓。

  static void _pine(
      Canvas canvas, Size size, WallpaperSpec spec, Color primary,
      Color secondary) {
    // 方案：0 剪影（主色底、第二色的树）/ 1 实体（第二色底、主色树）/ 2 双拼
    switch (spec.scheme) {
      case 1:
        canvas.drawRect(Offset.zero & size, Paint()..color = secondary);
        _paintTree(canvas, size, spec, primary);
        _grain(canvas, size, spec.texture);
        break;
      case 2:
        canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height * 0.55),
            Paint()..color = primary);
        canvas.drawRect(
            Rect.fromLTWH(
                0, size.height * 0.55, size.width, size.height * 0.45),
            Paint()..color = Color.lerp(primary, kInkDark, 0.4)!);
        _paintTree(canvas, size, spec, secondary);
        _grain(canvas, size, spec.texture);
        break;
      default:
        canvas.drawRect(Offset.zero & size, Paint()..color = primary);
        _paintTree(canvas, size, spec, secondary);
        _grain(canvas, size, spec.texture);
    }
  }


  /// 三层叠塔三角 + 一截树干（树干与树冠同色）。
  static void _paintTree(Canvas canvas, Size size, WallpaperSpec spec,
      Color treeColor) {
    final double cx = spec.anchorX * size.width;
    final double k = 0.75 + 0.5 * spec.intensity;
    final paint = Paint()..color = treeColor;

    // [宽度系数, 高度系数]，三层逐级放大、层间微叠
    const tiers = [
      [0.34, 0.150],
      [0.52, 0.150],
      [0.72, 0.155],
    ];
    double baseY = spec.anchorY * size.height;
    for (final t in tiers) {
      final double w = size.width * t[0] * k;
      final double h = size.height * t[1] * k;
      final path = Path()
        ..moveTo(cx, baseY)
        ..lineTo(cx - w / 2, baseY + h)
        ..lineTo(cx + w / 2, baseY + h)
        ..close();
      canvas.drawPath(path, paint);
      baseY += h - size.height * 0.012 * k;
    }
    // 树干
    final double trunkW = size.width * 0.05 * k;
    final double trunkH = size.height * 0.20 * k;
    canvas.drawRect(
      Rect.fromLTWH(
          cx - trunkW / 2, baseY - size.height * 0.01 * k, trunkW, trunkH),
      Paint()..color = treeColor,
    );
  }

  // --------------------------------------------------------------- template 4
  // 云染：层叠的清晰色块，同色系深浅交替，如云层堆叠。

  static void _cloudDye(
      Canvas canvas, Size size, WallpaperSpec spec, Color primary,
      Color secondary, Color third) {
    // 色块外的背景 = 第三色
    canvas.drawRect(Offset.zero & size, Paint()..color = third);
    _grain(canvas, size, spec.texture);
    final s = _s(size);
    final int bands = 3 + (spec.intensity * 1.99).round(); // 3..4
    final double bandW = size.width * 0.82;
    final double bandH = size.height * 0.115;
    final double gap = size.height * 0.055;
    final double totalH = bands * bandH + (bands - 1) * gap;
    final double startY = (spec.anchorY * size.height - totalH / 2)
        .clamp(size.height * 0.05, size.height - totalH - size.height * 0.05);
    // 色调序列：第二色与主色交替，不做自动过渡
    final tones = [secondary, primary];

    // 方案 1：竖列 —— 竖向色条并排
    if (spec.scheme == 1) {
      final double barH = size.height * 0.50;
      final double vGap = size.width * 0.045;
      final double barW = (size.width * 0.82 - (bands - 1) * vGap) / bands;
      final double top = (spec.anchorY * size.height - barH / 2)
          .clamp(size.height * 0.06, size.height - barH - size.height * 0.06);
      final double left = (size.width - size.width * 0.82) / 2;
      for (int i = 0; i < bands; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(left + i * (barW + vGap), top, barW, barH),
            Radius.circular(4 * s),
          ),
          Paint()..color = tones[i % tones.length],
        );
      }
      return;
    }

    // 方案 2：方格 —— 2×2 方块阵
    if (spec.scheme == 2) {
      final double sq = size.width * 0.34;
      final double g = size.width * 0.05;
      final double cx = size.width / 2;
      final double cy = (spec.anchorY * size.height)
          .clamp(sq + g, size.height - sq - g);
      final origins = [
        Offset(cx - sq - g / 2, cy - sq - g / 2),
        Offset(cx + g / 2, cy - sq - g / 2),
        Offset(cx - sq - g / 2, cy + g / 2),
        Offset(cx + g / 2, cy + g / 2),
      ];
      for (int i = 0; i < 4; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(origins[i].dx, origins[i].dy, sq, sq),
            Radius.circular(4 * s),
          ),
          Paint()..color = tones[i % tones.length],
        );
      }
      return;
    }

    // 方案 0：横叠（默认）
    for (int i = 0; i < bands; i++) {
      final double y = startY + i * (bandH + gap);
      final double xOff = (i.isOdd ? 1 : -1) * size.width * 0.02;
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2 + xOff, y + bandH / 2),
        width: bandW,
        height: bandH,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(4 * s)),
        Paint()..color = tones[i % tones.length],
      );
    }
  }

  // --------------------------------------------------------------- template 5
  // 几何：折线把画面切成两侧色块，线行其上，如山脊分界。

  static void _zigzag(
      Canvas canvas, Size size, WallpaperSpec spec, Color primary,
      Color secondary) {
    _paper(canvas, size, spec.texture);
    final s = _s(size);
    final int lines = 1 + (spec.intensity * 2.99).round(); // 1..3 条平行线

    Paint linePaint(int i) => Paint()
      ..color = kInkDark.withOpacity(i == 0 ? 0.85 : 0.45 / i)
      ..strokeWidth = (i == 0 ? 2.4 : 1.4) * s;

    // 方案 1：左右 —— 垂直分界，左侧主色、右侧浅化
    if (spec.scheme == 1) {
      final double splitX = spec.anchorX * size.width;
      canvas.drawRect(Rect.fromLTWH(0, 0, splitX, size.height),
          Paint()..color = primary);
      canvas.drawRect(
          Rect.fromLTWH(splitX, 0, size.width - splitX, size.height),
          Paint()..color = secondary);
      for (int i = 0; i < lines; i++) {
        canvas.drawLine(Offset(splitX + i * 12 * s, 0),
            Offset(splitX + i * 12 * s, size.height), linePaint(i));
      }
      _grain(canvas, size, spec.texture * 0.7);
      return;
    }

    // 方案 2：上下 —— 水平分层，上层主色、下层浅化
    if (spec.scheme == 2) {
      final double splitY = spec.anchorY * size.height;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, splitY),
          Paint()..color = primary);
      canvas.drawRect(
          Rect.fromLTWH(0, splitY, size.width, size.height - splitY),
          Paint()..color = secondary);
      for (int i = 0; i < lines; i++) {
        canvas.drawLine(Offset(0, splitY + i * 12 * s),
            Offset(size.width, splitY + i * 12 * s), linePaint(i));
      }
      _grain(canvas, size, spec.texture * 0.7);
      return;
    }

    // 方案 0：斜切（默认）
    final double midY = spec.anchorY * size.height;
    final double dx = (spec.anchorX - 0.5) * size.width * 0.4;
    final p0 = Offset(size.width * 0.62 + dx, -size.height * 0.02);
    final p1 = Offset(size.width * 0.04, midY - size.height * 0.12);
    final p2 = Offset(size.width * 0.96, midY + size.height * 0.10);
    final p3 = Offset(size.width * 0.38 + dx, size.height * 1.02);

    // 折线两侧的色块填充：左侧主色、右侧浅化
    final left = Path()
      ..moveTo(0, p0.dy)
      ..lineTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(0, p3.dy)
      ..close();
    final right = Path()
      ..moveTo(size.width, p0.dy)
      ..lineTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(size.width, p3.dy)
      ..close();
    canvas.drawPath(left, Paint()..color = primary);
    canvas.drawPath(right, Paint()..color = secondary);

    // 折线本体 + 平行副线
    final line = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy);
    for (int i = 0; i < lines; i++) {
      canvas.save();
      canvas.translate(0, i * 12 * s);
      canvas.drawPath(
        line,
        Paint()
          ..color = kInkDark.withOpacity(i == 0 ? 0.85 : 0.45 / i)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (i == 0 ? 2.4 : 1.4) * s
          ..strokeJoin = StrokeJoin.miter,
      );
      canvas.restore();
    }
    _grain(canvas, size, spec.texture * 0.7);
  }

  // --------------------------------------------------------------- template 6
  // 点缀：可调底色之上密布第二色小圆点阵，点阵范围按方案排布。

  static void _frames(
      Canvas canvas, Size size, WallpaperSpec spec, Color accent,
      Color secondary, Color third) {
    // 框外背景 = 第三色
    canvas.drawRect(Offset.zero & size, Paint()..color = third);
    _grain(canvas, size, spec.texture);
    // 点阵范围。方案：0 居中 / 1 偏置（点阵右移）/ 2 满版（近满出血）
    Rect frame;
    switch (spec.scheme) {
      case 1:
        frame = Rect.fromCenter(
          center: Offset(size.width * 0.62, spec.anchorY * size.height),
          width: size.width * 0.78,
          height: size.height * 0.66,
        );
        break;
      case 2:
        frame = Rect.fromLTWH(size.width * 0.06, size.height * 0.045,
            size.width * 0.88, size.height * 0.91);
        break;
      default:
        frame = Rect.fromCenter(
          center: Offset(size.width * 0.5, spec.anchorY * size.height),
          width: size.width * 0.86,
          height: size.height * 0.72,
        );
    }
    // 小圆点阵（第二色）：浓淡控制点径、横向控制点距，范围内居中排布
    final double spacing = size.width * (0.060 + 0.08 * spec.anchorX);
    final double dotR = size.width * 0.032 * (0.7 + 0.6 * spec.intensity);
    final double inset = spacing * 0.55;
    final Rect area = Rect.fromLTRB(
      frame.left + inset,
      frame.top + inset,
      frame.right - inset,
      frame.bottom - inset,
    );
    if (area.width > 0 && area.height > 0) {
      final dotPaint = Paint()..color = secondary;
      final int cols = math.max(1, (area.width / spacing).floor());
      final int rows = math.max(1, (area.height / spacing).floor());
      final double startX = area.center.dx - (cols - 1) * spacing / 2;
      final double startY = area.center.dy - (rows - 1) * spacing / 2;
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          canvas.drawCircle(
              Offset(startX + c * spacing, startY + r * spacing),
              dotR, dotPaint);
        }
      }
    }
  }
}
