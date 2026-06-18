# 5.8 — Handoff Package: تسليم التصاميم للمطورين
**إعداد:** ليلى السعد — UI/UX Designer  
**التسليم إلى:** خالد العمري (Flutter Developer) + محمد العلي (Backend Developer)  
**تاريخ التسليم:** 17 يونيو 2026

---

## 1. محتويات حزمة التسليم

```
📁 04-ui-ux-designer/
│
├── 📁 01-user-research/
│   └── research-report.md                    ← بحث المستخدم
│
├── 📁 02-journey-maps/
│   ├── client-journey.md                     ← رحلة العميل
│   └── artisan-journey.md                    ← رحلة الحرفي
│
├── 📁 03-wireframes-lowfi/
│   ├── wireframes-client.md                  ← Low-fi العميل
│   └── wireframes-artisan.md                 ← Low-fi الحرفي
│
├── 📁 04-wireframes-hifi/
│   ├── hifi-client-screens.md                ← Hi-fi العميل
│   └── hifi-artisan-screens.md               ← Hi-fi الحرفي
│
├── 📁 05-design-system/
│   └── design-system.md                      ← النظام البصري
│
├── 📁 06-screens/
│   ├── admin-panel-screens.md                ← شاشات الإدارة
│   ├── prototype-flow.md                     ← تدفق الـ Prototype
│   └── handoff-package.md (this file)        ← حزمة التسليم
│
├── inbox.md
├── project-brief.md
└── ba-analysis.md
```

---

## 2. ما يجب تنفيذه من Flutter (لـ خالد)

### 2.1 الأولوية القصوى — Sprint 1

| المكون | ملف التصميم | ملاحظات Flutter |
|--------|------------|----------------|
| **Design System Tokens** | `05-design-system/design-system.md` | إنشاء `ThemeData` مع `ThemeExtension` للألوان والخطوط والمسافات |
| **Color Palette** | `05-design-system/` → Colors | تعيين `ColorScheme.fromSeed(seedColor: Color(0xFF0D9488))` |
| **Typography** | `05-design-system/` → Typography | استخدام `TextTheme` مع Noto Naskh Arabic + Poppins |
| **Buttons** | `05-design-system/` → Buttons | 3 أنواع: Primary, Secondary, Text — مع حالات hover/pressed/disabled |
| **BottomNavigationBar** | `05-design-system/` → Bottom Nav | عميل (4 تبويبات) / حرفي (4 تبويبات) |

### 2.2 شاشات العميل — Sprint 1-2

| الشاشة | الملف | الصفحة | المكونات الرئيسية |
|--------|-------|-------|-----------------|
| Onboarding/Login | `04-wireframes-hifi/hifi-client-screens.md` | HC-01 | PageView + SmoothIndicator + OTP |
| Home — Categories | `04-wireframes-hifi/hifi-client-screens.md` | HC-02 | GridView 3×3 + SearchBar + Cards |
| Artisan List | `04-wireframes-hifi/hifi-client-screens.md` | HC-03 | ListView.builder + Card مع CTA |
| Artisan Profile | `04-wireframes-hifi/hifi-client-screens.md` | HC-04 | NestedScrollView + SliverAppBar + BottomBar |
| Review | `04-wireframes-hifi/hifi-client-screens.md` | HC-05 | RatingBar + TextField + Success State |
| My Account | `04-wireframes-hifi/hifi-client-screens.md` | HC-06 | ListTile + Logout |

### 2.3 شاشات الحرفي — Sprint 2-3

