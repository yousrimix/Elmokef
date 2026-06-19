import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/client/presentation/screens/artisan_list_screen.dart';
import '../../features/client/presentation/screens/artisan_profile_screen.dart';
import '../../features/client/presentation/screens/review_screen.dart';
import '../../features/client/presentation/screens/account_screen.dart';
import '../../features/client/presentation/screens/map_screen.dart';
import '../../features/client/presentation/screens/search_screen.dart';
import '../../features/client/presentation/screens/complaint_screen.dart';
import '../../features/client/presentation/screens/favorites_screen.dart';
import '../../features/client/presentation/screens/my_orders_screen.dart';
import '../../features/artisan/presentation/screens/dashboard_screen.dart';
import '../../features/artisan/presentation/screens/requests_screen.dart';
import '../../features/artisan/presentation/screens/reviews_screen.dart';
import '../../features/artisan/presentation/screens/account_management_screen.dart';
import '../../features/artisan/presentation/screens/subscriptions_screen.dart';
import '../../features/artisan/presentation/screens/payment_screen.dart';
import '../../features/artisan/presentation/screens/subscription_settings_screen.dart';
import '../../features/artisan/presentation/screens/wizard_screen.dart';
import '../../features/artisan/presentation/screens/artisan_profile_screen.dart';
import '../../features/artisan/presentation/screens/portfolio_gallery_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';

final GlobalKey<NavigatorState> rootNavigator = GlobalKey<NavigatorState>();
String initialRoute = '/splash';

// ─── Page Transition Helpers ──────────────────────────────────
enum TransitionType { slideUp, fade, scale, slideLeft, slideRight }

Page<T> _buildPage<T>(Widget child, TransitionType type) {
  return CustomTransitionPage<T>(
    key: ValueKey(child.runtimeType),
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (type) {
        case TransitionType.slideUp:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        case TransitionType.fade:
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        case TransitionType.scale:
          return ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        case TransitionType.slideLeft:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.12, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        case TransitionType.slideRight:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-0.12, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
      }
    },
  );
}

final appRouter = GoRouter(
  navigatorKey: rootNavigator,
  initialLocation: initialRoute,
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => _buildPage(const SplashScreen(), TransitionType.fade),
    ),
    GoRoute(path: '/login', pageBuilder: (context, state) => _buildPage(const LoginScreen(), TransitionType.fade)),
    GoRoute(path: '/register', pageBuilder: (context, state) => _buildPage(const RegisterScreen(), TransitionType.fade)),
    GoRoute(path: '/home', pageBuilder: (context, state) => _buildPage(const HomeScreen(), TransitionType.fade)),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => _buildPage(
        SearchScreen(initialQuery: state.uri.queryParameters['q']),
        TransitionType.slideLeft,
      ),
    ),
    GoRoute(
      path: '/artisans/:serviceId',
      pageBuilder: (context, state) => _buildPage(
        ArtisanListScreen(
          serviceId: state.pathParameters['serviceId']!,
          serviceName: state.extra as String?,
        ),
        TransitionType.slideUp,
      ),
    ),
    GoRoute(
      path: '/map/:serviceId',
      pageBuilder: (context, state) => _buildPage(
        MapScreen(
          serviceId: state.pathParameters['serviceId']!,
          serviceName: state.extra as String? ?? '',
        ),
        TransitionType.slideUp,
      ),
    ),
    GoRoute(
      path: '/artisan/:id',
      pageBuilder: (context, state) => _buildPage(
        ArtisanProfileScreen(
          artisanId: state.pathParameters['id']!,
        ),
        TransitionType.slideUp,
      ),
    ),
    GoRoute(
      path: '/review/:artisanId',
      pageBuilder: (context, state) => _buildPage(
        ReviewScreen(
          artisanId: state.pathParameters['artisanId']!,
          artisanName: state.extra as String? ?? 'الحرفي',
        ),
        TransitionType.scale,
      ),
    ),
    GoRoute(path: '/account', pageBuilder: (context, state) => _buildPage(const AccountScreen(), TransitionType.slideLeft)),
    GoRoute(path: '/favorites', pageBuilder: (context, state) => _buildPage(const FavoritesScreen(), TransitionType.slideLeft)),
    GoRoute(path: '/my-orders', pageBuilder: (context, state) => _buildPage(const MyOrdersScreen(), TransitionType.slideLeft)),
    GoRoute(path: '/my-reviews', pageBuilder: (context, state) => _buildPage(const ReviewsScreen(), TransitionType.slideLeft)),
    GoRoute(path: '/artisan-dashboard', pageBuilder: (context, state) => _buildPage(const DashboardScreen(), TransitionType.slideUp)),
    GoRoute(path: '/artisan-requests', pageBuilder: (context, state) => _buildPage(const RequestsScreen(), TransitionType.slideUp)),
    GoRoute(path: '/artisan-reviews', pageBuilder: (context, state) => _buildPage(ReviewsScreen(artisanId: state.extra as String?), TransitionType.slideUp)),
    GoRoute(path: '/artisan-account', pageBuilder: (context, state) => _buildPage(const AccountManagementScreen(), TransitionType.slideLeft)),
    GoRoute(path: '/subscriptions', pageBuilder: (context, state) => _buildPage(const SubscriptionsScreen(), TransitionType.slideUp)),
    GoRoute(
      path: '/payment',
      pageBuilder: (context, state) => _buildPage(
        PaymentScreen(planId: state.extra as String? ?? 'pro'),
        TransitionType.scale,
      ),
    ),
    GoRoute(path: '/subscription-settings', pageBuilder: (context, state) => _buildPage(const SubscriptionSettingsScreen(), TransitionType.slideLeft)),
    GoRoute(path: '/artisan-register', pageBuilder: (context, state) => _buildPage(const WizardScreen(), TransitionType.slideUp)),
    GoRoute(path: '/artisan-profile-view', pageBuilder: (context, state) => _buildPage(const ArtisanProfileViewScreen(), TransitionType.slideUp)),
    GoRoute(path: '/artisan-gallery', pageBuilder: (context, state) => _buildPage(const PortfolioGalleryScreen(), TransitionType.slideUp)),
    GoRoute(path: '/notifications', pageBuilder: (context, state) => _buildPage(const NotificationsScreen(), TransitionType.slideLeft)),
    GoRoute(
      path: '/complaint/:artisanId',
      pageBuilder: (context, state) => _buildPage(
        ComplaintScreen(
          artisanId: state.pathParameters['artisanId']!,
          artisanName: state.extra as String? ?? '',
        ),
        TransitionType.slideUp,
      ),
    ),
  ],
);
