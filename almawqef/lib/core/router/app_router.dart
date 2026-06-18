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

final appRouter = GoRouter(
  navigatorKey: rootNavigator,
  initialLocation: initialRoute,
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/search',
      builder: (context, state) => SearchScreen(initialQuery: state.uri.queryParameters['q']),
    ),
    GoRoute(
      path: '/artisans/:serviceId',
      builder: (context, state) => ArtisanListScreen(
        serviceId: state.pathParameters['serviceId']!,
        serviceName: state.extra as String?,
      ),
    ),
    GoRoute(
      path: '/map/:serviceId',
      builder: (context, state) => MapScreen(
        serviceId: state.pathParameters['serviceId']!,
        serviceName: state.extra as String? ?? '',
      ),
    ),
    GoRoute(
      path: '/artisan/:id',
      builder: (context, state) => ArtisanProfileScreen(
        artisanId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/review/:artisanId',
      builder: (context, state) => ReviewScreen(
        artisanId: state.pathParameters['artisanId']!,
        artisanName: state.extra as String? ?? 'الحرفي',
      ),
    ),
    GoRoute(path: '/account', builder: (context, state) => const AccountScreen()),
    GoRoute(path: '/artisan-dashboard', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/artisan-requests', builder: (context, state) => const RequestsScreen()),
    GoRoute(path: '/artisan-reviews', builder: (context, state) => ReviewsScreen(artisanId: state.extra as String?)),
    GoRoute(path: '/artisan-account', builder: (context, state) => const AccountManagementScreen()),
    GoRoute(path: '/subscriptions', builder: (context, state) => const SubscriptionsScreen()),
    GoRoute(
      path: '/payment',
      builder: (context, state) => PaymentScreen(planId: state.extra as String? ?? 'pro'),
    ),
    GoRoute(path: '/subscription-settings', builder: (context, state) => const SubscriptionSettingsScreen()),
    GoRoute(path: '/artisan-register', builder: (context, state) => const WizardScreen()),
    GoRoute(path: '/artisan-profile-view', builder: (context, state) => const ArtisanProfileViewScreen()),
    GoRoute(path: '/artisan-gallery', builder: (context, state) => const PortfolioGalleryScreen()),
    GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
    GoRoute(
      path: '/complaint/:artisanId',
      builder: (context, state) => ComplaintScreen(
        artisanId: state.pathParameters['artisanId']!,
        artisanName: state.extra as String? ?? '',
      ),
    ),
  ],
);
