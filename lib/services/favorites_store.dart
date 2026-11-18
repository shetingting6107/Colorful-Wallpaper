import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/wallpaper_spec.dart';

/// Favorites persisted locally via SharedPreferences (JSON list).
class FavoritesStore {
  static const String _key = 'han_colors_favorites';

  static Future<List<WallpaperSpec>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const <String>[];
    return raw
        .map((s) =>
            WallpaperSpec.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> _saveAll(List<WallpaperSpec> specs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, specs.map((s) => jsonEncode(s.toJson())).toList());
  }

  static String _fingerprint(WallpaperSpec s) => jsonEncode(s.toJson());

  static Future<bool> isFavorite(WallpaperSpec spec) async {
    final all = await load();
    final fp = _fingerprint(spec);
    return all.any((s) => _fingerprint(s) == fp);
  }

  /// Toggles [spec]; returns the updated list (and whether it was added).
  static Future<(List<WallpaperSpec>, bool)> toggle(
      WallpaperSpec spec) async {
    final all = await load();
    final fp = _fingerprint(spec);
    final idx = all.indexWhere((s) => _fingerprint(s) == fp);
    final bool added;
    if (idx >= 0) {
      all.removeAt(idx);
      added = false;
    } else {
      all.insert(0, spec.copy());
      added = true;
    }
    await _saveAll(all);
    return (all, added);
  }

  static Future<void> remove(WallpaperSpec spec) async {
    final all = await load();
    final fp = _fingerprint(spec);
    all.removeWhere((s) => _fingerprint(s) == fp);
    await _saveAll(all);
  }
}
