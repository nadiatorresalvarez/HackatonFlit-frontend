import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/analysis_provider.dart';
import 'screens/about_screen.dart';
import 'screens/analyze_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _titles = [
    'Inicio',
    'Analizar',
    'Mapa',
    'Info',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onStartAnalysis: () => setState(() => _index = 1)),
          const AnalyzeScreen(embedInShell: true),
          const MapScreen(),
          const AboutScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco_rounded),
            label: 'Analizar',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info_rounded),
            label: 'Info',
          ),
        ],
      ),
    );
  }
}

class TerraGuardApp extends StatelessWidget {
  const TerraGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalysisProvider()..bootstrap(),
      child: MaterialApp(
        title: 'TerraGuard Arequipa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AppShell(),
      ),
    );
  }
}
