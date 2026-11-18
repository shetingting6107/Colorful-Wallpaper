/// Deterministic value-noise / fbm generator (pure Dart, no dependencies).
/// Used to bake grain and ink-bleed textures once at startup.
class ValueNoise {
  final int seed;
  const ValueNoise(this.seed);

  static int _hash(int x, int y, int seed) {
    int h = seed & 0x7fffffff;
    h = (h + x * 0x1b873593 + y * 0x9e3779b1) & 0x7fffffff;
    h = ((h ^ (h >> 13)) * 0x5bd1e995) & 0x7fffffff;
    h = h ^ (h >> 15);
    return h & 0x7fffffff;
  }

  double _lattice(int x, int y) => _hash(x, y, seed) / 0x7fffffff;

  static double _smooth(double t) => t * t * (3 - 2 * t);

  /// Value noise in [0, 1].
  double noise2(double x, double y) {
    final int xi = x.floor();
    final int yi = y.floor();
    final double xf = x - xi;
    final double yf = y - yi;
    final double a = _lattice(xi, yi);
    final double b = _lattice(xi + 1, yi);
    final double c = _lattice(xi, yi + 1);
    final double d = _lattice(xi + 1, yi + 1);
    final double u = _smooth(xf);
    final double v = _smooth(yf);
    return a + (b - a) * u + (c - a) * v + (a - b - c + d) * u * v;
  }

  /// Fractal Brownian motion in [0, 1].
  double fbm(double x, double y,
      {int octaves = 4, double gain = 0.5, double lacunarity = 2.0}) {
    double amp = 1.0, freq = 1.0, sum = 0.0, norm = 0.0;
    for (int i = 0; i < octaves; i++) {
      sum += amp * noise2(x * freq, y * freq);
      norm += amp;
      amp *= gain;
      freq *= lacunarity;
    }
    return sum / norm;
  }
}
