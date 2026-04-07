import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'responsive_builder.dart';
import 'package:reclaim/core/theme/app_theme.dart';

/// Website-style top navigation bar for desktop/tablet
class WebNavBar extends StatelessWidget implements PreferredSizeWidget {
  final int cartItemCount;
  final String? currentRoute;

  const WebNavBar({
    super.key,
    this.cartItemCount = 0,
    this.currentRoute,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);
    final theme = Theme.of(context);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final navWidth = constraints.maxWidth;
              final showDesktopLinks = isDesktop && navWidth >= 900;
              final showSearch = isDesktop && navWidth >= 1220;
              final compactLinks = navWidth < 1120;
              final showAccountLabel = isDesktop && navWidth >= 1080;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Logo
                    InkWell(
                      onTap: () => context.go('/student-dashboard'),
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.eco, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'ReClaim',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (showDesktopLinks) ...[
                      const SizedBox(width: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _NavLink(
                                label: 'Home',
                                icon: Icons.home_outlined,
                                isActive: currentRoute == '/student-dashboard',
                                compact: compactLinks,
                                onTap: () => context.go('/student-dashboard'),
                              ),
                              _NavLink(
                                label: 'Shop',
                                icon: Icons.storefront_outlined,
                                isActive: currentRoute == '/shop',
                                compact: compactLinks,
                                onTap: () => context.go('/shop'),
                              ),
                              _NavLink(
                                label: 'Discover',
                                icon: Icons.explore_outlined,
                                isActive: currentRoute?.contains('discovery') ?? false,
                                compact: compactLinks,
                                onTap: () => context.go('/student-dashboard/discovery'),
                              ),
                              _NavLink(
                                label: 'Orders',
                                icon: Icons.receipt_long_outlined,
                                isActive: currentRoute == '/orders',
                                compact: compactLinks,
                                onTap: () => context.go('/orders'),
                              ),
                              _NavLink(
                                label: 'Detection',
                                icon: Icons.document_scanner_outlined,
                                isActive: currentRoute == '/detection',
                                compact: compactLinks,
                                onTap: () => context.go('/detection'),
                              ),
                              _NavLink(
                                label: 'Rankings',
                                icon: Icons.emoji_events_outlined,
                                isActive: currentRoute == '/rankings',
                                compact: compactLinks,
                                onTap: () => context.go('/rankings'),
                              ),
                              _NavLink(
                                label: 'Business',
                                icon: Icons.auto_graph_outlined,
                                isActive: currentRoute == '/business-engine',
                                compact: compactLinks,
                                onTap: () => context.go('/business-engine?role=customer'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ] else
                      const Spacer(),

                    // Search bar (desktop, only when space allows)
                    if (showSearch)
                      SizedBox(
                        width: 280,
                        height: 40,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search materials...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),

                    if (showSearch) const SizedBox(width: 16),

                    // Cart icon with badge
                    _NavIconButton(
                      icon: Icons.shopping_cart_outlined,
                      badge: cartItemCount > 0 ? '$cartItemCount' : null,
                      tooltip: 'Cart',
                      onTap: () => context.go('/cart'),
                    ),

                    const SizedBox(width: 8),

                    // Notifications
                    _NavIconButton(
                      icon: Icons.notifications_outlined,
                      tooltip: 'Notifications',
                      onTap: () => context.go('/notifications'),
                    ),

                    const SizedBox(width: 8),

                    // Profile/Account
                    PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.person_outline,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (showAccountLabel) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'Account',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade600),
                        ],
                      ],
                    ),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'profile':
                        context.go('/profile');
                        break;
                      case 'orders':
                        context.go('/orders');
                        break;
                      case 'settings':
                        context.go('/settings');
                        break;
                      case 'business':
                        context.go('/business-engine?role=customer');
                        break;
                      case 'admin':
                        context.go('/admin-dashboard');
                        break;
                      case 'lab':
                        context.go('/lab-dashboard');
                        break;
                      case 'logout':
                        context.go('/auth');
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: ListTile(
                        leading: Icon(Icons.person_outline, size: 20),
                        title: Text('My Profile'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'orders',
                      child: ListTile(
                        leading: Icon(Icons.receipt_long_outlined, size: 20),
                        title: Text('My Orders'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: ListTile(
                        leading: Icon(Icons.settings_outlined, size: 20),
                        title: Text('Settings'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'business',
                      child: ListTile(
                        leading: Icon(Icons.auto_graph_outlined, size: 20),
                        title: Text('Business Engine'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'admin',
                      child: ListTile(
                        leading: Icon(Icons.admin_panel_settings_outlined, size: 20),
                        title: Text('Admin Panel'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'lab',
                      child: ListTile(
                        leading: Icon(Icons.science_outlined, size: 20),
                        title: Text('Lab Dashboard'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout, size: 20, color: Colors.red),
                        title: Text('Logout', style: TextStyle(color: Colors.red)),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool compact;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.icon,
    this.isActive = false,
    this.compact = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive ? theme.colorScheme.primary : Colors.grey.shade700;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: compact ? 16 : 18, color: color),
                SizedBox(width: compact ? 4 : 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: compact ? 13 : 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isActive ? 40 : 0,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final String tooltip;
  final VoidCallback onTap;

  const _NavIconButton({
    required this.icon,
    this.badge,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: badge != null
              ? Badge(
                  label: Text(
                    badge!,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  child: Icon(icon, size: 22, color: const Color(0xFF5A6470)),
                )
              : Icon(icon, size: 22, color: const Color(0xFF5A6470)),
        ),
      ),
    );
  }
}

/// Website footer for desktop/tablet views
class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = Breakpoints.isDesktop(context);

    return Container(
      color: AppTheme.primaryDark,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : 24,
              vertical: isDesktop ? 48 : 32,
            ),
            child: Column(
              children: [
                // Main footer content
                isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildBrandColumn(theme)),
                          Expanded(child: _buildLinksColumn('Shop', ['All Products', 'Electronics', 'Metals', 'Plastics', 'Glass'])),
                          Expanded(child: _buildLinksColumn('Account', ['My Orders', 'Cart', 'Settings', 'Profile'])),
                          Expanded(child: _buildLinksColumn('Support', ['Contact Us', 'FAQ', 'Privacy Policy', 'Terms of Service'])),
                        ],
                      )
                    : Column(
                        children: [
                          _buildBrandColumn(theme),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildLinksColumn('Shop', ['All Products', 'Electronics', 'Metals'])),
                              Expanded(child: _buildLinksColumn('Account', ['My Orders', 'Cart', 'Settings'])),
                              Expanded(child: _buildLinksColumn('Support', ['Contact', 'FAQ', 'Privacy'])),
                            ],
                          ),
                        ],
                      ),

                const SizedBox(height: 32),
                Divider(color: Colors.white24),
                const SizedBox(height: 16),

                // Copyright
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '© 2026 ReClaim. Built for sustainability.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: [
                        _FooterSocialIcon(Icons.language, () {}),
                        _FooterSocialIcon(Icons.mail_outline, () {}),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'ReClaim',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Sustainable Materials Marketplace for academic institutions. '
          'Transforming waste into opportunity, one material at a time.',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildLinksColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {},
              child: Text(
                link,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterSocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FooterSocialIcon(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, size: 18, color: Colors.white60),
        ),
      ),
    );
  }
}
