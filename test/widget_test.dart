import 'package:flutter_test/flutter_test.dart';
import 'package:han_colors/models/wallpaper_spec.dart';

void main() {
  test('WallpaperSpec json round-trip keeps every field', () {
    final s = WallpaperSpec(
      colorId: 'tianqing',
      secondaryColorId: 'yuebai',
      template: TemplateType.pine,
      texture: 0.8,
      intensity: 0.4,
      anchorX: 0.3,
      anchorY: 0.7,
    );
    final r = WallpaperSpec.fromJson(s.toJson());
    expect(r.colorId, 'tianqing');
    expect(r.secondaryColorId, 'yuebai');
    expect(r.template, TemplateType.pine);
    expect(r.texture, 0.8);
    expect(r.intensity, 0.4);
    expect(r.anchorX, 0.3);
    expect(r.anchorY, 0.7);
  });

  test('WallpaperSpec defaults are sane', () {
    final s = WallpaperSpec(colorId: 'zhusha');
    expect(s.secondaryColorId, 'yuebai');
    expect(s.template, TemplateType.solidGrain);
    expect(s.texture, inInclusiveRange(0, 1));
  });
}
