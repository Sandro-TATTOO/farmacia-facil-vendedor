import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/dashboard'))  return 0;
    if (loc.startsWith('/orders'))     return 1;
    if (loc.startsWith('/products'))   return 2;
    if (loc.startsWith('/pharmacy'))   return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withValues(alpha: 0.15),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/dashboard'); break;
            case 1: context.go('/orders');    break;
            case 2: context.go('/products');  break;
            case 3: context.go('/pharmacy');  break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon:         Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label:        'Dashboard',
          ),
          NavigationDestination(
            icon:         Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label:        'Pedidos',
          ),
          NavigationDestination(
            icon:         Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label:        'Produtos',
          ),
          NavigationDestination(
            icon:         Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label:        'Farmácia',
          ),
        ],
      ),
    );
  }
}
