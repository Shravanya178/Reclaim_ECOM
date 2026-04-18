import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reclaim/core/theme/app_theme.dart';
import 'responsive_builder.dart';
import 'web_navbar.dart';

/// A responsive scaffold that provides website-like navigation on desktop
/// and mobile-friendly navigation on smaller screens.
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final String? currentRoute;
  final int cartItemCount;
  final bool showNavBar;
  final bool showFooter;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? mobileAppBar;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.currentRoute,
    this.cartItemCount = 0,
    this.showNavBar = true,
    this.showFooter = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.mobileAppBar,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    if (isMobile) {
      return _buildMobileLayout(context);
    }
    return _buildDesktopLayout(context);
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: mobileAppBar ??
          AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                const Text('ReClaim'),
              ],
            ),
            actions: [
              IconButton(
                icon: Badge(
                  isLabelVisible: cartItemCount > 0,
                  label: Text('$cartItemCount'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                onPressed: () => context.go('/cart'),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.go('/notifications'),
              ),
            ],
          ),
      drawer: _buildMobileDrawer(context),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          // Top navigation bar
          if (showNavBar)
            WebNavBar(
              cartItemCount: cartItemCount,
              currentRoute: currentRoute,
            ),

          // Main content area
          Expanded(
            child: body,
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Drawer _buildMobileDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.85),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 28),
                ),
                SizedBox(height: 12),
                Text(
                  'Welcome!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sustainable Materials Marketplace',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          _drawerItem(context, Icons.home_outlined, 'Home', '/student-dashboard'),
          _drawerItem(context, Icons.storefront_outlined, 'Shop', '/shop'),
          _drawerItem(context, Icons.explore_outlined, 'Discover', '/student-dashboard/discovery'),
          _drawerItem(context, Icons.receipt_long_outlined, 'My Orders', '/orders'),
          _drawerItem(context, Icons.shopping_cart_outlined, 'Cart', '/cart'),
          const Divider(),
          _drawerItem(context, Icons.swap_horiz, 'Skill Barter', '/barter'),
          _drawerItem(context, Icons.add_circle_outline, 'Requests', '/requests'),
          _drawerItem(context, Icons.eco_outlined, 'Impact', '/impact'),
          _drawerItem(context, Icons.document_scanner_outlined, 'Detection', '/detection'),
          _drawerItem(context, Icons.emoji_events_outlined, 'Rankings', '/rankings'),
          const Divider(),
          _drawerItem(context, Icons.science_outlined, 'Lab Dashboard', '/lab-dashboard'),
          _drawerItem(context, Icons.admin_panel_settings_outlined, 'Admin Panel', '/admin-dashboard'),
          const Divider(),
          _drawerItem(context, Icons.settings_outlined, 'Settings', '/settings'),
          _drawerItem(context, Icons.logout, 'Logout', '/auth', isDestructive: true),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    String route, {
    bool isDestructive = false,
  }) {
    final isActive = currentRoute == route;
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Colors.red
            : isActive
                ? theme.colorScheme.primary
                : Colors.grey.shade700,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive
              ? Colors.red
              : isActive
                  ? theme.colorScheme.primary
                  : Colors.grey.shade800,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      selected: isActive,
      selectedTileColor: theme.colorScheme.primary.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
