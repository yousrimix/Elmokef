# Sprint 4 — Handoff Package
**إعداد:** ليلى السعد — UI/UX Designer  
**التسليم إلى:** خالد العمري (Flutter) + محمد العلي (Backend)

---

## 1. التسليمات

| المجلد | الملف | المحتوى |
|--------|-------|---------|
| `sprint-04-artisan/` | `01-simplified-mode.md` | Simplified Mode — 6 شاشات + Design Tokens + مبادئ التصميم |
| | `02-artisan-dashboard.md` | Dashboard — Stats + Requests + Notifications + حالات خاصة |
| | `03-handoff.md` (هذا الملف) | Handoff كامل |

---

## 2. ملخص الشاشات المطلوبة

| الرمز | الشاشة | الأولوية | الوضع |
|-------|--------|---------|-------|
| SM-01 | Simplified Dashboard | Must | جديد |
| SM-02 | Simplified Requests | Must | جديد |
| SM-03 | Simplified Profile | Must | جديد |
| SM-04 | Simplified Add Photo | Must | جديد |
| SM-05 | Simplified Reviews | Should | جديد |
| SM-06 | Simplified Settings | Should | جديد |
| HA-01 | Dashboard (عادي) | Must | محدّث |
| HA-02 | My Requests | Must | محدّث |
| HA-03 | My Reviews | Must | محدّث |
| HA-04 | My Account | Must | موجود |
| HA-05 | Subscriptions | Must | موجود |

### علاقة Simplified Mode بالوضع العادي

```
[تسجيل الدخول]
      │
      ▼
[اختيار الوضع: عادي أم مبسّط؟]  ← سؤال مرة واحدة
      │               │
      ▼               ▼
[واجهة عادية]    [Simplified Mode]
  (HA-01-05)      (SM-01-06)
      │               │
      └───────┬───────┘
              ▼
      [إعدادات ← تبديل الوضع]
```

---

## 3. الـ API Endpoints (لـ محمد)

| الطريقة | الـ Endpoint | التحديث |
|---------|-------------|---------|
| GET | `/api/v1/artisans/:id/dashboard` | Stats | views, contacts, avg_rating, avg_price, monthly_requests |
| | | Requests | آخر 5 طلبات مع client_name, service, distance, status |
| | | profile_completion | 0.0–1.0 بناءً على الحقول المعبأة |
| GET | `/api/v1/artisans/:id/requests?status=&page=&cursor=` | التصفية حسب الحالة + Pagination |
| PUT | `/api/v1/artisans/:id/requests/:reqId/status` | `{status: "responded" / "cancelled"}` |
| GET | `/api/v1/artisans/:id/notifications?since=` | آخر الإشعارات (Polling) |
| POST | `/api/v1/notifications/register` | تسجيل FCM token + الجهاز (Huawei/Google) |

### Dashboard Response Schema

```json
{
  "stats": {
    "total_views": 128,
    "total_contacts": 45,
    "avg_rating": 4.8,
    "avg_price": 150.0,
    "monthly_requests": 12,
    "profile_completion": 0.7
  },
  "new_requests": [
    {
      "id": "req_123",
      "client_name": "عميد",
      "client_photo": "https://...",
      "service_name": "سباكة",
      "distance_km": 2.3,
      "city": "الدار البيضاء",
      "created_at": "2026-07-20T10:30:00Z",
      "status": "new"
    }
  ],
  "recent_reviews": [
    {
      "id": "rev_456",
      "client_name": "سعيد",
      "rating": 5,
      "comment": "خدمة ممتازة",
      "created_at": "2026-07-19T15:00:00Z"
    }
  ]
}
```

### Profile Completion Logic

```dart
double calculateProfileCompletion(ArtisanProfile profile) {
  double score = 0.0;
  if (profile.name != null && profile.name!.isNotEmpty) score += 0.10;
  if (profile.photo != null) score += 0.15;
  if (profile.bio != null && profile.bio!.isNotEmpty) score += 0.15;
  if (profile.services.isNotEmpty) score += 0.20;
  if (profile.portfolioImages.isNotEmpty) score += 0.20; // 5+ images = 0.20
  if (profile.identityDoc != null) score += 0.10;
  if (profile.city != null) score += 0.10;
  return min(score, 1.0);
}
```

---

## 4. مكونات Flutter الجديدة (لـ خالد)

