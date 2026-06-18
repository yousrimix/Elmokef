# المرحلة 2: النقاش الداخلي — Elmokef
## رأي Flutter Developer — خالد العمري

**تقييم عام:** تحليل سارة ممتاز وشامل. سأركز على التحديات التقنية من منظور Flutter بناءً على متطلبات التحليل.

---

### 1. 🔴 الخرائط والموقع — تحدٍّ تقني أول

**المتطلبات:** FR-02 (GPS تلقائي + يدوي)، FR-05 (ترتيب حسب المسافة)

**التحديات:**
- التبديل بين **Google Maps + OpenStreetMap (OSM)** حسب توفر الخدمة — خطر: OSM على Flutter يتطلب حزمة `flutter_map` التي تختلف كلياً في الـ API عن `google_maps_flutter`. هذا يعني واجهتين منفصلتين للخريطة أو طبقة تجريد (abstraction layer)
- **NFR-09 (استهلاك البطارية):** تتبع GPS المستمر يستهلك بطارية. الحل: استخدام `geolocator` مع تحديثات بتباعد 500 متر أو 5 دقائق، وتفعيل التتبع الدقيق فقط عند فتح شاشة البحث
- **RTL مع الخرائط:** اتجاه الشمال في الخريطة لا يجب أن ينعكس مع RTL — خطر مع `flutter_map` والتحكم في الـ compass
- **التحديد اليدوي:** شاشة اختيار موقع من الخريطة (pin) مع زر تأكيد — تحتاج `flutter_picker` أو Custom Google Maps controller

**التوصية:** بناء `LocationService` abstract مع `GoogleMapsLocationService` و `OSMLocationService` implementers. استخدام Riverpod لتحديد service نشط والتبديل التلقائي عند فشل GPS.

---

### 2. 🔴 RTL + localization — Arabic + French

**المتطلبات:** NFR-07 (عربي + فرنسي)

**التحديات:**
- Flutter يدعم RTL جيداً لكن الأرقام المختلطة (رقم هاتف، سعر) في نص عربي قد تظهر بترتيب خاطئ
- العربية المغربية (دارجة) والنص الفرنسي بحروف لاتينية — الحروف الخاصة (é, à, ç) يجب أن تكون مدعومة في الخط المختار
- اتجاه `flutter_map` (OSM tile) قد ينعكس في RTL
- **اختبار RTL:** كل شاشة تحتاج اختبار بصري باللغتين — أؤكد توصية رنا باختبار RTL من Sprint 1

**التوصية:** استخدام `flutter_localizations` + `intl` مع ملفات `.arb`. اختيار خط يدعم العربية والفرنسية (مثل Cairo أو Tajawal) وتجربته على أجهزة حقيقية.

---

### 3. 🟠 أداء قائمة الحرفيين — 55+ FPS على أجهزة ضعيفة

**المتطلبات:** FR-05 (قائمة مرتبة)، MS-04 (55 FPS على Redmi 9)

**التحديات:**
- قائمة تحتوي 100+ حرفي مع: صورة، اسم، تقييم (نجوم)، مسافة، سعر، حالة اشتراك — كل عنصر قد يحتوي 10+ Widget
- الصور من الشبكة + صور معرض الحرفي ← caching + lazy loading
- حساب المسافة وعرضها مع كل عنصر ← لا يجب إعادة حسابها عند scroll

**التوصية:**
- استخدام `ListView.builder` + `const` constructors + `Shimmer` للـ loading
- `cached_network_image` مع placeholder + compression
- تخزين `distance` محسوبة مسبقاً من API — لا نحسبها محلياً
- تجربة `AutomaticKeepAliveClientMixin` للعناصر المرئية
- اختبار أداء باستخدام `Flutter DevTools` + `Profile mode` من Sprint 2

---

### 4. 🟠 رفع الصور — ضغط + إلغاء + استئناف

**المتطلبات:** FR-15 (صور أعمال)، FR-12 (صورة هوية)، NFR-09 (ضغط ≤500KB)

**التحديات:**
- ضغط الصورة مع الحفاظ على 1080p على الأقل
- انقطاع الرفع مع 4G/3G — لا يوجد مكون built-in في Flutter للـ upload resume
- معرض الصور (Gallery View) مع zoom — يحتاج حزمة مثل `photo_view`
- هوية الحرفي: واجهة رفع + نص "لن تظهر للعملاء" + حالة التحقق

