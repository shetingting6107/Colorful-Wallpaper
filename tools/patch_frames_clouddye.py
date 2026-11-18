# -*- coding: utf-8 -*-
"""重写点缀模板 + 云染背景改第三色。"""
import io, sys

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

ENGINE = r'E:\uiapp\uiapp\lib\engine\wallpaper_engine.dart'
EDITOR = r'E:\uiapp\uiapp\lib\ui\editor_page.dart'


def patch(path, pairs):
    with open(path, 'r', encoding='utf-8') as f:
        s = f.read()
    for old, new in pairs:
        assert old in s, f'NOT FOUND in {path}:\n{old[:120]}'
        assert s.count(old) == 1, f'NOT UNIQUE in {path}:\n{old[:120]}'
        s = s.replace(old, new)
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(s)
    print(f'patched {path}: {len(pairs)} edits')


# ---------------------------------------------------------------- engine
cloud_old = """      Color secondary, Color third) {
    _paper(canvas, size, spec.texture);
    final s = _s(size);
    final int bands = 3 + (spec.intensity * 1.99).round(); // 3..4"""
cloud_new = """      Color secondary, Color third) {
    // 色块外的背景 = 第三色
    canvas.drawRect(Offset.zero & size, Paint()..color = third);
    _grain(canvas, size, spec.texture);
    final s = _s(size);
    final int bands = 3 + (spec.intensity * 1.99).round(); // 3..4"""

tones_old = """    // 色调序列：第二色起、第三色承、主色转、第二色浅化合
    final tones = [
      secondary,
      third,
      primary,
      Color.lerp(secondary, kPaper, 0.35)!,
    ];"""
tones_new = """    // 色调序列：第二色起、与主色过渡、主色转、第二色浅化合
    final tones = [
      secondary,
      Color.lerp(secondary, primary, 0.5)!,
      primary,
      Color.lerp(secondary, kPaper, 0.35)!,
    ];"""

frames_old = """  // --------------------------------------------------------------- template 6
  // 点缀：嵌套画框层层递进，框内一枚小小的色块点缀。

  static void _frames(
      Canvas canvas, Size size, WallpaperSpec spec, Color accent,
      Color secondary, Color third) {
    _paper(canvas, size, spec.texture);
    final s = _s(size);
    final frameColor = Color.lerp(kInkDark, kPaper, 0.35)!;
    // 单框。方案：0 居中 / 1 偏置（画框右移）/ 2 满框（近满出血）
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
    // 框内第二色填充 + 边线（浓淡控制线宽）
    canvas.drawRect(frame, Paint()..color = secondary);
    canvas.drawRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.2 + 3.0 * spec.intensity) * s
        ..color = frameColor.withOpacity(0.85),
    );
    // 框内点缀：主色小方块 + 第三色小圆点
    final double sq = size.width * 0.05;
    final double ax = frame.center.dx +
        (spec.anchorX - 0.5) * frame.width * 0.6;
    final double ay = frame.top + frame.height * 0.28;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(ax, ay), width: sq, height: sq),
      Paint()..color = accent,
    );
    canvas.drawCircle(
      Offset(ax, ay + sq * 2.2),
      sq * 0.22,
      Paint()..color = third.withOpacity(0.9),
    );
  }"""

frames_new = """  // --------------------------------------------------------------- template 6
  // 点缀：可调底色之上一枚主色描边方框，框内密布第二色小圆点阵。

  static void _frames(
      Canvas canvas, Size size, WallpaperSpec spec, Color accent,
      Color secondary, Color third) {
    // 框外背景 = 第三色
    canvas.drawRect(Offset.zero & size, Paint()..color = third);
    _grain(canvas, size, spec.texture);
    final s = _s(size);
    // 单框。方案：0 居中 / 1 偏置（画框右移）/ 2 满框（近满出血）
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
    // 主色描边方框（浓淡控制线宽），框内不再填充
    final double stroke = (1.2 + 3.0 * spec.intensity) * s;
    canvas.drawRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = accent,
    );
    // 框内小圆点阵（第二色）：浓淡控制点径，在框内居中排布
    final double spacing = size.width * 0.062;
    final double dotR = size.width * 0.011 * (0.7 + 0.6 * spec.intensity);
    final double inset = stroke / 2 + spacing * 0.55;
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
  }"""

patch(ENGINE, [(cloud_old, cloud_new), (tones_old, tones_new),
               (frames_old, frames_new)])

# ---------------------------------------------------------------- editor
anchorx_old = """  bool get _usesAnchorX =>
      spec.template == TemplateType.solidGrain ||
      spec.template == TemplateType.pine ||
      spec.template == TemplateType.zigzag ||
      spec.template == TemplateType.frames;"""
anchorx_new = """  bool get _usesAnchorX =>
      spec.template == TemplateType.solidGrain ||
      spec.template == TemplateType.pine ||
      spec.template == TemplateType.zigzag;"""

third_comment_old = "  /// 第三色：云染的过渡块、点缀的圆点。"
third_comment_new = "  /// 第三色：云染与点缀框外的背景底色。"

patch(EDITOR, [(anchorx_old, anchorx_new),
               (third_comment_old, third_comment_new)])

print('ALL OK')
