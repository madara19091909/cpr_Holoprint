import 'package:flutter/material.dart';

import '../services/history_store.dart';
import '../widgets/cpr_logo.dart';
import 'converter_page.dart';
import 'home_page.dart';
import 'library_page.dart';
import 'settings_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  int _historyRevision = 0;

  static const _titles = [
    'الرئيسية',
    'محرك التحويل',
    'مكتبتي',
    'الإعدادات',
  ];

  void _openConverter() => setState(() => _selectedIndex = 1);

  void _onExportSaved() {
    setState(() => _historyRevision++);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        key: ValueKey('home-$_historyRevision'),
        onOpenConverter: _openConverter,
        historyRevision: _historyRevision,
      ),
      ConverterPage(onExportSaved: _onExportSaved),
      LibraryPage(key: ValueKey('library-$_historyRevision')),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const CprLogo(size: 34),
            const SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CPR Holoprint',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.1,
                      ),
                ),
                Text(
                  _titles[_selectedIndex],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'التحويل',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'المكتبة',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