**التوصية:**
- `image_picker` + `flutter_image_compress` مع compression 70-80% أولاً ثم رفع
- `dio` مع `onSendProgress` لشريط التقدم (progress bar)
- تجربة `flutter_uploader` للخلفية (background upload)
- `cached_network_image` + `photo_view` للمعرض

---

### 5. 🟠 الإشعارات — Foreground + Background + Killed + Huawei

**المتطلبات:** US-16 (إشعارات الحرفي)، MS-02 (12 سيناريو)

**التحديات:**
- أجهزة **Huawei لا تحتوي Google Play Services** ← `firebase_messaging` لا يعمل. الحل: `huawei_push` مع `flutter_local_notifications`
- 3 حالات للتطبيق مع سلوك مختلف لكل حالة
- الإشعارات بالعربية قد تظهر مشوشة في نظام التشغيل إذا كان الجهاز بالإنجليزية
- الإشعارات عند killed state تتطلب `onBackgroundMessage` handler على مستوى top-level

**التوصية:**
- `firebase_messaging` + `huawei_push` مع `conditional import` (اختيار الخدمة حسب الجهاز)
- اختبار على **Huawei حقيقي** قبل الإطلاق — ضروري
- `flutter_local_notifications` لعرض الإشعارات محلياً في foreground
- فصل payload الإشعارات: `type` + `data` (لا text حساس)

---

### 6. 🟡 WebView الدفع — CMI

**المتطلبات:** US-18 (اشتراك ودفع)

**التحديات:**
- فتح WebView → دفع → استقبال callback → تحديث UI — كلها تحتاج تنسيق بين WebView و Dart
- فقدان الجلسة (session) عند العودة من WebView
- فشل الدفع (بطاقة منتهية، رصيد غير كافٍ) ← رسالة خطأ غير واضحة من البوابة
- SSL Pinning على WebView (حسب توصية فيصل)

**التوصية:**
- `webview_flutter` مع `NavigationDelegate` لاعتراض redirect URL بعد الدفع
- استخدام `JavaScriptChannel` للتواصل مع صفحة الدفع
- واجهة مستخدم: WebView داخل BottomSheet مع عنوان URL آمن visible للمستخدم
- اختبار دورة كاملة من Sprint 3

---

### 7. 🟡 الاتصال بالحرفي — Phone + WhatsApp deep link

**المتطلبات:** FR-07 (اتصال هاتف/واتساب)

**التحديات:**
- فتح تطبيق الهاتف: `launchUrl('tel:0633XXXXXX')` — بسيط
- فتح WhatsApp: `launchUrl('https://wa.me/212633XXXXXX')` — يعمل لكن إذا لم يكن WhatsApp مثبتاً، يتجه إلى المتصفح
- دعم أرقام المغرب: رمز الدولة +212 يجب إضافته تلقائياً للأرقام المحلية
- تسجيل "الطلب" في `contact_log` (حسب توصية نور) — نحتاج لتسجيل وقت ومدة الاتصال. هذا مستحيل مع deep link لأننا نغادر التطبيق.

**التوصية:**
- تأكيد تثبيت التطبيق عبر `canLaunchUrl()` قبل الاتصال
- إضافة `contact_log` في الخادم عند النقر على "اتصال" (وليس عند إتمام المكالمة)
- استخدام `url_launcher` للـ deep links
- نصيحة UX: بعد العودة للتطبيق، اسأل "هل تمت الخدمة؟" ← فرصة للتقييم

---

### 8. 🟢 الهندسة المعمارية — Clean Architecture + Riverpod

**القرارات التقنية:**

| القرار | الاختيار | السبب |
|-------|---------|-------|
| State Management | **Riverpod** | لا يعتمد على BuildContext، اختبار سهل، supported code generation |
| HTTP Client | **Dio** | Interceptors، cancellation، progress، retry (لـ offline) |
| Routing | **GoRouter** | Deep links، redirect guards (للمصادقة)، nested navigation |
| Local Storage | **Hive + SharedPreferences** | Hive للتخزين الكبير (القوائم)، SharedPreferences للإعدادات |
| Localization | **Flutter i18n + ARB** | متوافق مع Flutter natively |
| Maps | **Google Maps + flutter_map (OSM)** | Fallback strategy |
| Code Gen | **freezed + json_serializable + riverpod_generator** | تقليل boilerplate |
| Responsive | **flutter_screenutil** أو LayoutBuilder | تناسب جميع الشاشات |

