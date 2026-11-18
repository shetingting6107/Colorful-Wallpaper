import 'package:flutter/material.dart';

import 'engine/engine_assets.dart';
import 'models/han_color.dart';
import 'ui/showcase_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EngineAssets.load(); // bake grain / ink / seal textures once
  final repo = await ColorRepository.load();
  runApp(HanColorsApp(repo: repo));
}

class HanColorsApp extends StatelessWidget {
  final ColorRepository repo;
  const HanColorsApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Han Colors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAF7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE63E21), // 朱砂
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFAF7),
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
      ),
      home: ShowcasePage(repo: repo),
    );
  }
}
