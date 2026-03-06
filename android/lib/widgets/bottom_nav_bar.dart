import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return _buildPublicNav(context);
    }

    if (user.isAdmin) return _buildAdminNav(context);
    if (user.isSeller) return _buildSellerNav(context);
    return _buildBuyerNav(context);
  }

  Widget _buildPublicNav(BuildContext context) {
    final destinations = [
      const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      const NavigationDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store), label: 'Market'),
      const NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Favorites'),
      const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
    ];
    final routes = ['/home', '/marketplace', '/favorites', '/login'];
    return _nav(context, destinations, routes);
  }

  Widget _buildBuyerNav(BuildContext context) {
    final destinations = [
      const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      const NavigationDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store), label: 'Market'),
      const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
      const NavigationDestination(icon: Icon(Icons.message_outlined), selectedIcon: Icon(Icons.message), label: 'Messages'),
      const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
    ];
    final routes = ['/home', '/marketplace', '/buyer/dashboard', '/messages', '/profile'];
    return _nav(context, destinations, routes);
  }

  Widget _buildSellerNav(BuildContext context) {
    final destinations = [
      const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
      const NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Listings'),
      const NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Add'),
      const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
      const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
    ];
    final routes = ['/seller/dashboard', '/seller/listings', '/seller/listings/add', '/seller/orders', '/profile'];
    return _nav(context, destinations, routes);
  }

  Widget _buildAdminNav(BuildContext context) {
    final destinations = [
      const NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: 'Admin'),
      const NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Analytics'),
      const NavigationDestination(icon: Icon(Icons.pending_actions_outlined), selectedIcon: Icon(Icons.pending_actions), label: 'Approvals'),
      const NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Users'),
      const NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
    ];
    final routes = ['/admin/dashboard', '/admin/analytics', '/admin/approvals', '/admin/users', '/admin/settings'];
    return _nav(context, destinations, routes);
  }

  Widget _nav(BuildContext context, List<NavigationDestination> destinations, List<String> routes) {
    return NavigationBar(
      selectedIndex: currentIndex.clamp(0, destinations.length - 1),
      destinations: destinations,
      onDestinationSelected: (index) {
        if (index < routes.length) {
          context.go(routes[index]);
        }
      },
    );
  }
}