**هيكل المشروع المقترح:**
```
lib/
├── core/
│   ├── constants/        # API keys, endpoints, app strings
│   ├── error/            # Exceptions, failures (dartz Either)
│   ├── network/          # Dio client, interceptors, network_info
│   ├── router/           # GoRouter config + guards
│   ├── theme/            # Colors, typography, spacing, theme
│   ├── localization/     # L10n delegate + ARB files
│   ├── utils/            # Extensions, validators, helpers
│   └── di/               # Riverpod providers (global)
├── features/
│   ├── auth/             # Login, register, OAuth
│   │   ├── data/         # DTOs, datasources, repositories_impl
│   │   ├── domain/       # Entities, repository interfaces, usecases
│   │   └── presentation/ # Providers, screens, widgets
│   ├── client/           # Client home, search, favorites
│   ├── artisan/          # Artisan profile, services, portfolio
│   ├── ranking/          # Ranking list, filters, sorting
│   ├── subscription/     # Plans, payment, history
│   ├── admin/            # Admin dashboard (Web-focused)
│   └── splash/           # Splash screen + init logic
└── main.dart
```

---

### 9. 🟢 Offline Support — استراتيجية

**المتطلبات:** Non-functional (offline support مذكور في التكليف)

**التحديات:**
- قوائم الحرفيين وبياناتهم يجب أن تكون متاحة عند انقطاع الإنترنت
- التقييمات الجديدة يجب أن تُخزن محلياً وتُرفع لاحقاً (sync)
- APK size: Hive يضيف ~2MB، cached_network_image يضيف ~1MB

**التوصية:**
- تخزين `artisan_list` و `categories` و `artisan_profiles` في Hive cache
- إظهار "آخر تحديث: منذ ساعة" بجانب البيانات المخزنة
- أولوية التخزين: الفئات > قائمة الحرفيين > الملفات الشخصية > الصور
- استخدام `connectivity_plus` للكشف عن الاتصال

---

### 10. 🟢 تساؤلات واستيضاحات

1. **خوارزمية الترتيب (FR-05):** هل يحسبها الـ API ويرسل النتيجة مرتبة؟ أم نستلم الحرفيين ونحسب الترتيب محلياً في Flutter؟ أقترح الطريقة الأولى (API) لأن الوزن قد يتغير بدون تحديث للتطبيق.

2. **حساب المسافة:** هل API يرسل `distance` محسوبة أم نستخدم موقع العميل + `lat/lng` الحرفي لحساب المسافة محلياً باستخدام Haversine؟ أقترح API يرسل distance جاهزة ومفرزة.

3. **الموقع الجغرافي للعميل:** هل نخزنه أم لا حسب توصية نور وفيصل؟ أحتاج القرار لتصميم `LocationService`. أقترح: لا نخزنه — نستخدمه لحظياً فقط ونرسله مع كل طلب بحث.

4. **WhatsApp Business API:** هل هناك خطة لدمج WhatsApp Business API لإرسال واستقبال الرسائل داخل التطبيق (بدلاً من deep link)؟

5. **تطبيق الإدارة (Admin):** هل سيكون تطبيق Flutter منفصل أم جزءاً من نفس التطبيق مع مخفي (hidden)؟ أقترح تطبيقاً منفصلاً لتقليل حجم APK وأمان أفضل.

6. **نظام الخطط (Subscription Tiers):** هل هناك مزايا إضافية في الـ UI للباقات المدفوعة (شعار "مميز"، لون مختلف، فلتر حسب الباقة)؟

7. **تصميم UI/UX:** متى نتسلم التصاميم؟ أحتاجها بالعربية (RTL) والفرنسية لأبدأ التطوير.

---

### الخلاصة

التحدي الأكبر من ناحية Flutter هو **الخرائط والموقع + أداء القائمة على الأجهزة الضعيفة + إشعارات Huawei**. التوصيات المذكورة أعلاه تحتاج اختباراً مبكراً على أجهزة حقيقية (خاصة Redmi 9 و Huawei) في Sprint 1 نفسه. أوصي بـ **Proof of Concept (PoC)** لمدة 3 أيام قبل بدء التطوير للتحقق من جدوى حل الخرائط والإشعارات المزدوجة.

جاهز لبدء التطوير فور استلام التصميمات.