| المكون | الملف | الوصف |
|--------|-------|-------|
| `SimplifiedLayout` | `widgets/simplified_layout.dart` | Layout بدون BottomNav — أزرار كبيرة بدلاً منه |
| `BigStatCard` | `widgets/big_stat_card.dart` | بطاقة إحصائية كبيرة (أيقونة 40px + رقم 48px + تسمية) |
| `AlertCard` | `widgets/alert_card.dart` | بطاقة تنبيه مع لون حسب النوع (أخضر/برتقالي/أحمر) |
| `RequestCard` | `widgets/request_card.dart` | بطاقة طلب مع صورتين (اتصل/رفض) |
| `NotificationItem` | `widgets/notification_item.dart` | عنصر إشعار مع أيقونة + نص + إجراء |
| `QuickActionGrid` | `widgets/quick_action_grid.dart` | شبكة 2×2 للإجراءات السريعة |
| `ProfileCompletionBar` | `widgets/profile_completion_bar.dart` | شريط تقدم اكتمال الملف مع نص تحفيزي |
| `EmptyDashboard` | `widgets/empty_dashboard.dart` | حالة "لا طلبات بعد" للحرفي الجديد |
| `ModeToggle` | `widgets/mode_toggle.dart` | Toggle بين Simplified Mode والعادي |

### Simplified Layout

```dart
// SimplifiedLayout يحل مكان BottomNavigationBar
class SimplifiedLayout extends StatelessWidget {
  final Widget child;
  // لا BottomNav — 3 أزرار كبيرة في أسفل الـ Dashboard
  // يستخدم فقط في شاشات Simplified Mode
}
```

---

## 5. الـ State Management

```dart
// lib/features/artisan/providers/dashboard_provider.dart
@riverpod
class ArtisanDashboard extends _$ArtisanDashboard {
  // الحالة: AsyncValue<DashboardData>
  Future<void> fetchDashboard() async { ... }
  Future<void> markRequestResponded(String requestId) async { ... }
}

// lib/features/artisan/providers/simplified_mode_provider.dart
@riverpod
class SimplifiedMode extends _$SimplifiedMode {
  // الحالة: bool isSimplified
  // مخزّن في SharedPreferences
  bool get isSimplified => _prefs.getBool('simplified_mode') ?? false;
  Future<void> toggle() async { ... }
}

// lib/features/notifications/providers/notifications_provider.dart
@riverpod
class Notifications extends _$Notifications {
  // الحالة: AsyncValue<List<Notification>>
  Future<void> fetchNotifications() async { ... }
  Future<void> markAllRead() async { ... }
}
```

---

## 6. Routing

```dart
// إضافة هذه المسارات

GoRoute(
  path: '/artisan/dashboard',
  builder: (_, __) {
    // اختيار الوضع تلقائياً حسب الـ Provider
    final isSimplified = ref.watch(simplifiedModeProvider);
    return isSimplified ? SimplifiedDashboardScreen() : ArtisanDashboardScreen();
  },
  routes: [
    GoRoute(path: 'requests', builder: (_, __) => ArtisanRequestsScreen()),
    GoRoute(path: 'reviews', builder: (_, __) => ArtisanReviewsScreen()),
    GoRoute(path: 'profile', builder: (_, __) => ArtisanProfileScreen()),
    GoRoute(path: 'subscriptions', builder: (_, __) => SubscriptionsScreen()),
    GoRoute(path: 'notifications', builder: (_, __) => NotificationsScreen()),
    
    // Simplified Mode routes
    GoRoute(path: 'simplified/settings', builder: (_, __) => SimplifiedSettingsScreen()),
  ],
);
```

---

## 7. Assets

| الملف | الوصف | الصيغة |
|-------|-------|--------|
| `simplified_empty.svg` | Illustration "لا طلبات" | SVG 240×240 |
| `simplified_welcome.svg` | Illustration ترحيب للحرفي الجديد | SVG 240×240 |
| `simplified_camera.svg` | أيقونة كاميرا كبيرة | SVG 64×64 |

---

## 8. قائمة التحقق قبل التسليم

- [x] Simplified Mode: 6 شاشات كاملة
- [x] Dashboard: Stats, Requests, Notifications, Profile Completion
- [x] حالات خاصة: New Artisan (فارغ), Urgent, Subscription Expired
- [x] API endpoints محددة للمطور الخلفي
- [x] مكونات Flutter محددة للمطور الأمامي
- [x] State management + Routing
- [x] Assets محددة

---

— ليلى السعد | UI/UX Designer
