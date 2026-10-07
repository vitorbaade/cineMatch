import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'breakpoints.dart';

class AdaptiveScaffold extends StatelessWidget {
  final String currentRoute;
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AdaptiveScaffold({
    super.key,
    required this.currentRoute,
    required this.body,
    required this.title,
    this.actions,
    this.floatingActionButton,
  });

  static const _tabs = ['/', '/roulette', '/my-list'];
  static const _destinations = [
    (icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Início'),
    (icon: Icons.casino_outlined, selectedIcon: Icons.casino_rounded, label: 'CineMatch'),
    (icon: Icons.bookmark_outline_rounded, selectedIcon: Icons.bookmark_rounded, label: 'Minha Lista'),
  ];

  int get _currentIndex {
    final index = _tabs.indexOf(currentRoute);
    return index == -1 ? 0 : index;
  }

  void _onSelect(BuildContext context, int index) {
    final target = _tabs[index];
    if (target == currentRoute) return;
    Navigator.of(context).pushReplacementNamed(target);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isTablet(context);
    final isDesktop = Breakpoints.isDesktop(context);

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
        child: body,
      ),
    );

    if (!isTablet) {
      return Scaffold(
        appBar: AppBar(title: Text(title), actions: actions),
        body: SafeArea(child: content),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => _onSelect(context, i),
          items: [
            for (final d in _destinations) BottomNavigationBarItem(icon: Icon(d.icon), label: d.label),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.surface,
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => _onSelect(context, i),
              extended: isDesktop,
              minExtendedWidth: 210,
              labelType: isDesktop ? NavigationRailLabelType.none : NavigationRailLabelType.selected,
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
