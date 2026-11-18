import 'package:flutter/material.dart';

import '../engine/wallpaper_painter.dart';
import '../models/han_color.dart';
import '../models/wallpaper_spec.dart';
import '../services/favorites_store.dart';
import 'editor_page.dart';

/// Saved wallpaper compositions; tap to reopen in the editor.
class FavoritesPage extends StatefulWidget {
  final ColorRepository repo;
  const FavoritesPage({super.key, required this.repo});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<WallpaperSpec> _items = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final items = await FavoritesStore.load();
    if (mounted) {
      setState(() {
        _items = items;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text('还没有收藏\n在编辑器里点红心即可收藏',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF8A8A8A))))
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1170 / 2532,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final spec = _items[i];
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditorPage(
                              repo: widget.repo,
                              initialSpec: spec,
                            ),
                          ),
                        );
                        _reload();
                      },
                      onLongPress: () => _confirmDelete(spec),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CustomPaint(
                          painter: WallpaperPainter(spec, widget.repo),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _confirmDelete(WallpaperSpec spec) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline),
          title: const Text('从收藏中移除'),
          onTap: () async {
            Navigator.pop(context);
            await FavoritesStore.remove(spec);
            _reload();
          },
        ),
      ),
    );
  }
}
