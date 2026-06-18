# تقرير Sprint 2 — Flutter Developer

**إعداد:** خالد العمري — Flutter Developer  
**التسليم إلى:** الرئيس التنفيذي  
**التاريخ:** 17 يونيو 2026  
**فترة Sprint 2:** 6 يوليو – 17 يوليو 2026  
**الحالة:** 📋 مقترح — بانتظار الاعتماد

---

## 1. الملخص التنفيذي

Sprint 2 يركز على 3 محاور رئيسية: (1) ربط API الحقيقي بالشاشات، (2) إكمال PoC الخرائط والإشعارات، (3) إضافة Artisan Registration Wizard. Sprint 1 أنتج 12 شاشة ثابتة (static UI) — الآن وقت تحويلها إلى تطبيق حي يتكلم مع Backend.

---

## 2. المهام المقررة

### 2.1 🔴 ربط API — Data Layer (الأولوية القصوى)

**الهدف:** بناء طبقة البيانات الكاملة لتغذية الشاشات من API حقيقي

| المكون | التفاصيل | الملفات | الأيام |
|--------|---------|--------|--------|
| **Dio Client** | إنشاء ApiClient مع interceptors (auth, logging, error) + base URL من `api_constants.dart` | `lib/core/network/api_client.dart` | 1 |
| **Network Info** | كشف الاتصال بالإنترنت (connectivity_plus) | `lib/core/network/network_info.dart` | 0.5 |
| **Auth API** | تسجيل دخول/خروج عبر API + تخزين JWT في Hive | `features/auth/data/` | 1.5 |
| **Services API** | جلب فئات الخدمات + قائمة الحرفيين + ملف حرفي | `features/client/data/` | 2 |
| **Reviews API** | إرسال تقييم + جلب تقييمات | `features/client/data/` | 1 |
| **Favorites API** | إضافة/إزالة/عرض المفضلة | `features/client/data/` | 1 |
| **Artisan API** | Dashboard stats + طلبات + ملف حرفي | `features/artisan/data/` | 2 |
| **Subscription API** | جلب الباقات + اشتراك + دفع | `features/artisan/data/` | 1.5 |

**المجموع:** ~10.5 يوم

**إجمالي أيام API:** 3 أيام ← 5 أيام (حسب جاهزية Backend من محمد)

### 2.2 🔴 PoC الخرائط — Google Maps vs OSM

**الهدف:** اختبار ومقارنة Google Maps و OpenStreetMap في السياق المغربي

| اليوم | المهمة | التسليم |
|-------|--------|---------|
| **Day 1** | إعداد Google Maps API key + `google_maps_flutter` على جهاز حقيقي | خريطة تعمل مع تحديد موقع |
| **Day 2** | إعداد `flutter_map` + OSM tiles + MapTiler | خريطة OSM تعمل مع نفس الموقع |
| **Day 3** | اختبار A/B: دقة GPS في الدار البيضاء، الرباط، فاس + استهلاك البطارية + RTL | تقرير PoC مع توصية |

**المخرجات المتوقعة:**
- `LocationService` abstract class مع implementers
- `GoogleMapsLocationService` و `OSMLocationService`
- Riverpod provider للتبديل التلقائي

### 2.3 🟠 PoC إشعارات Huawei

**الهدف:** ضمان وصول الإشعارات على أجهزة Huawei (بدون Google Play Services)

| اليوم | المهمة | التسليم |
|-------|--------|---------|
| **Day 1** | إعداد HMS account + تنزيل `huawei_push` | Push token يظهر في الـ Log |
| **Day 2** | إرسال إشعار تجريبي من Firebase + HMS Console | إشعار يصل على Huawei (3 حالات) |
| **Day 3** | بناء `flutter_universal_push` service مع conditional import | Service واحد يعمل على Google + Huawei |

### 2.4 🟠 Artisan Registration Wizard

**المتطلب:** 4 شاشات Wizard لتسجيل الحرفي الجديد (A2a→A2d من تصاميم ليلى)

| الخطوة | المحتوى | الملف |
|--------|---------|-------|
| **Step 1** | معلومات شخصية (اسم، هاتف، مدينة، صورة) | `wizard_step1_screen.dart` |
| **Step 2** | اختيار الخدمات والأسعار (CheckboxListTile + PriceField) | `wizard_step2_screen.dart` |
| **Step 3** | رفع صور الأعمال + صورة الهوية (ImagePicker + preview) | `wizard_step3_screen.dart` |
| **Step 4** | اختيار باقة الاشتراك (RadioListTile — 3 plans) | `wizard_step4_screen.dart` |

