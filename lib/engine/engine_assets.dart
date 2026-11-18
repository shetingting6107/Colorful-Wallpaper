import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'noise.dart';

/// Textures baked once at startup: paper grain, ink-blot masks, seal distress.
/// Runtime painting only draws images — zero per-frame pixel work.
class EngineAssets {
  EngineAssets._();

  static EngineAssets? _instance;
  static EngineAssets get instance {
    final i = _instance;
    assert(i != null, 'EngineAssets.load() must complete before painting');
    return i!;
  }

  static bool get isReady => _instance != null;

  late final ui.Image grainLight; // white specks (alpha = brightness above mid)
  late final ui.Image grainDark;  // black specks (alpha = darkness below mid)
  late final List<ui.Image> blots; // 3 ink-blot alpha masks (white rgb)
  late final ui.Image sealNoise;   // distress mask for the seal template

  /// Generates all textures. Call once in main() before runApp.
  static Future<EngineAssets> load() async {
    final existing = _instance;
    if (existing != null) return existing;
    final a = EngineAssets._();
    final tiles = await _grainTiles();
    a.grainLight = tiles.$1;
    a.grainDark = tiles.$2;
    a.blots = await Future.wait([
      _blotMask(edge: 1.7, stretch: 1.25, seed: 11),
      _blotMask(edge: 1.9, stretch: 1.10, seed: 19),
      _blotMask(edge: 1.5, stretch: 1.35, seed: 31),
    ]);
    a.sealNoise = await _sealMask();
    _instance = a;
    return a;
  }

  static Future<ui.Image> _toImage(Uint8List rgba, int w, int h) {
    final c = Completer<ui.Image>();
    ui.decodeImageFromPixels(rgba, w, h, ui.PixelFormat.rgba8888, c.complete);
    return c.future;
  }

  static const int _grainSize = 256;

  /// Builds both grain tiles from one shared brightness field, so the dark
  /// and light speckles line up like real paper texture.
  static Future<(ui.Image, ui.Image)> _grainTiles() async {
    final n = ValueNoise(101);
    final rnd = math.Random(7);
    final light = Uint8List(_grainSize * _grainSize * 4);
    final dark = Uint8List(_grainSize * _grainSize * 4);
    for (int y = 0; y < _grainSize; y++) {
      for (int x = 0; x < _grainSize; x++) {
        // per-pixel white noise + low-frequency paper mottling
        final mottle = (n.fbm(x / 42.0, y / 42.0, octaves: 3) - 0.5) * 52.0;
        final g = 128.0 + (rnd.nextDouble() * 2 - 1) * 34.0 + mottle;
        final i = (y * _grainSize + x) * 4;
        light[i] = 255; light[i + 1] = 255; light[i + 2] = 255;
        light[i + 3] = ((g - 128.0).clamp(0.0, 255.0) * 1.35).round().clamp(0, 255).toInt();
        dark[i] = 0; dark[i + 1] = 0; dark[i + 2] = 0;
        dark[i + 3] = ((128.0 - g).clamp(0.0, 255.0) * 1.35).round().clamp(0, 255).toInt();
      }
    }
    return (
      await _toImage(light, _grainSize, _grainSize),
      await _toImage(dark, _grainSize, _grainSize),
    );
  }

  static const int _blotSize = 384;

  /// One ink-blot alpha mask: steep radial falloff with a fractal "bite" edge
  /// and fibrous interior, mirroring the Python prototype's blot().
  static Future<ui.Image> _blotMask({
    required double edge,
    required double stretch,
    required int seed,
  }) async {
    final nEdge = ValueNoise(seed);
    final nFiber = ValueNoise(seed + 100);
    const int s = _blotSize;
    const double cx = s / 2, cy = s / 2, R = s * 0.40;
    const double fiber = 0.55;
    final px = Uint8List(s * s * 4);
    for (int y = 0; y < s; y++) {
      for (int x = 0; x < s; x++) {
        final dx = (x - cx) / R;
        final dy = (y - cy) / (R * stretch);
        final r = math.sqrt(dx * dx + dy * dy);
        final ne = nEdge.fbm(x / s * 6.0, y / s * 6.0, octaves: 5);
        var a = (1.05 - r * (0.45 + edge * ne)).clamp(0.0, 1.0);
        a = math.pow(a, 1.6).toDouble();
        final nf = nFiber.fbm(x / s * 28.0, y / s * 28.0, octaves: 3);
        a *= (1.0 - fiber + fiber * nf * 2.0).clamp(0.0, 1.0);
        final i = (y * s + x) * 4;
        px[i] = 255; px[i + 1] = 255; px[i + 2] = 255;
        px[i + 3] = (a * 255).round().clamp(0, 255).toInt();
      }
    }
    return _toImage(px, s, s);
  }

  static Future<ui.Image> _sealMask() async {
    final n = ValueNoise(77);
    const int s = _blotSize;
    final px = Uint8List(s * s * 4);
    for (int y = 0; y < s; y++) {
      for (int x = 0; x < s; x++) {
        final v = n.fbm(x / s * 7.0, y / s * 7.0, octaves: 5);
        var a = ((v - 0.32) * 3.2).clamp(0.0, 1.0);
        a = math.pow(a, 1.2).toDouble();
        final i = (y * s + x) * 4;
        px[i] = 255; px[i + 1] = 255; px[i + 2] = 255;
        px[i + 3] = (a * 255).round().clamp(0, 255).toInt();
      }
    }
    return _toImage(px, s, s);
  }
}
