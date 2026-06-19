# 📋 الميقف (Elmokef) — وثيقة المشروع

> **سوق الحرفيين المغاربة — منصة تربط الحرفيين بالعملاء في المغرب**

---

## 📑 فهرس المحتويات

1. [نظرة عامة](#1-نظرة-عامة)
2. [هيكل المشروع](#2-هيكل-المشروع)
3. [قائمة الشاشات (20 شاشة)](#3-قائمة-الشاشات-20-شاشة)
4. [دليل API](#4-دليل-api)
5. [كيفية البدء](#5-كيفية-البدء)

---

## 1. نظرة عامة

### 📌 وصف المشروع

**الميقف** هي منصة إلكترونية مغربية تهدف إلى ربط الحرفيين (النجارين، السباكين، الكهربائيين، البنائين، إلخ) بالعملاء الذين يبحثون عن خدماتهم. تتيح المنصة للعملاء البحث عن الحرفيين حسب المنطقة والتخصص، الاطلاع على ملفاتهم الشخصية وتقييماتهم، والتواصل معهم مباشرة. كما توفر للحرفيين لوحة تحكم متكاملة لإدارة أعمالهم واشتراكاتهم ومحفظة أعمالهم.

### 🛠 التقنيات المستخدمة

| الطبقة | التقنية |
|--------|---------|
| **الواجهة الأمامية** | Flutter + Web (Dart 3.x) |
| **نظام التصميم** | Material 3 (M3) |
| **إدارة الحالة** | Riverpod 2.x |
| **التوجيه** | GoRouter |
| **طلبات HTTP** | Dio 5.x مع interceptors |
| **الخلفية** | NestJS 11.x (TypeScript) |
| **قاعدة البيانات** | PostgreSQL 16 + PostGIS |
| **التخزين المؤقت** | Redis 7 |
| **ORM** | Prisma 7.x |
| **التوثيق** | Swagger (OpenAPI) |
| **الأمان** | JWT (Passport), Helmet, Throttler |
| **WebSocket** | Socket.IO (الطلبات والدفع) |
| **الدفع** | CMI (بوابة الدفع المغربية) |
| **الإشعارات** | Firebase Cloud Messaging + Huawei Push |
| **الحاويات** | Docker Compose (PostgreSQL + Redis + ClamAV) |
| **الصور** | Sharp (معالجة الصور + تصغير) |
| **مكافحة الفيروسات** | ClamAV (فحص الملفات المرفوعة) |

---

## 2. هيكل المشروع

### 📁 الواجهة الأمامية (Flutter)

```
almawqef/
├── .dart_tool/
├── .idea/
├── android/                       # تكوين Android
├── assets/                        # الموارد (صور، أيقونات)
├── build/                         # مخرجات البناء
├── ios/                           # تكوين iOS
├── l10n/                          # التوطين والترجمة
├── lib/                           # الكود المصدري الرئيسي
│   ├── main.dart                  # نقطة الدخول + تهيئة Firebase
│   │
│   ├── core/                      # الكود المشترك الأساسي
│   │   ├── constants/
│   │   │   ├── api_constants.dart     # جميع مسارات API
│   │   │   └── app_constants.dart     # ثوابت التطبيق
│   │   ├── di/
│   │   │   └── providers.dart         # حقن التبعيات (Riverpod)
│   │   ├── error/
│   │   │   ├── exceptions.dart        # استثناءات مخصصة
│   │   │   └── failures.dart          # أنواع الفشل
│   │   ├── network/
│   │   │   ├── api_client.dart        # عميل Dio + Interceptors
│   │   │   └── network_info.dart      # فحص الاتصال
│   │   ├── notifications/
│   │   │   └── notification_service.dart  # خدمة الإشعارات
│   │   ├── router/
│   │   │   └── app_router.dart        # GoRouter (كل المسارات)
│   │   ├── theme/
│   │   │   ├── app_colors.dart        # لوحة الألوان
│   │   │   ├── app_spacing.dart       # المسافات
│   │   │   ├── app_theme.dart         # ثيم Material 3 الكامل
│   │   │   └── app_typography.dart    # الخطوط
│   │   └── widgets/                   # الويدجت المشتركة
│   │       ├── app_bottom_nav.dart    # الشريط السفلي
│   │       ├── app_card.dart          # بطاقة موحدة
│   │       ├── error_state.dart       # شاشة الخطأ
│   │       ├── loading_widgets.dart   # مؤشرات التحميل
│   │       ├── rating_bar.dart        # شريط التقييم
│   │       ├── verified_badge.dart    # شارة التحقق
│   │       └── buttons/
│   │           └── primary_button.dart
│   │
│   ├── features/                  # الميزات (Feature-first)
│   │   ├── auth/                  # المصادقة
│   │   │   ├── data/
│   │   │   │   ├── datasources/   # AuthRemoteDataSource
│   │   │   │   ├── models/        # UserModel
│   │   │   │   └── repositories/  # AuthRepositoryImpl
│   │   │   ├── domain/
│   │   │   │   ├── entities/      # UserEntity
│   │   │   │   ├── repositories/  # AuthRepository (interface)
│   │   │   │   └── usecases/      # LoginUseCase, RegisterUseCase
│   │   │   └── presentation/
│   │   │       ├── providers/     # AuthProvider
│   │   │       └── screens/       # LoginScreen, RegisterScreen
│   │   │
│   │   ├── client/                # شاشات العميل
│   │   │   ├── data/
│   │   │   │   ├── datasources/   # ClientRemoteDataSource
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   └── repositories/  # ClientRepository
│   │   │   └── presentation/
│   │   │       ├── providers/     # ClientProvider
│   │   │       └── screens/       # 7 شاشات
│   │   │
│   │   ├── artisan/               # شاشات الحرفي
│   │   │   ├── data/
│   │   │   │   ├── datasources/   # ArtisanRemoteDataSource
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   └── repositories/
│   │   │   └── presentation/
│   │   │       ├── providers/     # ArtisanProvider
│   │   │       └── screens/       # 9 شاشات
│   │   │
│   │   ├── home/                  # الصفحة الرئيسية
│   │   │   ├── data/
│   │   │   │   ├── datasources/   # ServicesRemoteDataSource
│   │   │   │   ├── models/        # CategoryModel, ArtisanModel
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   └── repositories/
│   │   │   └── presentation/
│   │   │       ├── providers/     # HomeProvider, ServicesProvider
│   │   │       └── screens/       # HomeScreen
│   │   │
│   │   ├── notifications/         # الإشعارات
│   │   │   ├── data/
│   │   │   │   ├── datasources/   # NotificationRemoteDataSource
│   │   │   │   ├── models/        # NotificationModel
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   └── repositories/
│   │   │   └── presentation/
│   │   │       ├── providers/     # NotificationProvider
│   │   │       └── screens/       # NotificationsScreen
│   │   │
│   │   └── splash/                # شاشة البداية
│   │       └── presentation/
│   │           └── screens/       # SplashScreen
│   │
│   └── (ملفات أخرى)
│
├── team/                          # وثائق فريق العمل
│   ├── 01-ui-ux-review/           # مراجعة UI/UX
│   │   └── review.md
│   ├── 03-docs/                   # وثائق المشروع ← (أنت هنا)
│   └── 04-ui-ux-designer/         # ملفات المصمم
│
├── test/                          # اختبارات
├── web/                           # تكوين Web
├── windows/                       # تكوين Windows
├── pubspec.yaml                   # ملف الاعتماديات
└── README.md
```

### 📁 الخلفية (NestJS)

```
backend/
├── prisma/
│   ├── schema.prisma              # مخطط قاعدة البيانات (17 model)
│   ├── seed.ts                    # بيانات أولية للتطوير
│   └── seed-admin.ts              # إضافة مشرف
├── src/
│   ├── main.ts                    # نقطة الدخول + Swagger
│   ├── app.module.ts              # تجميع الوحدات
│   ├── app.controller.ts
│   │
│   ├── common/                    # مشترك
│   │   ├── dto/                   # PaginationDto
│   │   ├── filters/               # HttpExceptionFilter
│   │   ├── guards/                # RolesGuard, IpWhitelist, Throttler
│   │   ├── interceptors/          # TraceIdInterceptor
│   │   └── services/              # AntivirusService, EncryptionService
│   │
│   ├── prisma/                    # PrismaModule + PrismaService
│   ├── redis/                     # RedisModule + RedisService
│   │
│   └── modules/                   # وحدات API
│       ├── auth/                  # تسجيل، دخول، OAuth، OTP
│       ├── services/              # شجرة الخدمات (فئات هرمية)
│       ├── artisans/              # الحرفيين + الملفات + المحفظة + الوثائق
│       ├── reviews/               # التقييمات + الإشراف
│       ├── orders/                # الطلبات + WebSocket
│       ├── complaints/            # الشكايات
│       ├── subscriptions/         # الباقات والاشتراكات
│       ├── payments/              # الدفع (CMI) + WebSocket
│       ├── upload/                # رفع الصور
│       ├── notifications/         # الإشعارات + FCM
│       ├── ranking/               # نظام الترتيب (قابل للتخصيص)
│       └── (admin)                # نقاط نهاية الإدارة
│
├── docker-compose.yml             # PostgreSQL + Redis + ClamAV
├── package.json
├── tsconfig.json
└── .env
```

---

## 3. قائمة الشاشات (20 شاشة)

### 🔐 المصادقة (2 شاشات)

| # | الاسم (عربي) | الاسم (English) | المسار | الوصف | الحالة |
|---|-------------|-----------------|--------|-------|--------|
| 1 | شاشة البداية | Splash Screen | `/splash` | شاشة الترحيب الأولية + التحقق من التوكن والانتقال التلقائي | ✅ مكتملة |
| 2 | تسجيل الدخول | Login Screen | `/login` | تسجيل الدخول بالبريد الإلكتروني أو رقم الهاتف + كلمة المرور | ✅ مكتملة |
| 3 | إنشاء حساب | Register Screen | `/register` | إنشاء حساب جديد (عميل) بالاسم والهاتف والبريد وكلمة المرور | ✅ مكتملة |

### 🏠 الصفحة الرئيسية والخدمات (شاشتين)

| # | الاسم (عربي) | الاسم (English) | المسار | الوصف | الحالة |
|---|-------------|-----------------|--------|-------|--------|
| 4 | الصفحة الرئيسية | Home Screen | `/home` | عرض الفئات والخدمات الهرمية + الحرفيين المقترحين + شريط البحث السريع | ✅ مكتملة |
| 5 | البحث | Search Screen | `/search?q=` | نتائج البحث مع فلترة حسب الخدمة والفئة والموقع | ✅ مكتملة |

### 👤 شاشات العميل (Client) — 7 شاشات

| # | الاسم (عربي) | الاسم (English) | المسار | الوصف | الحالة |
|---|-------------|-----------------|--------|-------|--------|
| 6 | قائمة الحرفيين | Artisan List Screen | `/artisans/:serviceId` | قائمة الحرفيين لخدمة معينة مع الترتيب والمسافة والتصفية | ✅ مكتملة |
| 7 | ملف الحرفي (عام) | Artisan Profile Screen | `/artisan/:id` | الملف الشخصي للحرفي: السيرة، التقييمات، المعرض، الخدمات | ✅ مكتملة |
| 8 | التقييم | Review Screen | `/review/:artisanId` | إضافة تقييم وتعليق على خدمة | ✅ مكتملة |
| 9 | الخريطة | Map Screen | `/map/:serviceId` | عرض الحرفيين على الخريطة حسب الخدمة والموقع | ✅ مكتملة |
| 10 | حسابي | Account Screen | `/account` | الملف الشخصي للعميل + المفضلة + الإعدادات | ✅ مكتملة |
| 11 | تقديم شكوى | Complaint Screen | `/complaint/:artisanId` | تقديم شكوى ضد حرفي مع إرفاق صورة | ✅ مكتملة |
| — | الإشعارات | Notifications | `/notifications` | قائمة الإشعارات المسحوبة زمنيًا | ✅ مكتملة |

### 🛠 شاشات الحرفي (Artisan) — 9 شاشات

| # | الاسم (عربي) | الاسم (English) | المسار | الوصف | الحالة |
|---|-------------|-----------------|--------|-------|--------|
| 12 | لوحة التحكم | Dashboard Screen | `/artisan-dashboard` | إحصائيات الحرفي: الطلبات، التقييمات، الزوار | ✅ مكتملة |
| 13 | الطلبات الواردة | Requests Screen | `/artisan-requests` | قائمة طلبات العملاء مع إمكانية القبول/الرفض | ✅ مكتملة |
| 14 | التقييمات (حرفي) | Reviews Screen | `/artisan-reviews` | عرض وإدارة تقييمات الحرفي مع الردود | ✅ مكتملة |
| 15 | إدارة الحساب (حرفي) | Account Management Screen | `/artisan-account` | تعديل الملف الشخصي، السيرة، صورة الغلاف | ✅ مكتملة |
| 16 | الباقات والاشتراكات | Subscriptions Screen | `/subscriptions` | عرض الباقات المتاحة (FREE/PRO/PREMIUM) | ✅ مكتملة |
| 17 | الدفع | Payment Screen | `/payment?plan=` | واجهة الدفع عبر CMI + WebSocket | ✅ مكتملة |
| 18 | إعدادات الاشتراك | Subscription Settings Screen | `/subscription-settings` | إلغاء، ترقية، إعدادات التجديد التلقائي | ✅ مكتملة |
| 19 | معرض الأعمال | Portfolio Gallery Screen | `/artisan-gallery` | عرض/إضافة/حذف صور معرض الأعمال | ✅ مكتملة |
| 20 | ملف الحرفي (معاينة) | Artisan Profile View Screen | `/artisan-profile-view` | معاينة الملف الشخصي كما يراه العميل | ✅ مكتملة |
| — | معالج التسجيل (حرفي) | Wizard Screen | `/artisan-register` | معالج خطوة بخطوة لتسجيل حساب حرفي جديد | ✅ مكتملة |

> **ملاحظة:** إجمالي المسارات الفريدة = 22 مسارًا (20 شاشة فريدة + شاشتان إضافيتان هما الإشعارات ومعالج التسجيل).

---

## 4. دليل API

### 📍 العنوان الأساسي

```
Base URL: /api/v1
Swagger:  /api/docs
```

توثيق Swagger متاح عند تشغيل الخادم على: `http://localhost:3000/api/docs`

### 🔐 المصادقة — `/auth`

| الطريقة | المسار | الوصف | الحماية |
|---------|--------|-------|---------|
| POST | `/auth/register` | تسجيل مستخدم جديد (دور CLIENT) | عام |
| POST | `/auth/register/artisan` | تسجيل حساب حرفي جديد | عام |
| POST | `/auth/login` | تسجيل الدخول (Email/Phone + Password) | عام |
| POST | `/auth/refresh` | تجديد رمز الوصول عبر Refresh Token (Cookie) | JWT |
| POST | `/auth/logout` | تسجيل الخروج وإبطال جميع Refresh Tokens | JWT |
| POST | `/auth/oauth` | تسجيل الدخول عبر OAuth (Google/Facebook) | عام |
| POST | `/auth/otp/send` | إرسال رمز تحقق SMS | عام |
| POST | `/auth/otp/verify` | التحقق من OTP | عام |
| GET | `/auth/profile` | الملف الشخصي للمستخدم الحالي | JWT |

**مثال — تسجيل الدخول:**

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "ahmed@example.com",
  "password": "securePassword123"
}
```

**الاستجابة:**

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "uuid",
    "name": "أحمد",
    "phone": "+2126XXXXXXXX",
    "email": "ahmed@example.com",
    "role": "CLIENT",
    "image": null,
    "isVerified": false
  }
}
```

> يتم إرجاع `refreshToken` عبر Cookie (httpOnly, secure, sameSite=strict).

### 📂 الخدمات والفئات — `/services`

| الطريقة | المسار | الوصف | الحماية |
|---------|--------|-------|---------|
| GET | `/services` | قائمة الخدمات الهرمية (مع Redis Cache — TTL 1 ساعة) | عام |
| GET | `/services?q=...&category_id=...&cursor=...&limit=...` | بحث في الخدمات | عام |
| GET | `/services/:id` | تفاصيل خدمة معينة (Cache — TTL 30 دقيقة) | عام |
| POST | `/services` | إضافة خدمة جديدة | — |
| PUT | `/services/:id` | تحديث خدمة | — |
| DELETE | `/services/:id` | حذف خدمة (Soft delete) | — |

**مثال — جلب الخدمات:**

```http
GET /api/v1/services
```

**الاستجابة:**

```json
[
  {
    "id": "uuid",
    "name_ar": "البناء والتشييد",
    "name_fr": "Construction",
    "icon": "construction_icon",
    "order_index": 1,
    "parent_id": null,
    "artisan_count": 15,
    "children": [
      {
        "id": "uuid",
        "name_ar": "بناء",
        "name_fr": "Maçonnerie",
        "icon": null,
        "order_index": 1,
        "parent_id": "parent-uuid",
        "artisan_count": 8,
        "children": []
      }
    ]
  }
]
```

### 👨‍🔧 الحرفيين — `/artisans`

| الطريقة | المسار | الوصف | الحماية |
|---------|--------|-------|---------|
| GET | `/artisans?service_id=...&lat=...&lng=...&cursor=...&limit=...` | بحث وترتيب الحرفيين | عام |
| GET | `/artisans/:id` | ملف حرفي كامل (مع الخدمات + المعرض + التقييمات) | عام |
| PUT | `/artisans/:id/profile` | تحديث الملف الشخصي (bio, coverImage) | ARTISAN |
| POST | `/artisans/:id/cover` | رفع صورة الغلاف (multipart) | ARTISAN |
| GET | `/artisans/:id/portfolio` | معرض أعمال الحرفي | عام |
| POST | `/artisans/:id/portfolio` | إضافة صورة للمعرض (multipart) | ARTISAN |
| DELETE | `/artisans/:id/portfolio/:mediaId` | حذف صورة من المعرض | ARTISAN |
| POST | `/artisans/:id/services` | إضافة خدمة للحرفي | ARTISAN |
| PUT | `/artisans/:id/services/:serviceId` | تحديث سعر خدمة الحرفي | ARTISAN |
| DELETE | `/artisans/:id/services/:serviceId` | حذف خدمة الحرفي (soft) | ARTISAN |
| GET | `/artisans/documents` | قائمة وثائق الحرفي | ARTISAN |

**مثال — ملف حرفي كامل:**

```http
GET /api/v1/artisans/uuid
```

**الاستجابة:**

```json
{
  "id": "uuid",
  "bio": "نجار منذ 20 سنة...",
  "coverImage": "/uploads/artisans/cover/xxx.jpg",
  "ratingAvg": 4.5,
  "totalRatings": 27,
  "totalOrders": 45,
  "responseTimeAvg": 30,
  "rankingScore": 0.85,
  "isVerified": true,
  "user": {
    "id": "uuid",
    "name": "محمد البناوي",
    "image": "/uploads/avatars/xxx.jpg"
  },
  "services": [
    {
      "id": "uuid",
      "price": 350,
      "service": {
        "id": "uuid",
        "name_ar": "نجارة عامة",
        "name_fr": "Menuiserie générale"
      }
    }
  ],
  "portfolio": [
    {
      "id": "uuid",
      "imageUrl": "/uploads/portfolio/xxx.jpg",
      "thumbnailUrl": "/uploads/portfolio/thumbs/xxx.jpg",
      "description": "خزانة خشب"
    }
  ],
  "reviews": [
    {
      "id": "uuid",
      "rating": 5,
      "comment": "شغل ممتاز",
      "client": {
        "id": "uuid",
        "name": "أحمد"
      },
      "createdAt": "2026-06-15T10:30:00Z"
    }
  ]
}
```

### ⭐ التقييمات — `/reviews`

| الطريقة | المسار | الوصف | الحماية |
|---------|--------|-------|---------|
| POST | `/reviews` | إضافة تقييم (واحد لكل خدمة+عميل) | JWT |
| GET | `/reviews/:id` | تفاصيل تقييم | عام |
| GET | `/artisans/:artisanId/reviews` | تقييمات حرفي (public, paginated) | عام |
| PATCH | `/reviews/:id` | تعديل تقييم (صاحبه فقط) | JWT |
| DELETE | `/reviews/:id` | حذف تقييم (soft — صاحبه فقط) | JWT |
| GET | `/admin/reviews` | قائمة مراجعة التقييمات (ADMIN) | ADMIN |
| PATCH | `/admin/reviews/:id` | قبول/رفض تقييم (ADMIN) | ADMIN |

### 📦 الطلبات — `/orders`

| الطريقة | المسار | الوصف | الحماية |
|---------|--------|-------|---------|
| POST | `/orders` | إنشاء طلب خدمة (Client) | JWT |
| GET | `/orders/client?status=...&cursor=...&limit=...` | طلباتي كعميل | JWT |
| GET | `/orders/artisan?status=...&cursor=...&limit=...` | طلباتي كحرفي (واردة) | JWT |
| GET | `/orders/:id` | تفاصيل الطلب | JWT |
| PATCH | `/orders/:id/status` | تحديث حالة الطلب | JWT |
| PATCH | `/orders/:id/cancel` | إلغاء الطلب | JWT |
| DELETE | `/orders/:id` | حذف الطلب (ADMIN — Soft delete) | ADMIN |

**WebSocket — `/orders`:**

- الاحداث: `order.created` (للحرفي), `order.updated` (للعميل والحرفي)
- الانضمام: `subscribe:orders`
- التوثيق: عبر Bearer token في Headers أو query param

### 💰 الاشتراكات — `/subscriptions`

| الطريقة | المسار | الوصف | الحماية |
|---------|--------|-------|---------|
| GET | `/subscriptions/plans` | قائمة الباقات المتاحة | عام |
| POST | `/subscriptions/subscribe` | اشتراك جديد (ARTISAN) | ARTISAN |
| POST | `/subscriptions/cancel` | إلغاء الاشتراك | ARTISAN |
| POST | `/subscriptions/upgrade` | ترقية الباقة | ARTISAN |
| GET | `/subscriptions/my` | اشتراكي الحالي | ARTISAN |
| GET | `/subscriptions/admin` | كل الاشتراكات (ADMIN) | ADMIN |

**أنواع الباقات:**

| الباقة | السعر | تضخيم الترتيب | الميزات |
|--------|-------|--------------|---------|
| FREE | 0 درهم | ×1.0 | أساسية |
| PRO | (محدد) | ×1.2 | مميزة |
| PREMIUM | (محدد) | ×1.5 | كل الميزات + ظهور أول |

### 💳 الدفع — `/payments`

| الطريقة | المسار | الوصف | الحماية |
|---------|--------|-------|---------|
| POST | `/payments/init` | بدء عملية دفع — إعادة CMI form token | ARTISAN |
| POST | `/payments/webhook` | WebHook من بوابة CMI | IP Whitelist |
| GET | `/payments/status/:id` | استعلام حالة الدفع | JWT |

**WebSocket — `/ws/payments`:**

- الأحداث: `payment:confirmed`, `payment:failed`
- الانضمام: `subscribe:payment` مع `paymentId`

### 📢 الإشعارات — `/notifications`

| الطريقة | المسار | الوصف | الحماية |
|---------|--------|-------|---------|
| GET | `/notifications?cursor=...&limit=...` | قائمة الإشعارات (مسحوبة زمنيًا) | JWT |
| PATCH | `/notifications/:id/read` | تعيين إشعار كمقروء | JWT |
| POST | `/notifications/register-device` | تسجيل جهاز (FCM) | JWT |
| DELETE | `/notifications/unregister-device` | إلغاء تسجيل جهاز | JWT |

### ⚠️ الشكايات — `/complaints`

| الطريقة | المسار | الوصف | الحماية |
|---------|--------|-------|---------|
| POST | `/complaints` | تقديم شكوى ضد حرفي | JWT |
| GET | `/complaints` | شكايات المستخدم | JWT |
| GET | `/admin/complaints` | كل الشكايات (ADMIN) مع فلترة | ADMIN |
| PATCH | `/admin/complaints/:id` | تحديث حالة شكوى (ADMIN) | ADMIN |

### 📤 رفع الملفات — `/upload`

| الطريقة | المسار | الوصف | الحماية |
|---------|--------|-------|---------|
| POST | `/upload` | رفع صورة (jpg/jpeg/png/webp/gif, max 5MB) | ARTISAN |

### 📊 الترتيب — `/ranking`

| الطريقة | المسار | الوصف | الحماية |
|---------|--------|-------|---------|
| GET | `/ranking/config` | عرض إعدادات الترتيب الحالية | عام |
| PUT | `/ranking/config` | تحديث إعدادات الترتيب (weights, boosts) | ADMIN |
| POST | `/ranking/recalculate` | إعادة حساب Scores لكل الحرفيين | ADMIN |

### 🔐 المسارات الإدارية — `/admin`

| الطريقة | المسار | الوصف | الحماية |
|---------|--------|-------|---------|
| GET | `/admin/documents` | قائمة الوثائق المعلقة (PENDING) | ADMIN |
| GET | `/admin/documents/:id` | تفاصيل وثيقة | ADMIN |
| PATCH | `/admin/documents/:id` | قبول أو رفض وثيقة | ADMIN |
| GET | `/admin/reviews` | قائمة مراجعة التقييمات | ADMIN |
| PATCH | `/admin/reviews/:id` | قبول/رفض تقييم | ADMIN |
| GET | `/admin/complaints` | كل الشكايات | ADMIN |
| PATCH | `/admin/complaints/:id` | تحديث حالة شكوى | ADMIN |
| GET | `/subscriptions/admin` | كل الاشتراكات | ADMIN |

### 🗺 مخطط قاعدة البيانات (Prisma)

```
User ──┬── ClientProfile
       ├── ArtisanProfile ─── ArtisanService ─── Service
       │                   └── ArtisanPortfolio
       │                   └── ArtisanDocument
       ├── Review (as client/client)
       ├── Favorite
       ├── Order (as client/artisan)
       ├── Complaint (as complainant/target)
       ├── Subscription
       ├── Payment
       ├── Notification
       ├── Device
       ├── AuditLog
       └── RefreshToken
```

---

## 5. كيفية البدء

### 📋 المتطلبات الأساسية

- **Node.js** ≥ 18.x مع npm
- **Dart SDK** ≥ 3.7.2 مع Flutter (web)
- **Docker Desktop** (لقواعد البيانات)
- **Git**

### 🐳 1. تشغيل Backend

```bash
# الانتقال إلى مجلد الباك-إند
cd E:\charika\backend

# تشغيل قواعد البيانات (PostgreSQL + Redis + ClamAV)
docker compose up -d

# تثبيت الاعتماديات
npm install

# توليد عميل Prisma + تطبيق الترحيلات
npx prisma generate
npx prisma migrate dev --name init

# (اختياري) إضافة بيانات أولية
npx ts-node prisma/seed.ts

# تشغيل الخادم (وضع التطوير)
npm run start:dev
```

الخادم سيعمل على: `http://localhost:3000`
توثيق Swagger: `http://localhost:3000/api/docs`

### 🎨 2. تشغيل Flutter (الواجهة الأمامية)

```bash
# الانتقال إلى مجلد Flutter
cd E:\charika\almawqef

# تثبيت الاعتماديات
flutter pub get

# تشغيل على المتصفح (Web)
flutter run -d chrome

# أو بناء نسخة الإنتاج
flutter build web
```

التطبيق سيفتح على: `http://localhost:52729` (المنفذ قد يختلف)

### 🧪 3. تشغيل Mock Server (للاختبار)

إذا لم يكن Backend متاحًا، يمكن تعديل `api_constants.dart` ليشير إلى:

```dart
static const String baseUrl = 'http://localhost:3001/api/v1';
```

ثم استخدام json-server أو أي أداة mock أخرى.

### 🏗️ هيكل المطورين — `team/`

```
almawqef/team/
├── 01-ui-ux-review/      # مراجعة تصميم UI/UX
│   └── review.md
├── 03-docs/               # (أنت هنا) وثائق المشروع
└── 04-ui-ux-designer/     # ملفات المصمم
```

---

## 📌 ملاحظات إضافية

### 🧪 إعدادات البيئة (Backend)

انسخ ملف `.env.example` إلى `.env` واملأ القيم:

```
PORT=3000
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/elmokef"
REDIS_URL="redis://localhost:6379"
JWT_SECRET="your-secret-key"
CORS_ORIGIN="http://localhost:52729"
```

### 🔑 صلاحيات الأدوار

| الدور | الوصف |
|-------|-------|
| `CLIENT` | عميل يبحث عن حرفيين ويطلب خدمات ويقيم |
| `ARTISAN` | حرفي يدير ملفه وخدماته واشتراكه ويستقبل الطلبات |
| `ADMIN` | مشرف يدير التقييمات والشكايات والوثائق والترتيب |

### 🌐 إشعارات WebSocket

- **الطلبات:** `/orders` namespace — إشعارات فورية بالطلبات الجديدة والتحديثات
- **الدفع:** `/ws/payments` namespace — تأكيد/فشل الدفع لحظيًا

### 🎨 نظام الألوان (Material 3)

- **اللون الرئيسي:** زمردي (#059669) — ثقة ونمو
- **لون الإظهار:** كهرماني (#F59E0B) — دفء ونشاط
- **الخلفية:** رمادي فاتح (#F8FAFC) — نظافة وبساطة
- **النصوص:** كحلي (#111827) — وضوح وقراءة
- **ما يشبه واتساب:** (#25D366) — للتواصل مع الحرفي

---

> **آخر تحديث:** 18 يونيو 2026
> **المسار:** `E:\charika\almawqef\team\03-docs\README.md`
