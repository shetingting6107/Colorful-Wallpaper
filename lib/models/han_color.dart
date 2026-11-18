import 'dart:ui';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

/// One entry of the traditional Chinese color library (assets/colors.json).
class HanColor {
  final String id;
  final String family;
  final String nameZh;
  final String pinyin;
  final String nameEn;
  final String hex;
  final String noteEn;
  final String noteZh;

  const HanColor({
    required this.id,
    required this.family,
    required this.nameZh,
    required this.pinyin,
    required this.nameEn,
    required this.hex,
    required this.noteEn,
    required this.noteZh,
  });

  factory HanColor.fromJson(Map<String, dynamic> j) => HanColor(
        id: j['id'] as String,
        family: j['family'] as String,
        nameZh: j['nameZh'] as String,
        pinyin: j['pinyin'] as String,
        nameEn: j['nameEn'] as String,
        hex: j['hex'] as String,
        noteEn: j['noteEn'] as String,
        noteZh: j['noteZh'] as String,
      );

  Color get color =>
      Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
}

class ColorFamily {
  final String id;
  final String zh;
  final String en;
  const ColorFamily({required this.id, required this.zh, required this.en});

  factory ColorFamily.fromJson(Map<String, dynamic> j) =>
      ColorFamily(id: j['id'] as String, zh: j['zh'] as String, en: j['en'] as String);
}

class ColorRepository {
  final List<ColorFamily> families;
  final List<HanColor> colors;

  const ColorRepository({required this.families, required this.colors});

  HanColor byId(String id) => colors.firstWhere((c) => c.id == id,
      orElse: () => colors.first);

  List<HanColor> ofFamily(String familyId) =>
      colors.where((c) => c.family == familyId).toList();

  static Future<ColorRepository> load() async {
    final raw = await rootBundle.loadString('assets/colors.json');
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return ColorRepository(
      families: (j['families'] as List)
          .map((e) => ColorFamily.fromJson(e as Map<String, dynamic>))
          .toList(),
      colors: (j['colors'] as List)
          .map((e) => HanColor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
