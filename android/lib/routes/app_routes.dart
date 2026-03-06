import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/public/home_screen.dart';
import '../screens/public/marketplace_screen.dart';
import '../screens/public/item_details_screen.dart';
import '../screens/public/favorites_screen.dart';
import '../screens/public/recently_viewed_screen.dart';
import '../screens/buyer/buyer_dashboard_screen.dart';
import '../screens/buyer/buyer_orders_screen.dart';
import '../screens/buyer/buyer_rentals_screen.dart';
import '../screens/buyer/buyer_payments_screen.dart';
import '../screens/buyer/buyer_disputes_screen.dart';
import '../screens/buyer/buyer_receipt_screen.dart';
import '../screens/buyer/buyer_report_screen.dart';
import '../screens/buyer/checkout_screen.dart';
import '../screens/seller/seller_dashboard_screen.dart';
import '../screens/seller/seller_manage_listings_screen.dart';
import '../screens/seller/seller_edit_listing_screen.dart';
import '../screens/seller/add_listing_screen.dart';
import '../screens/seller/seller_orders_screen.dart';
import '../screens/seller/seller_rentals_screen.dart';
import '../screens/seller/seller_disputes_screen.dart';
import '../screens/seller/seller_order_details_screen.dart';
import '../screens/seller/seller_notifications_screen.dart';
import '../screens/seller/seller_settings_screen.dart';
import '../screens/seller/seller_help_screen.dart';
import '../screens/seller/seller_reports_screen.dart';
import '../screens/common/profile_screen.dart';
import '../screens/common/settings_screen.dart';
import '../screens/common/messages_screen.dart';
import '../screens/common/notifications_screen.dart';
import '../screens/common/review_screen.dart';
import '../screens/common/payment_review_screen.dart';
import '../screens/common/subscription_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_analytics_screen.dart';
import '../screens/admin/admin_approvals_screen.dart';
import '../screens/admin/admin_categories_screen.dart';
import '../screens/admin/admin_inbox_screen.dart';
import '../screens/admin/admin_notifications_screen.dart';
import '../screens/admin/admin_payouts_screen.dart';
import '../screens/admin/admin_reviews_screen.dart';
import '../screens/admin/admin_settings_screen.dart';
import '../screens/admin/admin_universities_screen.dart';
import '../screens/admin/admin_user_details_screen.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/admin/user_management_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      final location = state.matchedLocation;

      final publicRoutes = ['/login', '/register', '/home', '/marketplace'];
      final isPublicRoute = publicRoutes.any((r) => location.startsWith(r));

      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      if (isAuthenticated) {
        if (location == '/login' || location == '/register') {
          final user = authProvider.currentUser;
          if (user?.isAdmin ?? false) return '/admin';
          if (user?.isSeller ?? false) return '/seller/dashboard';
          return '/buyer/dashboard';
        }
      }

      return null;
    },
    routes: [
      // Auth
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Public
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/marketplace', builder: (_, __) => const MarketplaceScreen()),
      GoRoute(
        path: '/item/:id',
        builder: (_, state) => ItemDetailsScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
      GoRoute(path: '/recently-viewed', builder: (_, __) => const RecentlyViewedScreen()),

      // Buyer
      GoRoute(path: '/buyer/dashboard', builder: (_, __) => const BuyerDashboardScreen()),
      GoRoute(path: '/buyer/orders', builder: (_, __) => const BuyerOrdersScreen()),
      GoRoute(path: '/buyer/rentals', builder: (_, __) => const BuyerRentalsScreen()),
      GoRoute(path: '/buyer/payments', builder: (_, __) => const BuyerPaymentsScreen()),
      GoRoute(path: '/buyer/disputes', builder: (_, __) => const BuyerDisputesScreen()),
      GoRoute(
        path: '/buyer/receipt/:orderId',
        builder: (_, state) => BuyerReceiptScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(path: '/buyer/report', builder: (_, __) => const BuyerReportScreen()),
      GoRoute(
        path: '/checkout/:productId',
        builder: (_, state) => CheckoutScreen(productId: state.pathParameters['productId']!),
      ),

      // Seller
      GoRoute(path: '/seller/dashboard', builder: (_, __) => const SellerDashboardScreen()),
      GoRoute(path: '/seller/listings', builder: (_, __) => const SellerManageListingsScreen()),
      GoRoute(
        path: '/seller/listings/edit/:id',
        builder: (_, state) => SellerEditListingScreen(listingId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/seller/listings/add', builder: (_, __) => const AddListingScreen()),
      GoRoute(path: '/seller/orders', builder: (_, __) => const SellerOrdersScreen()),
      GoRoute(path: '/seller/rentals', builder: (_, __) => const SellerRentalsScreen()),
      GoRoute(path: '/seller/disputes', builder: (_, __) => const SellerDisputesScreen()),
      GoRoute(
        path: '/seller/orders/:id',
        builder: (_, state) => SellerOrderDetailsScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/seller/notifications', builder: (_, __) => const SellerNotificationsScreen()),
      GoRoute(path: '/seller/settings', builder: (_, __) => const SellerSettingsScreen()),
      GoRoute(path: '/seller/help', builder: (_, __) => const SellerHelpScreen()),
      GoRoute(path: '/seller/reports', builder: (_, __) => const SellerReportsScreen()),

      // Common
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/messages', builder: (_, __) => const MessagesScreen()),
      GoRoute(
        path: '/messages/:conversationId',
        builder: (_, state) => MessagesScreen(conversationId: state.pathParameters['conversationId']),
      ),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(
        path: '/review/:orderId',
        builder: (_, state) => ReviewScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: '/payment-review/:orderId',
        builder: (_, state) => PaymentReviewScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(path: '/subscription', builder: (_, __) => const SubscriptionScreen()),

      // Admin
      GoRoute(path: '/admin', builder: (_, __) => const AdminScreen()),
      GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/analytics', builder: (_, __) => const AdminAnalyticsScreen()),
      GoRoute(path: '/admin/approvals', builder: (_, __) => const AdminApprovalsScreen()),
      GoRoute(path: '/admin/categories', builder: (_, __) => const AdminCategoriesScreen()),
      GoRoute(path: '/admin/inbox', builder: (_, __) => const AdminInboxScreen()),
      GoRoute(path: '/admin/notifications', builder: (_, __) => const AdminNotificationsScreen()),
      GoRoute(path: '/admin/payouts', builder: (_, __) => const AdminPayoutsScreen()),
      GoRoute(path: '/admin/reviews', builder: (_, __) => const AdminReviewsScreen()),
      GoRoute(path: '/admin/settings', builder: (_, __) => const AdminSettingsScreen()),
      GoRoute(path: '/admin/universities', builder: (_, __) => const AdminUniversitiesScreen()),
      GoRoute(
        path: '/admin/users/:userId',
        builder: (_, state) => AdminUserDetailsScreen(userId: state.pathParameters['userId']!),
      ),
      GoRoute(path: '/admin/users', builder: (_, __) => const UserManagementScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