| الشاشة | الملف | الصفحة | المكونات الرئيسية |
|--------|-------|-------|-----------------|
| Wizard Step 1 | `03-wireframes-lowfi/wireframes-artisan.md` | A2a | Stepper + TextFormField + Dropdown |
| Wizard Step 2 | `03-wireframes-lowfi/wireframes-artisan.md` | A2b | CheckboxListTile + PriceField |
| Wizard Step 3 | `03-wireframes-lowfi/wireframes-artisan.md` | A2c | ImagePicker + Upload |
| Wizard Step 4 | `03-wireframes-lowfi/wireframes-artisan.md` | A2d | RadioListTile (3 plans) |
| Dashboard | `04-wireframes-hifi/hifi-artisan-screens.md` | HA-01 | Stats Cards + AlertCard + RequestList |
| My Requests | `04-wireframes-hifi/hifi-artisan-screens.md` | HA-02 | TabBar + Request Cards |
| My Reviews | `04-wireframes-hifi/hifi-artisan-screens.md` | HA-03 | RatingSummary + ReviewList + Reply |
| My Account | `04-wireframes-hifi/hifi-artisan-screens.md` | HA-04 | ProfileCard + Menu + Sub Status |
| Subscriptions | `04-wireframes-hifi/hifi-artisan-screens.md` | HA-05 | PlanCards + CMI WebView |

### 2.4 Admin Panel — Sprint 3-4

| الشاشة | الملف | ملاحظات |
|--------|-------|--------|
| Admin Login | `06-screens/admin-panel-screens.md` | AD-01 — مع MFA |
| Dashboard | `06-screens/admin-panel-screens.md` | AD-02 — KPI Cards + Charts |
| Artisans Management | `06-screens/admin-panel-screens.md` | AD-03 — DataTable + Search/Filter |
| Artisan Verification | `06-screens/admin-panel-screens.md` | AD-04 — Image Viewer + Accept/Reject |
| Complaints | `06-screens/admin-panel-screens.md` | AD-05 — Cards مع حالة |
| Analytics | `06-screens/admin-panel-screens.md` | AD-06 — Charts (fl_chart) |

---

## 3. الـ API Endpoints المطلوبة من التصميم (لـ محمد)

بناءً على التصاميم، الـ API endpoints الضرورية لتغذية الشاشات:

| Feature | Endpoint | البيانات المطلوبة من التصميم | الأولوية |
|---------|---------|---------------------------|---------|
| **Categories** | `GET /api/v1/services` | `[{id, name_ar, name_fr, icon, image, parent_id}]` | High |
| **Artisan List** | `GET /api/v1/artisans?service_id=&lat=&lng=&sort=&filter=` | `[{id, name, photo, profession, rating, reviews_count, price_min, distance, response_time, is_verified, subscription_tier}]` | High |
| **Artisan Profile** | `GET /api/v1/artisans/:id` | Full profile + services + portfolio + reviews | High |
| **Reviews** | `GET /api/v1/artisans/:id/reviews` | `[{client_name, rating, comment, date}]` | High |
| **Submit Review** | `POST /api/v1/reviews` | `{artisan_id, rating, comment}` | High |
| **Favorites** | `GET/POST/DELETE /api/v1/favorites` | Favorites list + add/remove | Medium |
| **Dashboard Stats** | `GET /api/v1/artisans/:id/stats` | `{views, contacts, rating}` | Medium |
| **Requests** | `GET /api/v1/artisans/:id/requests` | `[{client_name, service, distance, time, status}]` | Medium |
| **Subscriptions** | `GET/POST /api/v1/subscriptions` | Plan list + subscribe | High |
| **Admin Users** | `GET /api/v1/admin/artisans` | Full table data + filters | High |
| **Admin Verify** | `PUT /api/v1/admin/artisans/:id/verify` | Approve/reject + reason | High |

### تنسيق الـ API Response المتوقع من الـ Frontend
```json
{
  "success": true,
  "data": { ... },
  "pagination": {
    "cursor": "base64string",
    "hasMore": true
  }
}
```

---

## 4. إرشادات التكامل (Integration Notes)

### 4.1 State Management
- استخدم **Riverpod** (مقترح) أو Bloc
- أنشئ Providers لكل شاشة رئيسية:
  - `categoriesProvider` — لفئات الخدمات
  - `artisanListProvider` — لقائمة الحرفيين مع parameters
  - `artisanProfileProvider(family)` — لملف حرفي معين
  - `favoritesProvider` — للمفضلة
  - `authProvider` — للمصادقة

