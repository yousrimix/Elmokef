# تدقيق الكود — تطبيق الميقف (Elmokef)

**التاريخ:** 2026-06-19  
**النطاق:** `E:\charika\almawqef\lib\`  
**المراجـع:** subagent audit  

---

## الملخص التنفيذي

| النوع | العدد |
|-------|-------|
| ⛔ حرج | 5 |
| ⚠️ متوسط | 12 |
| 💡 تحسين | 15 |

---

# ⛔ حرج — خطأ يوقف التطبيق

### 1. `dart:html` import في api_client.dart

**الملف:** `lib/core/network/api_client.dart`  
**السطر:** `import 'dart:html' show window;` (السطر 1)  
**الوصف:** استخدام `dart:html` يجعل التطبيق يشتغل **فقط على الويب**. الكود يستعمل `window.localStorage` للـ token على الويب و `flutter_secure_storage` للموبايل، لكن الـ import نفسه يمنع compile على أندرويد/iOS.  
**الحل:** استعمال `package:universal_io` أو `package:universal_html` أو فصل الـ import خلف `conditional exports`/`kIsWeb`.

---

### 2. تشويه النص العربي (Mojibake) في home_screen.dart

**الملف:** `lib/features/home/presentation/screens/home_screen.dart`  
**الوصف:** كل النصوص العربية في الملف مشوهة — مثل:  
`Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ©` بدلاً من `الرئيسية`  
`Ø³Ø¨Ø§Ùƒ` بدلاً من `سباك`  
`Ø¨Ø­Ø«` بدلاً من `بحث`  

الملف محفوظ بترميز خاطئ (double-encoded UTF-8 أو Windows-1252). هذا يجعل أي نص عربي يظهر كرموز مشوشة.  
**الحل:** إعادة حفظ الملف بـ UTF-8 بدون BOM. تصدير كل النصوص إلى ملف `strings.dart` منظم.

---

### 3. الـ SplashScreen يستعمل `listenManual` قد يفوته الـ auth state

**الملف:** `lib/features/splash/presentation/screens/splash_screen.dart`  
**السطور:** `_checkAuth()` → `ref.listenManual(authProvider, ...)`  
**الوصف:** الـ `AuthNotifier` يستدعي `_checkAuth()` في الـ constructor وهو async. الـ `listenManual` يوضع بعد `await Future.delayed(800ms)` لكن في أحوال معينة قد يكون auth state قد انتهى قبل أن يبدأ الـ listen. النتيجة: التطبيق يبقى عالقاً في شاشة الـ splash ولا يوجه المستخدم.  
**الحل:** استخدام `ref.watch(authProvider)` مباشرة في `build()` بدلاً من `listenManual` مع `redirect` في GoRouter.

---

### 4. بيانات وهمية في شاشات أساسية — لا اتصال بـ Backend

**الملفات:**
- `lib/features/client/presentation/screens/artisan_profile_screen.dart` — كل المعلومات hardcoded
- `lib/features/client/presentation/screens/complaint_screen.dart` — فقط `setState` محلي
- `lib/features/client/presentation/screens/favorites_screen.dart` — `_favorites = []` دائماً فارغ
- `lib/features/client/presentation/screens/map_screen.dart` — `_mockArtisans` قائمة ثابتة

**الوصف:** هذه الشاشات لا تجلب البيانات من API إطلاقاً. المستخدم سيشاهد بيانات وهمية (اسم وهمي، صورة وهمية، هاتف وهمي `+212600000000`). عند النقر على "واتساب" أو "اتصال" سيفتح رقم وهمي.  
**الحل:** استعمال الـ providers الموجودة (`artisanProfileProvider`, `artisanReviewsProvider`, إلخ) وربطها مع هذه الشاشات.

---

### 5. ReviewScreen و ComplaintScreen — لا API call فعلي

**الملفات:**
- `lib/features/client/presentation/screens/review_screen.dart`
- `lib/features/client/presentation/screens/complaint_screen.dart`

**الوصف:** عند النقر على "إرسال التقييم" أو "إرسال الشكوى" فقط `setState(() => _submitted = true)` يحصل. لا يتم إرسال أي طلب API. البيانات تضيع عند إعادة تشغيل التطبيق.  
**الحل:** إضافة API calls عبر `apiClient.post(...)` وعرض loading spinner أثناء الإرسال ومعالجة الأخطاء.

---

# ⚠️ متوسط — خطأ وظيفي

---

### 6. مفقود `textDirection: TextDirection.rtl` في MaterialApp

**الملف:** `lib/main.dart`  
**الوصف:** الـ `MaterialApp.router` عنده `locale: Locale('ar')` لكنه **لا يملك** `textDirection: TextDirection.rtl`.  
مع أن Flutter يفهم العربية تلقائياً من locale، بعض الأدوات (مثل `Padding`, `EdgeInsets.only(left/right)`) قد تبقى كـ LTR. أيضاً `TextDirection.rtl` وحده للـ TextField ما يكفي — يفضل تحديده في الـ root.  
**الحل:** إضافة `textDirection: TextDirection.rtl` في `MaterialApp.router()`.

---

### 7. `Image.network()` بدلاً من `CachedNetworkImage` في بعض الأماكن

**الملف:** `lib/features/client/presentation/screens/search_screen.dart`  
**السطر:** `Image.network(a.imageUrl!, fit: BoxFit.cover, ...)`  
**الوصف:** استخدام `Image.network()` بدون caching. المستخدم سيعيد تحميل الصورة كل مرة.  
**الحل:** استخدام `CachedNetworkImage` المتوفر في الـ dependencies.

---

### 8. `compareTo` على سعر كـ String — خطأ في الترتيب

**الملف:** `lib/features/client/presentation/screens/artisan_list_screen.dart`  
**السطر:** `sorted.sort((a, b) => a.priceRange.compareTo(b.priceRange))`  
**الوصف:** `priceRange` هو String مثل `"150-300 درهم"`. الـ sort الحرفي (lexicographic) يعطي ترتيب خطأ — مثل "1000" قبل "200".  
**الحل:** إضافة حقل رقمي (`minPrice`/`maxPrice`) للـ Model واستعماله في الترتيب.

---

### 9. الـ `ReviewScreen` يبني `Scaffold` داخل `_buildSuccess()` كـ Scaffold منفصل

**الملف:** `lib/features/client/presentation/screens/review_screen.dart`  
**الوصف:** دالة `_buildSuccess()` ترجع `Scaffold` جديد داخل `Scaffold` الأصلي. هذا يسبب طبقتين من Scaffold.  
**الحل:** استعمال `showDialog` أو تغيير الحالة لعرض محتوى مختلف داخل نفس Scaffold.

---

### 10. الـ MapScreen لا يعمل بدون location — ولا يعرض ошибку

**الملف:** `lib/features/client/presentation/screens/map_screen.dart`  
**الوصف:** عند رفض المستخدم لطلب الموقع، فقط `_locationLoading = false` يحصل بدون أي رسالة. الخريطة تظهر بمركز افتراضي لكن الـ artisan markers تظهر بدون تحديد موقع المستخدم.  
**الحل:** إظهار SnackBar/Banner يطلب تفعيل الخدمة مع زر للإعدادات.

---

### 11. `canLaunchUrl` يستعمل package قديم — يحتاج إلى `launchUrl` فقط مع `mode`

**الملف:** `lib/features/client/presentation/screens/artisan_profile_screen.dart`  
**الوصف:** استخدام `await canLaunchUrl(uri)` ثم `await launchUrl(uri)` — هذا سيظل deprecated الآن مع `url_launcher` 6.x. كمان `canLaunchUrl` قد يعطي false على iOS للمكالمات.  
**الحل:** استعمال `await launchUrl(uri, mode: LaunchMode.externalApplication)` مباشرة مع try-catch.

---

### 12. `_iconBadge` مع `count: null` — حجماً غير مستغل

**الملف:** `lib/features/home/presentation/screens/home_screen.dart`  
**السطور:** `_iconBadge(Icons.notifications_outlined, null, ...)` — تمرير `null` دائماً يجعل الـ badge لا يظهر أبداً.  
**الحل:** جلب عداد الإشعارات الحقيقي من الـ API أو إخفاء الـ badge parameter إذا لم يكن مستعملاً.

---

### 13. لا يوجد `const` على بعض الـ StatelessWidgets

**الملفات:** `primary_button.dart`, `error_state.dart`, `loading_widgets.dart`, كثير من الـ widgets  
**الوصف:** معظم الـ widgets يصلح أن يكون `const` constructor لكنها بدون `const`. الـ Flutter يستفيد من `const` لتقليل إعادة البناء.  
**الحل:** إضافة `const` للـ constructors حيثما أمكن.

---

### 14. `connectivity_plus` قد لا يكتشف الإنترنت فورياً

**الملف:** `lib/core/network/network_info.dart`  
**الوصف:** الـ `network_info.dart` يستعمل `connectivity_plus` للتحقق من الاتصال قبل كل API call. لكن `connectivity_plus` يكتشف اتصال الـ WiFi (حتى بدون إنترنت فعلي). المستخدم قد يتصل بشبكة WiFi بدون إنترنت ويمنع من استخدام التطبيق خطأً.  
**الحل:** إضافة ping/health check للـ API base URL للتأكد من الاتصال الفعلي.

---

### 15. الـ `ErrorState` widget يستعمل `AppColors.errorBg` و `AppColors.danger` — لكنه لا يقبل custom message

**الملف:** `lib/core/widgets/error_state.dart`  
**الوصف:** `ErrorState` يعرض دائماً `"عذراً!"` كـ عنوان ثابت. قد لا يناسب كل السياقات.  
**الحل:** إضافة optional `title` parameter.

---

### 16. `WizardScreen` لا يحفظ البيانات بعد الإرسال

**الملف:** `lib/features/artisan/presentation/screens/wizard_screen.dart`  
**الوصف:** `_onSubmit()` فقط يظهر AlertDialog ولا يرسل أي API call. بيانات التسجيل (الاسم، الصورة، الهوية) لا تصل إلى السيرفر.  
**الحل:** إضافة API endpoint للـ registration مع multipart upload للصور.

---

### 17. لا يوجد `ScrollController`/`addListener` dispose في ArtisanListScreen

**الملف:** `lib/features/client/presentation/screens/artisan_list_screen.dart`  
**الوصف:** الـ `_scrollController` ينشأ ولا يوجد له `addListener`، لكنه ما زال يجب dispose لتجنب memory leak (خاصة مع التوجيه المتكرر).  
**الحل:** dispose موجود لكنه جيد — فقط ملاحظة تذكيرية.

---

# 💡 تحسين — اقتراحات

---

### 18. استعمال `AppTypography` في كل النصوص

**الملف:** `lib/core/theme/app_typography.dart`  
**الوصف:** يوجد `AppTypography` file لكن معظم النصوص في التطبيق تستخدم `TextStyle(...)` مباشرة بأحجام وأوزان متفرقة.  
**الحل:** تعريف `TextStyles` مركزية في `AppTypography` واستخدامها في كل مكان.

---

### 19. إضافة `pull-to-refresh` في شاشات متعددة

**الملفات:** `favorites_screen.dart`, `my_orders_screen.dart`, `account_screen.dart`, `search_screen.dart`  
**الوصف:** شاشات كثيرة لا تدعم السحب للتحديث.  
**الحل:** لف المحتوى بـ `RefreshIndicator`.

---

### 20. إضافة `Loading` state على أزرار الإرسال

**الملفات:** `review_screen.dart`, `complaint_screen.dart`, `wizard_screen.dart`  
**الوصف:** عند النقر على إرسال، لا يوجد `CircularProgressIndicator` على الزر. المستخدم قد ينقر مراراً.  
**الحل:** إضافة `isLoading` state + تعطيل الزر + عرض spinner.

---

### 21. فواصل `SizedBox(height: ...)` — استعمال `AppSpacing`

**الملف:** كل الملفات  
**الوصف:** يوجد `AppSpacing` مع قيم موحدة (`sm`, `md`, `lg`, `xl`) لكن معظم الـ SizedBox تستخدم أرقام مبعثرة (8, 10, 12, 14, 16, 20, 24, 28, 32).  
**الحل:** استعمال `AppSpacing.sm`, `AppSpacing.md`, إلخ للحفاظ على التناسق البصري.

---

### 22. إضافة `inputFormatters` و `validators` في النماذج

**الملفات:** `login_screen.dart`, `register_screen.dart`, `wizard_screen.dart`, `review_screen.dart`, `complaint_screen.dart`  
**الوصف:** حقول الإدخال ليس عليها validators رسمية — المستخدم قد يرسل رقم هاتف خطأ أو بريد إلكتروني غير صحيح.  
**الحل:** إضافة `Form` مع `TextFormField` و `validator` لكل حقل.

---

### 23. `softWrap: true` و `overflow: TextOverflow.ellipsis` على النصوص الطويلة

**الملفات:** عدة ملفات  
**الوصف:** بعض النصوص بدون `overflow` قد تخرج عن الشاشة في الشاشات الصغيرة.  
**الحل:** إضافة `overflow: TextOverflow.ellipsis` على كل `Text` في `Row` و `Flex`.

---

### 24. `CachedNetworkImage` placeholder و errorWidget تحسين

**الملف:** عدة ملفات  
**الوصف:** الـ `placeholder` و `errorWidget` يستخدمان `_avatarPlaceholder()` بشكل جيد. لكن بعضها يستخدم `Image.network` مباشرة.  
**الحل:** توحيد استعمال `AppNetworkImage` widget مخصص.

---

### 25. إعادة استخدام `EmptyState` widget الرسمي بدلاً من الـ inline

**الملفات:** `my_orders_screen.dart`, `favorites_screen.dart`, `search_screen.dart`  
**الوصف:** يوجد `EmptyState` جاهز لكن بعض الشاشات تبني Empty state يدوياً بنفس التصميم.  
**الحل:** استعمال `EmptyState` widget.

---

### 26. الـ `search_screen.dart` — استخدام `textSearchProvider` مع كل حرف

**الملف:** `lib/features/client/presentation/screens/search_screen.dart`  
**الوصف:** `_onSearchChanged` يعمل `setState(() => _query = value.trim())` الذي يبني `textSearchProvider` جديد مع كل حرف بعد 400ms debounce. لكن الـ `ref.watch(textSearchProvider(_query))` في `build()` يشتغل كل مرة حتى لو نفس القيمة. ممكن تحسين باستعمال `autoDispose` أو `family.autoDispose`.  
**الحل:** إضافة `.autoDispose` للـ `textSearchProvider`.

---

### 27. إضافة `MediaQuery` للـ responsive design

**الملفات:** عدة شاشات  
**الوصف:** كثير من الأحجام ثابتة (مثل `SizedBox(width: 120, height: 40)`). على الشاشات الصغيرة (أقل من 360dp) قد تخرج بعض العناصر.  
**الحل:** استعمال `MediaQuery.of(context).size.width` أو `flutter_screenutil` الموجود في الـ dependencies.

---

### 28. الـ `BottomNavItem` بارامترات يجب أن تكون `const`

**الملفات:** `app_bottom_nav.dart`  
**الوصف:** إذا كانت `BottomNavItem` تستخدم `const` constructor، كل `items: const [...]` يشتغل.  
**الحل:** إضافة `const` constructor لـ `BottomNavItem`.

---

### 29. `app_router.dart` — `my-reviews` route يشير إلى `NotificationsScreen` بدلاً من شاشة المراجعات

**الملف:** `lib/core/router/app_router.dart`  
**السطر:** `GoRoute(path: '/my-reviews', ...) => NotificationsScreen()`  
**الوصف:** رابط `/my-reviews` يفتح شاشة الإشعارات بدلاً من شاشة مراجعات المستخدم. خطأ في التوجيه.  
**الحل:** تغيير إلى `NotificationsScreen` يكون فقط لـ `/notifications` routes.

---

### 30. `artisanProfileProvider` و `artisanRepositoryProvider` — الـ artisanId null

**الملف:** `lib/features/artisan/presentation/providers/artisan_provider.dart`  
**الوصف:** `_artisanIdProvider` يرجع `String?` والـ providers ترمي Exception لو null. هذا جيد لكنه سيعرض "يجب تسجيل الدخول أولاً" للمستخدم بدون طريقة تصحيح.  
**الحل:** إضافة error handling ودعوة لتسجيل الدخول.

---

### 31. `auth_repository_impl.dart` يستعمل `dart:io` لـ `Platform.is...`?

**الملف:** `lib/features/auth/data/repositories/auth_repository_impl.dart`  
**الوصف:** إذا كان يستعمل `Platform` من `dart:io`، هذا سيمنع compile على الويب (مثل `dart:html`).  
**الحل:** التأكد من عدم وجود `dart:io` أو `dart:html` غير محمية بـ `kIsWeb`.

---

### 32. `flutter_secure_storage` dependency — هل هو متوافق مع الويب؟

**الملف:** `pubspec.yaml` → `flutter_secure_storage: ^9.2.4`  
**الوصف:** `flutter_secure_storage` لا يدعم الويب. إذا كان التطبيق سيُنشر على الـ web، سيحدث خطأ.  
**الحل:** استخدام `package:universal_storage` أو إضافة `flutter_secure_storage_web` بشكل منفصل.

---

# ملخص الملفات المُدقّقة

| المنطقة | الملفات |
|---------|---------|
| Core | `app_router.dart`, `api_constants.dart`, `api_client.dart`, `app_colors.dart`, `app_theme.dart`, `app_typography.dart`, `providers.dart`, `exceptions.dart`, `failures.dart`, `network_info.dart` |
| Auth | `auth_remote_datasource.dart`, `auth_repository_impl.dart`, `auth_repository.dart`, `auth_provider.dart`, `user_model.dart`, `user_entity.dart` |
| Home | `services_remote_datasource.dart`, `services_repository_impl.dart`, `services_repository.dart`, `home_provider.dart`, `services_provider.dart`, `home_screen.dart`, `category_model.dart` |
| Client | `login_screen.dart`, `register_screen.dart`, `artisan_list_screen.dart`, `artisan_profile_screen.dart`, `search_screen.dart`, `review_screen.dart`, `complaint_screen.dart`, `account_screen.dart`, `favorites_screen.dart`, `my_orders_screen.dart`, `map_screen.dart` |
| Artisan | `artisan_remote_datasource.dart`, `artisan_repository_impl.dart`, `artisan_provider.dart`, `dashboard_screen.dart`, `wizard_screen.dart`, `artisan_profile_screen.dart`, `notifications_screen.dart` |
| Widgets | `primary_button.dart`, `loading_widgets.dart`, `error_state.dart` |
| Root | `main.dart`, `pubspec.yaml` |

---

## توصيات عاجلة (الترتيب حسب الأهمية)

1. **إزالة `import 'dart:html'`** من `api_client.dart` — يمنع التطبيق من الـ compile
2. **إعادة حفظ `home_screen.dart`** بـ UTF-8 الصحيح
3. **ربط شاشات ArtisanProfile, Reviews, Complaints, Favorites بـ API**
4. **إضافة `textDirection: TextDirection.rtl`** في `main.dart`
5. **تصحيح `/my-reviews` route** في `app_router.dart`
6. **إضافة API calls إلى ReviewScreen و ComplaintScreen و WizardScreen**
7. **إضافة `CachedNetworkImage` بدلاً من `Image.network`**
8. **تصحيح sorting حسب السعر كرقم وليس String**
9. **إزالة Scaffold المكرر في ReviewScreen**
10. **إضافة `RefreshIndicator` في الشاشات المفقودة**

---

*النهاية — تم فحص 30+ ملف Dart وتحليل 32 نقطة تدقيق.*
