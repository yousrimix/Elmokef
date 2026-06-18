# 📤 Outbox — UI/UX Designer
**إعداد:** مصمم UI/UX (Designer Agent)  
**التسليم إلى:** فريق الموقف (Product Manager, Solution Architect, Flutter Developer, Backend Developer)  
**تاريخ:** 18 يونيو 2026 — بعد مراجعة التصميم بالكامل

---

## خلاصة ما تم

| النشاط | الحالة |
|--------|--------|
| قراءة Design System (55 صفحة/ملف) | ✅ تم |
| مراجعة Flutter Theme (`app_colors.dart` + `app_typography.dart`) | ✅ تم |
| تحليل User Flows (Client + Artisan + Admin) | ✅ تم |
| مراجعة الشاشات المُنفَّذة (24+ شاشة Flutter) | ✅ تم |
| كتابة `design-review.md` (تحليل كامل + فجوات + توصيات) | ✅ تم |
| كتابة هذا الملف (`outbox.md`) | ✅ تم |

---

## تسليمات التصميم (ما جاهز للتطوير)

### ✅ جاهز — يمكن البدء فوراً

| القطعة | المرجع | تحتاج إلى ماذا؟ |
|--------|--------|----------------|
| **Design System Tokens** | `05-design-system/design-system.md` | فقط إنشاء `ThemeExtension` |
| **Client Screens (6)** | `04-wireframes-hifi/hifi-client-screens.md` | HC-01 إلى HC-06 — كلها منفَّذة |
| **Artisan Screens (5+Wizard)** | `04-wireframes-hifi/hifi-artisan-screens.md` | HA-01 إلى HA-05 + Wizard |
| **Auth Flows** | `sprint-02-auth/` | Login + Register + OTP + Role Selection |
| **Services & Categories** | `sprint-03-services/` | Categories + Search + Filter |
| **Artisan Dashboard & Requests** | `sprint-04-artisan/` | Dashboard + Simplified Mode |
| **Reviews System** | `sprint-06-reviews/` | Star rating + Display + Complaint |
| **Subscriptions & Payments** | `sprint-07-subscriptions/` | Plans + Payment + Cancel |
| **Admin Panel (6 screens)** | `06-screens/admin-panel-screens.md` | AD-01 إلى AD-06 |
| **API Endpoints (كاملة)** | جميع ملفات Handoff | +30 endpoint موثقة مع JSON Schema |

### 🟠 بحاجة إلى قرار

| الموضوع | السؤال | المقترح |
|---------|--------|---------|
| **Simplified Mode متى يُنفَّذ؟** | Sprint 8 أم Sprint 9؟ | الأفضل في Sprint 8 — يؤثر على 50%+ من الحرفيين |
| **Admin Panel: Flutter Web أم React؟** | القرار الهندسي المعماري | حسب `solution-architect` |
| **Compare mode بين الحرفيين** | هل يُضاف للمرحلة الأولى؟ | مذكور في Client Journey — يُرجى تأكيد Product Manager |
| **Online/Offline toggle للحرفي** | هل ضروري؟ | يُوصى به — يمنع إهدار وقت العميل |
| **اختبار Concept ميداني** | متى و بميزانية؟ | يُرجى التنسيق مع Business Analyst |

---

## توصيات عاجلة للـ Flutter Developer (خالد)

### 1. إنشاء Spacing Tokens
```dart
// lib/core/theme/app_spacing.dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}
```

### 2. إنشاء ThemeExtension للألوان
لضمان توحيد الألوان عبر جميع الـ Widgets:
```dart
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primaryLightBg; // #F0FDF9
  final Color filterChipBg;   // #F3F4F6
  final Color verifiedBadge;  // #0D9488
  // ... البقية من design-system.md
}
```

### 3. تنفيذ مكونات الأزرار كـ Widgets منفصلة
| المكون | الملف المقترح | Design System مرجع |
|--------|--------------|-------------------|
| `AppPrimaryButton` | `core/widgets/app_primary_button.dart` | ارتفاع 56px، زوايا 12px |
| `AppSecondaryButton` | `core/widgets/app_secondary_button.dart` | إطار 2px |
| `AppFAB` | `core/widgets/app_fab.dart` | قطر 56px |
| `AppChip` | `core/widgets/app_chip.dart` | ارتفاع 32px |

### 4. شاشات جديدة في Sprint القادم
| الأولوية | الشاشة | المرجع |
|----------|--------|--------|
| 🔴 Onboarding (4 شاشات) | Sprint 2 — OB-01 إلى OB-04 |
| 🔴 Plan Comparison (بطاقات 3) | Sprint 7 — SB-01 |
| 🔴 Cancel Subscription (3 خطوات) | Sprint 7 — SB-04 |
| 🟠 Payment History | Sprint 7 — SS-02 |
| 🟠 Duplicate Review Prevention | Sprint 6 — Edge Case |

---

## توصيات للـ Backend Developer (محمد)

| الأولوية | الـ Endpoint | المرجع | ملاحظات |
|----------|-------------|--------|---------|
| 🔴 | `POST /api/v1/subscriptions/cancel` | Sprint 7 — SB-04 | مع سبب الإلغاء |
| 🔴 | `GET /api/v1/payments/history` | Sprint 7 — SS-02 | مع Pagination |
| 🔴 | `GET /api/v1/reviews/check` | Sprint 6 | منع التقييم المكرر |
| 🟠 | `Webhook POST /api/v1/payments/cmi-webhook` | Sprint 7 | CMI Integration |
| 🟠 | `GET /api/v1/categories/:id/subcategories` | Sprint 3 — CA-02 | |
| 🟠 | البحث Full-Text بالدارجة | Sprint 3 — SE-01 | pg_trgm |
| 🟡 | `POST /api/v1/notifications/register` | Sprint 4 | FCM + Huawei |

---

## للتنسيق مع Business Analyst (سارة)

- **User Stories US-09** (مقارنة حرفيين) — هل تضاف للمرحلة الأولى؟
- **User Stories US-19** (إحصائيات الحرفي) — هل التنفيذ الحالي في Dashboard كافٍ؟
- **اختبار المفهوم** (Concept Testing) — هل يمكن ترتيبه عبر وكيل ميداني في المغرب؟

---

## للتنسيق مع Product Manager

- الرجاء الإطلاع على `design-review.md` للمراجعة الكاملة
- تأكيد أولوية **Simplified Mode** في خارطة الطريق
- تأكيد **Admin Panel** — Flutter Web أم React؟

---

**جاهز للمراجعة والتعليقات.**  
— مصمم UI/UX
