import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Safe Firebase init (handles web where config may be missing)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init skipped (web/offline): $e');
  }

  String? killedRoute;
  try {
    killedRoute = await NotificationService.getKilledRoute();
  } catch (e) {
    debugPrint('Notifications not available (web/offline): $e');
  }
  
  if (killedRoute != null) {
    initialRoute = killedRoute;
  }

  runApp(
    const ProviderScope(
      child: ElmokefApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      NotificationService().init(navKey: rootNavigator);
    } catch (e) {
      debugPrint('Notification init skipped (web/offline): $e');
    }
  });
}

class ElmokefApp extends ConsumerWidget {
  const ElmokefApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp.router(
      title: 'الميقف',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale?.languageCode) {
            return supported;
          }
        }
        return const Locale('ar');
      },
    ),
    );
  }
}
