import 'package:flutter/material.dart';

import '../models/han_color.dart';
import '../models/wallpaper_spec.dart';
import 'editor_page.dart';
import 'favorites_page.dart';

/// Home: the 60-color library grouped by family.
class HomePage extends StatelessWidget {
  final ColorRepository repo;
  const HomePage({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('华色集',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: '收藏',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FavoritesPage(repo: repo)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '六十种中国传统色，点选其一，开始创作',
              style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 13),
            ),
          ),
          for (final f in repo.families) _familySection(context, f),
        ],
      ),
    );
  }

  Widget _familySection(BuildContext context, ColorFamily family) {
    final colors = repo.ofFamily(family.id);
    if (colors.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 12),
          child: Text(
            family.zh,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                color: Color(0xFF6B6B6B)),
          ),
        ),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final c in colors) _colorChip(context, c),
          ],
        ),
      ],
    );
  }

  Widget _colorChip(BuildContext context, HanColor c) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditorPage(
            repo: repo,
            initialSpec: WallpaperSpec(colorId: c.id),
          ),
        ),
      ),
      child: SizedBox(
        width: 56,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withOpacity(0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              c.nameZh,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF444444)),
            ),
          ],
        ),
      ),
    );
  }
}