### 4.2 الصور والأيقونات
- **صور الحرفيين:** تصل من API كـ URL — استخدم `CachedNetworkImage`
- **أيقونات الفئات:** SVG من مجلد assets/icons/ — أسمها حسب ID الفئة
- **صور المعرض:** 3 أحجام — thumbnail (150px) / medium (640px) / original

### 4.3 Localization (RTL)
- اللغة الافتراضية: العربية (RTL)
- دعم الفرنسية (LTR) عبر `flutter_localizations` مع `Intl`
- كل النصوص الثابتة في ملفات `.arb`
- أسماء الخدمات والوصوف من API (تخزين ثنائي اللغة في DB)

### 4.4 Loading and Error States
- استخدم `AsyncValue` من Riverpod لإدارة 3 حالات: loading, data, error
- الـ Shimmer effect للقوائم (package: `shimmer`)
- EmptyState widget موحّد لجميع القوائم الفارغة

### 4.5 Dimensions
- Mobile: التصميم على أساس 390px عرض (iPhone 14)
- استخدم `MediaQuery` للتكيف مع الشاشات المختلفة
- الهامش الجانبي: 24px (ثابت)
- ارتفاع Bottom Nav: 64px
- ارتفاع AppBar: 56px

---

## 5. الـ Assets المطلوبة

| الأصل | الحجم | الصيغة | العدد |
|-------|-------|-------|-------|
| Logo Elmokef | 120×40px | SVG | 1 (مع inverted للخلفيات الداكنة) |
| أيقونات الخدمات (9) | 48×48px | SVG | 9 |
| أيقونات الواجهة (10) | 24×24px | SVG | 10 |
| صور Onboarding (3) | متغير | PNG/SVG | 3 |
| Illustration Empty State | 240×240px | SVG | 1 |
| Illustration Error State | 240×240px | SVG | 1 |
| Avatar placeholder | 80×80px | PNG | 1 (ذكر + أنثى) |

---

## 6. الـ Design System في Flutter — كود مبدئي

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color accent = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color star = Color(0xFFFBBF24);
  static const Color verified = Color(0xFF0D9488);
  
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color bg = Color(0xFFF9FAFB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
}
```

---

## 7. خطة التطوير المقترحة (من منظور التصميم)

| Sprint | الشاشات | المدة |
|--------|---------|-------|
| **Sprint 1** | Design System + Theme + HC-01 + HC-02 | أسبوع 1 |
| **Sprint 2** | HC-03 + HC-04 + HC-05 + HC-06 | أسبوع 2 |
| **Sprint 3** | HA-01 + HA-02 + HA-03 + Artisan Wizard | أسبوع 3 |
| **Sprint 4** | HA-04 + HA-05 + Admin AD-01→AD-04 | أسبوع 4 |
| **Sprint 5** | Admin AD-05 + AD-06 + Polish + QA | أسبوع 5 |

---

## 8. قائمة التحقق النهائية (قبل بدء التطوير)

- [x] Design System متكامل (ألوان، خطوط، مسافات، أزرار، أيقونات)
- [x] جميع شاشات العميل مصممة (6 شاشات)
- [x] جميع شاشات الحرفي مصممة (6 شاشات + Wizard)
- [x] شاشات Admin Panel مصممة (6 شاشات)
- [x] User Flows موثقة (3 تدفقات)
- [x] حالات الـ Empty و Error و Loading محددة
- [x] الـ API endpoints المطلوبة محددة
- [x] خريطة التدفق (Prototype Flow) جاهزة
- [x] مكونات Figma Variants محددة
- [x] إرشادات RTL/Localization موثقة
- [x] الـ Assets المطلوبة محددة

---

**ملاحظة أخيرة:** هذه الحزمة نصية (Markdown) لأن التصميم النهائي يتم في Figma. الملفات هنا توثق كل قرارات التصميم والتجربة لتكون مرجعاً للفريق. إذا أردتم، أنتقل إلى Figma لإنشاء الـ Prototype التفاعلي الكامل.

— ليلى السعد | UI/UX Designer
