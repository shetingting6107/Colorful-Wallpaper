import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:han_colors/ui/fullPreview_page.dart';

import '../engine/wallpaper_engine.dart';
import '../engine/wallpaper_painter.dart';
import '../models/han_color.dart';
import '../models/wallpaper_spec.dart';
import '../services/favorites_store.dart';
import '../services/wallpaper_channel.dart';

/// Wallpaper editor: live preview + template / texture / intensity / position
/// controls + export and set-wallpaper actions.
class EditorPage extends StatefulWidget {
  final ColorRepository repo;
  final WallpaperSpec initialSpec;

  const EditorPage({super.key, required this.repo, required this.initialSpec});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late WallpaperSpec spec = widget.initialSpec.copy();
  bool _busy = false;
  bool _isFav = false;

  /// 控制区分页：0 方案 / 1 排列 / 2 颜色
  final PageController _pageCtrl = PageController(initialPage: 0);
  int _pageIndex = 0;

  ColorRepository get repo => widget.repo;

  @override
  void initState() {
    super.initState();
    FavoritesStore.isFavorite(spec).then((v) {
      if (mounted) setState(() => _isFav = v);
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _mutate(void Function() fn) => setState(fn);

  void _selectTemplate(TemplateType t) {
    _mutate(() {
      spec.template = t;
      spec.scheme = 0;
      // sensible per-template anchors
      switch (t) {
        case TemplateType.solidGrain:
          spec.anchorX = 0.50; spec.anchorY = 0.42;
          break;
        case TemplateType.pine:
          spec.anchorX = 0.50; spec.anchorY = 0.16;
          break;
        case TemplateType.cloudDye:
          spec.anchorY = 0.50;
          break;
        case TemplateType.zigzag:
          spec.anchorX = 0.50; spec.anchorY = 0.50;
          break;
        case TemplateType.frames:
          spec.anchorX = 0.50; spec.anchorY = 0.42;
          break;
        default:
          break;
      }
    });
    _pageCtrl.animateToPage(0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
    );
    setState(() {
      _pageIndex = 0;
    });
  }

  bool get _usesIntensity =>
      spec.template == TemplateType.solidGrain ||
      spec.template == TemplateType.pine ||
      spec.template == TemplateType.cloudDye ||
      spec.template == TemplateType.zigzag ||
      spec.template == TemplateType.frames;

  bool get _usesAnchorX =>
      spec.template == TemplateType.solidGrain ||
      spec.template == TemplateType.pine ||
      spec.template == TemplateType.zigzag ||
      spec.template == TemplateType.frames;

  bool get _usesAnchorY => spec.template != TemplateType.duoGradient;

  /// 第三色：云染与点缀框外的背景底色。
  bool get _usesThird =>
      spec.template == TemplateType.cloudDye ||
      spec.template == TemplateType.frames;

  @override
  Widget build(BuildContext context) {
    final color = repo.byId(spec.colorId);
    return Scaffold(
      appBar: AppBar(
        title: Text('${color.nameZh}  ${color.nameEn}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        actions: [
          IconButton(
            icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border,
                color: _isFav ? const Color(0xFFE63E21) : null),
            tooltip: '收藏',
            onPressed: _toggleFavorite,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _preview()),
            _templateStrip(),
            _controls(),
            _actions(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- preview

  Widget _preview() {
    return GestureDetector(
      onTap: () {
        //点击跳至全屏预览
        Navigator.push(
          context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => FullPreviewPage(spec: spec, repo: repo),
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (ctx, anim, _, child) {
                  return FadeTransition(opacity: anim, child: child);
              }
            ));
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: AspectRatio(
            aspectRatio: WallpaperEngine.aspect,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CustomPaint(painter: WallpaperPainter(spec, repo)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _templateStrip() {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: TemplateType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final t = TemplateType.values[i];
          final selected = spec.template == t;
          return GestureDetector(
            onTap: () => _selectTemplate(t),
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      width: selected ? 2 : 1,
                      color: selected
                          ? const Color(0xFFA97844)
                          : Colors.black.withOpacity(0.12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    // child: CustomPaint(painter: WallpaperPainter(mini, repo)),
                    child: Image.asset(templeAssetMap[t]!, fit: BoxFit.cover,),//底部样式参考图改为加载静态图片
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kTemplateLabels[i],
                  style: TextStyle(
                    fontSize: 9,
                    color: selected
                        ? const Color(0xFFA97844)
                        : const Color(0xFF8A8A8A),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------- controls

  bool get _hasSchemeTab {
    final schemes = kTemplateSchemes[spec.template] ?? const[];
    return schemes.length > 1;
  }

  List<({String label, Widget page})> _buildTabPages() {
    final List<({String label, Widget page})> tabPage = [];
    if(_hasSchemeTab) {
      tabPage.add((label: '样式', page: _schemePage()));
    }
    tabPage.add((label: '排列', page: _arrangePage()));
    tabPage.add((label: '颜色', page: _colorPage()));
    return tabPage;
  }

  Widget _controls() {
    final List<({String label, Widget page})> tabPage = _buildTabPages();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        children: [
          _controlTabs(tabPage: tabPage),
          const SizedBox(height: 6),
          SizedBox(
            height: 160,
            child: PageView(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              children: tabPage.map((e) => e.page).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 分页页签：方案 / 排列 / 颜色，选中时深色高亮，点击切换分页。
  Widget _controlTabs({required List<({String label, Widget page})> tabPage}) {
    return Row(
      children: [
        for (int i = 0; i < tabPage.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _pageCtrl.animateToPage(i,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _pageIndex == i
                      ? const Color(0xFFA97844)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _pageIndex == i
                        ? const Color(0xFFA97844)
                        : Colors.black.withOpacity(0.18),
                  ),
                ),
                child: Text(
                  tabPage[i].label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _pageIndex == i
                        ? Colors.white
                        : const Color(0xFF6B6B6B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 分页一：方案（当前模板的构图/填充方案）。
  Widget _schemePage() {
    return Column(
        children: [
          _schemeRow(),
      ],
    );
  }

  /// 分页二：排列（深浅 / 形状大小 / 横向 / 纵向）。
  Widget _arrangePage() {
    return Column(
      children: [
        _sliderRow('深浅', spec.texture,
            (v) => _mutate(() => spec.texture = v)),
        if (_usesIntensity)
          _sliderRow('形状大小', spec.intensity,
              (v) => _mutate(() => spec.intensity = v)),
        if (_usesAnchorX)
          _sliderRow(
              spec.template == TemplateType.frames ? '疏密' : '横向',
              spec.anchorX,
              (v) => _mutate(() => spec.anchorX = v)),
        if (_usesAnchorY)
          _sliderRow('纵向', spec.anchorY,
              (v) => _mutate(() => spec.anchorY = v)),
      ],
    );
  }

  /// 分页三：颜色（主色 / 第二色 / 第三色）。
  Widget _colorPage() {
    return Column(
      children: [
        _colorStrip('主色', spec.colorId,
            (id) => _mutate(() => spec.colorId = id)),
        _colorStrip('第二色', spec.secondaryColorId,
            (id) => _mutate(() => spec.secondaryColorId = id)),
        if (_usesThird)
          _colorStrip('第三色', spec.thirdColorId,
              (id) => _mutate(() => spec.thirdColorId = id)),
      ],
    );
  }

  /// 方案选择：当前模板有多个构图/填充方案时显示。
  Widget _schemeRow() {
    final schemes = kTemplateSchemes[spec.template] ?? const <String>[];
    if (schemes.length <= 1) return const SizedBox.shrink();
    final sel = spec.scheme.clamp(0, schemes.length - 1);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(
                width: 40,
                child: Text("方案",
                    style:
                    TextStyle(fontSize: 12, color: Color(0xFF6B6B6B))),
              ),

              for (int i = 0; i < schemes.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(schemes[i],
                        style: const TextStyle(fontSize: 12)),
                    selected: sel == i,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) => _mutate(() => spec.scheme = i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sliderRow(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(label,
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFF6B6B6B))),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(value: value, onChanged: onChanged),
          ),
        ),
      ],
    );
  }

  /// 第二色 / 第三色：与主色一致的抽屉式选色。
  Widget _colorStrip(
      String label, String currentId, ValueChanged<String> onPick) {
    final c = repo.byId(currentId);
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B6B6B))),
          ),
          TextButton.icon(
            onPressed: () => _pickColor(onPick),
            icon: CircleAvatar(radius: 9, backgroundColor: c.color),
            label: Text('${c.nameZh} · ${c.nameEn}',
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _pickColor(ValueChanged<String> onPick) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: repo.colors.length,
        itemBuilder: (context, i) {
          final c = repo.colors[i];
          return GestureDetector(
            onTap: () {
              onPick(c.id);
              Navigator.pop(context);
            },
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.color,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.black.withOpacity(0.06)),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(c.nameZh,
                    style: const TextStyle(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------- actions

  Widget _actions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _saveImage,
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('保存'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: _busy ? null : _chooseWallpaperTarget,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.wallpaper, size: 18),
              label: Text(_busy ? '处理中…' : '设为壁纸'),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _render() =>
      WallpaperEngine.renderPng(spec, repo);

  String get _fileName =>
      'han_colors_${spec.colorId}_${DateTime.now().millisecondsSinceEpoch}';

  Future<void> _saveImage() async {
    setState(() => _busy = true);
    try {
      final bytes = await _render();
      final ok = await WallpaperChannel.saveToGallery(bytes, _fileName);
      _toast(ok ? '已保存到相册' : '保存失败');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _chooseWallpaperTarget() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('主屏幕'),
              onTap: () => _setWallpaper('home'),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('锁屏'),
              onTap: () => _setWallpaper('lock'),
            ),
            ListTile(
              leading: const Icon(Icons.smartphone_outlined),
              title: const Text('主屏幕和锁屏'),
              onTap: () => _setWallpaper('both'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setWallpaper(String target) async {
    Navigator.pop(context); // close the sheet
    setState(() => _busy = true);
    try {
      final bytes = await _render();
      final error = await WallpaperChannel.setWallpaper(bytes, target);
      if (error == null) {
        _toast('壁纸已更新');
      } else {
        // iOS path: setting wallpaper is not allowed — save instead.
        final ok = await WallpaperChannel.saveToGallery(bytes, _fileName);
        _toast(ok
            ? '已存入相册，请在系统设置中设为壁纸'
            : error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final (_, added) = await FavoritesStore.toggle(spec);
    if (mounted) {
      setState(() => _isFav = added);
      _toast(added ? '已加入收藏' : '已取消收藏');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
