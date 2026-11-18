import '../models/wallpaper_spec.dart';

/// 首页精选：手工调校的「颜色 × 模板 × 参数」组合。
/// 每一项都是可直接渲染、也可进入编辑器继续微调的完整规格。
final List<WallpaperSpec> kPresets = [
  // 朱砂 · 点缀（米白底 · 红框红点阵）
  WallpaperSpec(
      colorId: 'zhusha',
      secondaryColorId: 'zhusha',
      thirdColorId: 'mibai',
      template: TemplateType.frames,
      texture: 0.55,
      intensity: 0.6,
      anchorX: 0.5,
      anchorY: 0.40),
  // 松花绿 · 松
  WallpaperSpec(
      colorId: 'bise',
      secondaryColorId: 'songhualv',
      template: TemplateType.pine,
      texture: 0.5,
      intensity: 0.6,
      anchorX: 0.5,
      anchorY: 0.16),
  // 天青 × 月白 · 双色渐变
  WallpaperSpec(
      colorId: 'tianqing',
      secondaryColorId: 'yuebai',
      template: TemplateType.duoGradient,
      texture: 0.1),
  // 石青 · 云染（米白底）
  WallpaperSpec(
      colorId: 'shiqing',
      thirdColorId: 'mibai',
      template: TemplateType.cloudDye,
      texture: 0.5,
      intensity: 0.6,
      anchorY: 0.50),
  // 胭脂 · 几何折线
  WallpaperSpec(
      colorId: 'yanzhi',
      secondaryColorId: 'ziteng',
      template: TemplateType.zigzag,
      texture: 0.45,
      intensity: 0.6,
      anchorX: 0.5,
      anchorY: 0.5),
  // 玄色 · 点缀（米白底 · 墨框墨点阵）
  WallpaperSpec(
      colorId: 'xuanse',
      secondaryColorId: 'xuanse',
      thirdColorId: 'mibai',
      template: TemplateType.frames,
      texture: 0.5,
      intensity: 0.5,
      anchorX: 0.5,
      anchorY: 0.42),
  // 竹青 · 松
  WallpaperSpec(
      colorId: 'zhuqing',
      template: TemplateType.pine,
      texture: 0.55,
      intensity: 0.5,
      anchorX: 0.5,
      anchorY: 0.18),
  // 杏黄 × 米白 · 双色渐变
  WallpaperSpec(
      colorId: 'xinghuang',
      secondaryColorId: 'mibai',
      template: TemplateType.duoGradient,
      texture: 0.35),
  // 藏青 · 纸纹纯色
  WallpaperSpec(
      colorId: 'zangqing',
      template: TemplateType.solidGrain,
      texture: 0.65),
  // 藕荷色 · 云染（米白底）
  WallpaperSpec(
      colorId: 'ouhese',
      thirdColorId: 'mibai',
      template: TemplateType.cloudDye,
      texture: 0.45,
      intensity: 0.5,
      anchorY: 0.52),
  // 秋香色 · 几何折线
  WallpaperSpec(
      colorId: 'qiuxiangse',
      template: TemplateType.zigzag,
      texture: 0.45,
      intensity: 0.55,
      anchorX: 0.5,
      anchorY: 0.48),
  // 黛色 · 纸纹纯色
  WallpaperSpec(
      colorId: 'daise',
      template: TemplateType.solidGrain,
      texture: 0.6),
];
