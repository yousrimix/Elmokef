import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  NotificationService().handleNotification(message.data, isBackground: true);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _localPlugin = FlutterLocalNotificationsPlugin();
  GlobalKey<NavigatorState>? navigatorKey;
  int _notificationId = 0;
  bool _initialized = false;

  // رسائل فرنسية شائعة قد ترسلها الإدارة
  static const Map<String, String> _frToAr = {
    'Nouveau message': 'رسالة جديدة',
    'Votre compte a été vérifié': 'تم التحقق من حسابك',
    'Votre abonnement a expiré': 'انتهت صلاحية اشتراكك',
    'Rappel de renouvellement': 'تذكير بالتجديد',
    'Offre spéciale': 'عرض خاص',
    'Votre demande a été acceptée': 'تم قبول طلبك',
    'Votre demande a été refusée': 'تم رفض طلبك',
    'Mise à jour du profil': 'تحديث الملف الشخصي',
    'Nouvelle évaluation reçue': 'تقييم جديد',
    'Paiement confirmé': 'تم تأكيد الدفع',
    'Paiement échoué': 'فشل الدفع',
  };

  String _localizeString(Map<String, dynamic> data, String key) {
    final value = data[key] as String?;
    if (value == null) return '';
    // إذا كانت رسالة الفرنسية، اترجمها
    return _frToAr[value] ?? value;
  }

  Future<void> init({GlobalKey<NavigatorState>? navKey}) async {
    if (_initialized) return;
    navigatorKey = navKey;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const androidSettings = AndroidInitializationSettings('drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (details) => _handleLocalNavigation(details.payload),
    );

    try {
      await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true).timeout(const Duration(seconds: 5));
      await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 5));
      FirebaseMessaging.onMessage.listen((msg) => handleNotification(msg.data, isForeground: true));
      FirebaseMessaging.onMessageOpenedApp.listen((msg) => handleNotification(msg.data, isOpenedFromTerminated: true));
    } on TimeoutException {
      // Huawei devices without Google Play Services — skip FCM
    } catch (_) {
      // FCM not available — push will not work but app continues
    }

    _initialized = true;
  }

  Future<String?> getFcmToken() => FirebaseMessaging.instance.getToken();

  static Future<String?> getKilledRoute() async {
    final msg = await FirebaseMessaging.instance.getInitialMessage();
    if (msg == null) return null;
    final type = msg.data['type'] as String? ?? '';
    switch (type) {
      case 'review': return '/artisan-reviews';
      case 'subscription': return '/subscription-settings';
      case 'payment': return '/subscriptions';
      case 'documents': return '/artisan-account';
      default: return '/notifications';
    }
  }

  void handleNotification(Map<String, dynamic> data, {bool isForeground = false, bool isBackground = false, bool isOpenedFromTerminated = false}) {
    final title = _localizeString(data, 'title') as String? ?? data['title'] as String? ?? '';
    final body = _localizeString(data, 'body') as String? ?? data['body'] as String? ?? '';

    if (isForeground) {
      _showLocalNotification(title, body, data.toString());
    }

    if (isOpenedFromTerminated || isBackground) {
      _navigateByType(data);
    }
  }

  void _handleLocalNavigation(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final navigator = navigatorKey?.currentContext;
    if (navigator == null || !navigator.mounted) return;
    final router = GoRouter.of(navigator);
    switch (payload) {
      case 'review':
        router.go('/artisan-reviews');
      case 'subscription':
        router.go('/subscription-settings');
      case 'payment':
        router.go('/subscriptions');
      case 'documents':
        router.go('/artisan-account');
      default:
        router.go('/notifications');
    }
  }

  void _showLocalNotification(String title, String body, String payload) {
    _localPlugin.show(
      _notificationId++,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails('elmokef_channel', 'Elmokef', channelDescription: 'إشعارات الميقف', importance: Importance.high, priority: Priority.high, icon: 'drawable/ic_notification'),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  void _navigateByType(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    final navigator = navigatorKey?.currentContext;
    if (navigator == null || !navigator.mounted) return;

    final router = GoRouter.of(navigator);
    switch (type) {
      case 'review':
        router.go('/artisan-reviews');
      case 'subscription':
        router.go('/subscription-settings');
      case 'payment':
        router.go('/subscriptions');
      case 'documents':
        router.go('/artisan-account');
      default:
        router.go('/notifications');
    }
  }
}
