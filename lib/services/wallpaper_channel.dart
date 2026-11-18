import 'package:flutter/services.dart';

/// Bridge to the native hosts:
///  - Android (MainActivity.java): WallpaperManager + MediaStore
///  - iOS (AppDelegate.swift): Photos library (wallpaper must be set manually)
class WallpaperChannel {
  static const MethodChannel _ch = MethodChannel('han.colors/wallpaper');

  /// Saves PNG bytes into the system gallery. Returns true on success.
  static Future<bool> saveToGallery(Uint8List bytes, String name) async {
    try {
      final ok = await _ch.invokeMethod<bool>(
          'saveToGallery', {'bytes': bytes, 'name': name});
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Sets the wallpaper. [target] is 'home', 'lock' or 'both'.
  /// Returns null on success, otherwise a human-readable error message
  /// (iOS always reports unsupported — save to Photos and guide the user).
  static Future<String?> setWallpaper(Uint8List bytes, String target) async {
    try {
      await _ch.invokeMethod<bool>(
          'setWallpaper', {'bytes': bytes, 'target': target});
      return null;
    } on PlatformException catch (e) {
      return e.message ?? 'Failed to set wallpaper';
    } catch (e) {
      return e.toString();
    }
  }
}