**التنفيذ:** `Stepper` widget + Riverpod State لكل خطوة مع إمكانية الرجوع

### 2.5 🟡 Localization — ARB Files

**الهدف:** تجهيز ملفات الترجمة العربية والفرنسية لجميع النصوص الثابتة

| الملف | المحتوى |
|-------|---------|
| `l10n/app_ar.arb` | ~50 مفتاح: عناوين، أزرار، تسميات، رسائل خطأ |
| `l10n/app_fr.arb` | نفس المفاتيح بالفرنسية |

### 2.6 🟡 Offline Support — Hive Caching

| البيانات | استراتيجية التخزين |
|---------|-------------------|
| فئات الخدمات | Hive box — تحديث كل 1 ساعة |
| قائمة الحرفيين | Hive box — تحديث كل 5 دقائق |
| ملف الحرفي | Hive box فردي — تحديث عند كل فتح |
| تفضيلات المستخدم | SharedPreferences |

### 2.7 🟢 Build APK + Testing

| المهمة | التفاصيل |
|-------|---------|
| Build APK | `flutter build apk --release` + اختبار على Redmi 9 |
| Widget Tests | اختبار لكل شاشة رئيسية (pumpWidget + find) |
| Unit Tests | اختبار للـ Repositories و UseCases |
| Performance | Flutter DevTools + Profile mode (55+ FPS) |

---

## 3. الجدول الزمني (10 أيام عمل — 22 يونيو → 3 يوليو)

| اليوم | المهام |
|------|--------|
| **اليوم 1-2** | 🔴 PoC الخرائط — Google Maps + OSM + تقرير |
| **اليوم 3** | 🔴 PoC إشعارات Huawei — HMS + FCM + تقرير |
| **اليوم 4-6** | 🔴 ربط API — Dio + Auth + Services + Reviews |
| **اليوم 7-8** | 🟠 Artisan Wizard — 4 شاشات + Stepper |
| **اليوم 9** | 🟡 Localization + Offline Hive Caching |
| **اليوم 10** | 🟢 Build APK + اختبارات |

---

## 4. التحديات المتوقعة

| التحدي | التأثير | خطة التخفيف |
|--------|---------|-------------|
| **Backend API غير جاهز** (من محمد) | تأخير ربط API | استخدام Mock API (JSON محلي + Dio MockAdapter) |
| **Huawei device غير متوفر** | PoC Huawei يتأخر | استخدام AVD مع Huawei Mobile Services (HMS) kit |
| **Google Maps API Key غير مفعل** | PoC Google Maps يتأخر | البدء بـ OSM أولاً + الانتظار |
| **WebView CMI للدفع** | رفض Apple | SafariViewController / Chrome Custom Tabs |

---

## 5. الموارد المطلوبة

- [ ] **Google Maps API Key** (لاختبار الخريطة)
- [ ] **حساب Huawei Developer** + HMS (لاختبار الإشعارات)
- [ ] **جهاز Huawei حقيقي** (يفضل P30/P40 أو Nova)
- [ ] **API endpoints** من محمد العلي (Backend) — أو Mock API
- [ ] **أيقونات SVG** من ليلى (للفئات + الواجهة)
- [ ] **مساحة 20 جيجابايت** على القرص لبناء APK
- [ ] **جهاز Redmi 9 أو A系列** لاختبار الأداء

---

## 6. المخرجات المتوقعة بنهاية Sprint 2

- [ ] تطبيق يتكلم مع API حقيقي (أو Mock)
- [ ] PoC قرار Google Maps vs OSM + التوصية
- [ ] إشعارات تعمل على Huawei + Google
- [ ] 4 شاشات Wizard لتسجيل الحرفي
- [ ] ترجمة عربية + فرنسية
- [ ] APK Release جاهز للتثبيت
- [ ] 55+ FPS على Redmi 9 (قائمة الحرفيين)

---

## 7. الاعتماديات (Dependencies)

```
Sprint 2 ─┬─ API Integration ──────── يعتمد على ← Backend Developer (محمد)
           ├─ PoC Maps ────────────── يعتمد على ← Google Maps API Key
           ├─ PoC Huawei ───────────── يعتمد على ← Huawei Developer Account
           ├─ Icons/Assets ─────────── يعتمد على ← UI/UX Designer (ليلى)
           └─ Build APK ────────────── يعتمد على ← DevOps (مساحة + CI)
```

---

**الخلاصة:** جاهز لبدء Sprint 2 حال اعتماد الخطة وتوفر الموارد المطلوبة. أوصي بـ **Mock API** كخطة بديلة في حال تأخر Backend.

— خالد العمري | Flutter Developer
