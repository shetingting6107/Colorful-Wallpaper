import 'package:flutter/painting.dart' show Offset;

/// The six parametric wallpaper templates.
enum TemplateType {
  solidGrain,  // 纸纹纯色
  duoGradient, // 双色渐变
  pine,        // 松（三层叠三角 + 树干）
  cloudDye,    // 云染（层叠柔边色块）
  zigzag,      // 几何（折线构图）
  frames,      // 点缀（嵌套画框 + 色块点缀）
}

const List<String> kTemplateLabels = [
  '纸纹纯色',
  '双色渐变',
  '松',
  '云染',
  '几何',
  '点缀',
];

/// 每个模板的构图/填充方案（方案 0 为默认）。
const Map<TemplateType, List<String>> kTemplateSchemes = {
  TemplateType.solidGrain: ['纯色'],
  TemplateType.duoGradient: ['竖向', '对角', '横向'],
  TemplateType.pine: ['剪影', '实体', '双拼'],
  TemplateType.cloudDye: ['横叠', '竖列', '方格'],
  TemplateType.zigzag: ['斜切', '左右', '上下'],
  TemplateType.frames: ['居中', '偏置', '满框'],
};

const Map<TemplateType, String> templeAssetMap = {
  TemplateType.solidGrain: 'assets/template_preview/solidGrain.jpg',
  TemplateType.duoGradient: 'assets/template_preview/duoGradient.jpg',
  TemplateType.pine: 'assets/template_preview/pine.jpg',
  TemplateType.cloudDye: 'assets/template_preview/cloudDye.jpg',
  TemplateType.zigzag:'assets/template_preview/zigzag.jpg',
  TemplateType.frames: 'assets/template_preview/frames.jpg',
};

/// Everything needed to deterministically render one wallpaper.
class WallpaperSpec {
  String colorId;
  String secondaryColorId;

  /// 第三色：松的月轮、云染的过渡块、点缀的圆点。
  String thirdColorId;
  TemplateType template;

  /// Paper-grain strength, 0..1.
  double texture;

  /// Ink density / element weight, 0..1.
  double intensity;

  /// Main element anchor, each axis 0..1.
  double anchorX;
  double anchorY;

  /// 构图/填充方案索引，对应 kTemplateSchemes。
  int scheme;

  WallpaperSpec({
    required this.colorId,
    this.secondaryColorId = 'yuebai',
    this.thirdColorId = 'minghuang',
    this.template = TemplateType.solidGrain,
    this.texture = 0.5,
    this.intensity = 0.6,
    this.anchorX = 0.46,
    this.anchorY = 0.40,
    this.scheme = 0,
  });

  Offset get anchor => Offset(anchorX, anchorY);

  WallpaperSpec copy() => WallpaperSpec(
        colorId: colorId,
        secondaryColorId: secondaryColorId,
        thirdColorId: thirdColorId,
        template: template,
        texture: texture,
        intensity: intensity,
        anchorX: anchorX,
        anchorY: anchorY,
        scheme: scheme,
      );

  Map<String, dynamic> toJson() => {
        'colorId': colorId,
        'secondaryColorId': secondaryColorId,
        'thirdColorId': thirdColorId,
        'template': template.index,
        'texture': texture,
        'intensity': intensity,
        'anchorX': anchorX,
        'anchorY': anchorY,
        'scheme': scheme,
      };

  factory WallpaperSpec.fromJson(Map<String, dynamic> j) => WallpaperSpec(
        colorId: j['colorId'] as String,
        secondaryColorId: j['secondaryColorId'] as String? ?? 'yuebai',
        thirdColorId: j['thirdColorId'] as String? ?? 'minghuang',
        template: TemplateType.values[(j['template'] as num).toInt()],
        texture: (j['texture'] as num).toDouble(),
        intensity: (j['intensity'] as num).toDouble(),
        anchorX: (j['anchorX'] as num).toDouble(),
        anchorY: (j['anchorY'] as num).toDouble(),
        scheme: (j['scheme'] as num?)?.toInt() ?? 0,
      );
}
