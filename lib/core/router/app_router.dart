import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Import all screens
import 'package:reclaim/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:reclaim/features/auth/presentation/screens/auth_screen.dart';
import 'package:reclaim/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:reclaim/features/auth/presentation/screens/campus_selection_screen.dart';
import 'package:reclaim/core/models/user.dart';

// Dashboard screens
import 'package:reclaim/features/dashboard/presentation/screens/student_dashboard_screen.dart';
import 'package:reclaim/features/dashboard/presentation/screens/lab_dashboard_screen.dart';
import 'package:reclaim/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:reclaim/features/dashboard/presentation/screens/scm_dashboard_screen.dart';

// Student feature screens
import 'package:reclaim/features/discovery/presentation/screens/discovery_map_screen.dart';
import 'package:reclaim/features/dashboard/presentation/screens/student_profile_screen.dart';
import 'package:reclaim/features/materials/presentation/screens/materials_feed_screen.dart';
import 'package:reclaim/features/requests/presentation/screens/request_board_screen.dart';
import 'package:reclaim/features/requests/presentation/screens/request_creation_screen.dart';
import 'package:reclaim/features/opportunities/presentation/screens/barter_opportunities_screen.dart';

// Lab feature screens
import 'package:reclaim/features/capture/presentation/screens/material_capture_screen.dart';
import 'package:reclaim/features/inventory/presentation/screens/material_inventory_screen.dart';
import 'package:reclaim/features/opportunities/presentation/screens/opportunities_dashboard_screen.dart';

// Shared screens
import 'package:reclaim/features/materials/presentation/screens/material_detail_screen.dart';
import 'package:reclaim/features/materials/presentation/screens/lifecycle_tracking_screen.dart';
import 'package:reclaim/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:reclaim/features/impact/presentation/screens/impact_dashboard_screen.dart';
import 'package:reclaim/features/settings/presentation/screens/settings_screen.dart';

// E-commerce screens
import 'package:reclaim/features/ecommerce/presentation/screens/product_catalog_screen.dart';
import 'package:reclaim/features/ecommerce/presentation/screens/cart_screen.dart';
import 'package:reclaim/features/ecommerce/presentation/screens/checkout_screen.dart';
import 'package:reclaim/features/ecommerce/presentation/screens/order_history_screen.dart';
import 'package:reclaim/features/ecommerce/presentation/screens/order_detail_screen.dart';
import 'package:reclaim/features/ecommerce/presentation/screens/admin_dashboard_screen.dart' as ecom_admin;

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    debugLogDiagnostics: true,
    routes: [
      // Authentication Routes
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/campus-selection',
        name: 'campus-selection',
        builder: (context, state) {
          final role = state.extra as UserRole?;
          return CampusSelectionScreen(selectedRole: role);
        },
      ),
      
      // Dashboard Routes
      GoRoute(
        path: '/student-dashboard',
        name: 'student-dashboard',
        builder: (context, state) => const StudentDashboardScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            name: 'student-profile',
            builder: (context, state) => const StudentProfileScreen(),
          ),
          GoRoute(
            path: 'discovery',
            name: 'discovery-map',
            builder: (context, state) => const DiscoveryMapScreen(),
          ),
          GoRoute(
            path: 'materials-feed',
            name: 'materials-feed',
            builder: (context, state) => const MaterialsFeedScreen(),
          ),
          GoRoute(
            path: 'requests',
            name: 'request-board',
            builder: (context, state) => const RequestBoardScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'request-creation',
                builder: (context, state) => const RequestCreationScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'barter',
            name: 'barter-opportunities',
            builder: (context, state) => const BarterOpportunitiesScreen(),
          ),
        ],
      ),
      
      GoRoute(
        path: '/lab-dashboard',
        name: 'lab-dashboard',
        builder: (context, state) => const LabDashboardScreen(),
        routes: [
          GoRoute(
            path: 'capture',
            name: 'material-capture',
            builder: (context, state) => const MaterialCaptureScreen(),
          ),
          GoRoute(
            path: 'inventory',
            name: 'material-inventory',
            builder: (context, state) => const MaterialInventoryScreen(),
          ),
          GoRoute(
            path: 'opportunities',
            name: 'opportunities-dashboard',
            builder: (context, state) => const OpportunitiesDashboardScreen(),
          ),
        ],
      ),
      
      GoRoute(
        path: '/admin-dashboard',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // SCM Dashboard
      GoRoute(
        path: '/scm-dashboard',
        name: 'scm-dashboard',
        builder: (context, state) => const ScmDashboardScreen(),
      ),

      // ── E-Commerce Routes ──────────────────────────────────────────
      GoRoute(
        path: '/shop',
        name: 'shop',
        builder: (context, state) => const ProductCatalogScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/order/:id',
        name: 'order-detail',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/ecom-admin',
        name: 'ecom-admin',
        builder: (context, state) => const ecom_admin.AdminDashboardScreen(),
      ),

      // Material Detail Route (shared)
      GoRoute(
        path: '/material/:id',
        name: 'material-detail',
        builder: (context, state) {
          final materialId = state.pathParameters['id']!;
          return MaterialDetailScreen(materialId: materialId);
        },
      ),
      
      // Shared Routes (accessible from any dashboard)
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/impact',
        name: 'impact-dashboard',
        builder: (context, state) => const ImpactDashboardScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/lifecycle',
        name: 'lifecycle-tracking',
        builder: (context, state) => const LifecycleTrackingScreen(),
      ),
      GoRoute(
        path: '/barter',
        name: 'barter',
        builder: (context, state) => const BarterOpportunitiesScreen(),
      ),
      GoRoute(
        path: '/requests',
        name: 'requests',
        builder: (context, state) => const RequestBoardScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const StudentProfileScreen(),
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/onboarding'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}