# 📦 Flutter API Integration — Outbox Report
## مشروع الميقف (Elmokef)

**التاريخ:** 2026-06-18
**الحالة:** ✅ مكتمل — API Integration جاهز

---

## 🎯 ملخص المنجز

ربط كامل لـ Flutter بـ API الحقيقي للباك-إند. تم الحفاظ على كل الموك البيانات (Mock Data) السابق وإضافة API بجانبها كمصدر أساسي.

---

## 📁 الملفات المضافة

### 1. Auth Flow — `lib/features/auth/`

| الملف | الوصف |
|---|---|
| `domain/entities/user_entity.dart` | كيان المستخدم الأساسي |
| `domain/repositories/auth_repository.dart` | الواجهة المجردة للمصادقة |
| `domain/usecases/login_usecase.dart` | Use Case لتسجيل الدخول |
| `domain/usecases/register_usecase.dart` | Use Case للتسجيل |
| `data/models/user_model.dart` | Model JSON ↔ Entity |
| `data/datasources/auth_remote_datasource.dart` | استدعاءات API عبر Dio |
| `data/repositories/auth_repository_impl.dart` | تطبيق repository مع token storage |

**نقاط النهاية المستخدمة:**
- `POST /auth/login` ← تسجيل الدخول (بريد أو هاتف)
- `POST /auth/register` ← تسجيل عميل
- `POST /auth/register/artisan` ← تسجيل حرفي
- `GET /auth/profile` ← جلب الملف الشخصي
- `POST /auth/logout` ← تسجيل الخروج

**التخزين:** JWT tokens في `flutter_secure_storage`

### 2. Home & Services — `lib/features/home/`

| الملف | الوصف |
|---|---|
| `data/datasources/services_remote_datasource.dart` | **(معدل)** — إضافة API حقيقي |
| `data/models/category_model.dart` | **(معدل)** — تغيير id من int إلى String UUID |
| `data/repositories/services_repository_impl.dart` | **(معدل)** — تحويل إلى API + NetworkInfo |
| `domain/repositories/services_repository.dart` | **(معدل)** — String IDs |
| `presentation/providers/services_provider.dart` | **(معدل)** — إضافة artisan/profile/portfolio providers |

**نقاط النهاية المستخدمة:**
- `GET /services` ← شجرة الفئات (category tree)
- `GET /services?q=...` ← بحث في الخدمات
- `GET /artisans?service_id=...` ← بحث عن حرفيين
- `GET /artisans` ← حرفيين مقترحين

### 3. Client Flow — `lib/features/client/`

| الملف | الوصف |
|---|---|
| `domain/repositories/client_repository.dart` | واجهة عمليات العميل |
| `data/datasources/client_remote_datasource.dart` | API للعميل |
| `data/repositories/client_repository_impl.dart` | تطبيق العميل |
| `presentation/providers/client_provider.dart` | Riverpod providers |

**نقاط النهاية المستخدمة:**
- `POST /reviews` ← إرسال تقييم
- `POST /complaints` ← تقديم شكوى
- `GET /favorites` ← المفضلة

### 4. Artisan Flow — `lib/features/artisan/`

| الملف | الوصف |
|---|---|
| `domain/repositories/artisan_repository.dart` | واجهة الحرفي (ArtisanStats DTO) |
| `data/datasources/artisan_remote_datasource.dart` | API للحرفي مع رفع صور |
| `data/repositories/artisan_repository_impl.dart` | تطبيق الحرفي |
| `presentation/providers/artisan_provider.dart` | Riverpod providers مع artisanId من auth |

**نقاط النهاية المستخدمة:**
- `GET /artisans/:id/stats` ← إحصائيات لوحة التحكم
- `GET /artisans/:id/requests` ← الطلبات
- `PUT /artisans/:id/profile` ← تحديث الملف
- `POST /artisans/:id/services` ← إضافة خدمة
- `PUT /artisans/:id/services/:serviceId` ← تعديل سعر الخدمة
- `DELETE /artisans/:id/services/:serviceId` ← حذف خدمة
- `GET /subscriptions/plans` ← الباقات
- `POST /subscriptions/subscribe` ← اشتراك
- `POST /subscriptions/cancel` ← إلغاء
- `POST /subscriptions/upgrade` ← ترقية
- `GET /subscriptions/my` ← اشتراكي الحالي
- `POST /upload` ← رفع صور
- `POST /artisans/:id/portfolio` ← إضافة صورة للمعرض
- `DELETE /artisans/:id/portfolio/:mediaId` ← حذف من المعرض
- `GET /artisans/:id/portfolio` ← معرض الأعمال

### 5. Core Changes — `lib/core/`

| الملف | التغيير |
|---|---|
| `network/api_client.dart` | **(معدل)** — إضافة `_AuthInterceptor` يسحب Bearer token من secure storage |
| `di/providers.dart` | **(معدل)** — إضافة `secureStorageProvider`، تمرير storage لـ ApiClient |
| `router/app_router.dart` | **(معدل)** — تغيير path params من int إلى String (UUID) |
| `constants/api_constants.dart` | **(معدل)** — إضافة endpoints جديدة (registerArtisan, logout, profile, upload, complaints, subscription sub-routes) |

### 6. Pubspec

| الملف | التغيير |
|---|---|
| `pubspec.yaml` | **(معدل)** — إضافة `flutter_secure_storage: ^9.2.4` |

---

## 🔐 Auth Flow — كيف يعمل

```
User → Login/Register Screen → AuthNotifier.login()
  → AuthRepositoryImpl.login()
    → AuthRemoteDataSource.login() → Dio POST /auth/login
    ← { user, accessToken, refreshToken }
    → FlutterSecureStorage.write(accessToken)
    → AuthNotifier updates state (authenticated)

All subsequent API calls:
  ApiClient._AuthInterceptor → secureStorage.read(accessToken)
    → Dio headers: Authorization: Bearer <token>
```

---

## 📋 هيكلة البيانات — الفروقات مع الموك

| الموك (قديم) | API (جديد) |
|---|---|
| `id: int` | `id: String` (UUID) |
| `snake_case` fields | `snake_case` أو `camelCase` — الـ Model يتعامل مع الاتنين |
| `artisan_count` من JSON مباشر | `_count.artisanServices` من Prisma |
| Mock artisan list مع بيانات ثابتة | `ArtisanPublicDto` من الباك-إند مع user, services, portfolio, reviews |

---

## ✅ قائمة التحقق النهائية

- [x] Auth login/register/logout مع JWT
- [x] Secure Storage للتوكين
- [x] Auth Interceptor يضيف Bearer token لكل الطلبات
- [x] Service categories من API
- [x] Artisan list بالبحث عن service_id
- [x] Artisan profile (public) من API
- [x] Artisan reviews من API
- [x] Artisan portfolio من API
- [x] Client: إرسال تقييم + شكوى
- [x] Artisan dashboard stats
- [x] Artisan requests
- [x] Subscription plans + اشتراك + إلغاء + ترقية
- [x] Portfolio gallery (رفع + حذف)
- [x] رفع الصور Upload
- [x] الموك البيانات محفوظة جنب API كـ fallback
- [x] نفس النمط: Riverpod providers, repositories, datasources

---

## 🔧 المتبقي / توصيات

1. **إضافة `refresher` للتوكين** — حالياً التوكين منتهي (15m) بدون refresh. أضف `AuthInterceptor` يعيد توجيه لـ `/auth/refresh` عند 401.
2. **Splash screen** — الآن يتفقد `authProvider` ويوجه حسب الحالة.
3. **Home screen** يستخدم `categoriesProvider` و `suggestedArtisansProvider` من API — الموك ملغي إلا إذا فشل API.
4. **اختبار** — الـ API يحتاج باك-إند شغال على `https://api.elmokef.ma/api/v1`. غيّر `baseUrl` في `api_constants.dart` إذا كان محلياً.
5. **Notifications** — الـ remote data source والـ repository جاهزين بالفعل ويستخدمون API.
