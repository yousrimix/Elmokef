# تحليل الفجوات (Gap Analysis) — مشروع الموقف

**إعداد:** محلل الأعمال (BA Agent)  
**تاريخ التحليل:** 18 يونيو 2026  
**المرحلة:** Sprint 9 → Sprint 10 (Beta Launch)

---

## 🎯 الهدف

مقارنة الـ User Stories المُوثَّقة في `outbox.md` مع الواقع الفعلي في الكود (Backend + Flutter + Admin Panel) لتحديد الفجوات بين ما خُطِّطَ له وما أُنْجِزَ فعلاً.

---

## 📊 ملخص عام

| المكون | الحالة | ملاحظات |
|--------|--------|---------|
| **Backend (NestJS)** | ✅ كامل تقريباً | 13 موديول، Auth كامل، OTP، OAuth، Ranking، Reviews، Complaints، Payments (CMI)، Subscriptions، Notifications (FCM+HMS)، Upload، Redis |
| **Flutter Mobile** | 🟡 70% مكتمل | الواجهات موجودة لكن أغلبها بيانات وهمية (mock) — لا تكامل حقيقي مع الـ API |
| **Admin Panel (React)** | 🟡 60% مكتمل | الشاشات موجودة لكن البيانات fallback (ثابتة/وهمية) |
| **Infrastructure** | 🟢 تم البدء | Docker, Nginx, CMI Scripts موجودة |
| **Tests** | 🔴 ضعيف جداً | ملف اختبار واحد فقط في كل من Flutter و Backend |

---

## 🔍 1️⃣ الـ User Stories المُنجَزة بالكامل (✅)

### Auth Module (Sprint 2)
| ID | الحالة | ملاحظات |
|----|--------|---------|
| AUTH-01 & AUTH-02 | ✅ مكتمل | Registration Client + Artisan — `POST /api/v1/auth/register` + `register/artisan` |
| AUTH-03 | ✅ مكتمل | Login — `POST /api/v1/auth/login` |
| AUTH-04 & AUTH-05 | ✅ مكتمل | OAuth Google/Facebook — `POST /api/v1/auth/oauth` مع Firebase verifyIdToken |
| AUTH-06 | ⚠️ جزئي | Forgot/Reset Password موجود في DTOs لكن لم نجد endpoint فعلي في auth.controller |
| AUTH-07 | ❌ غير موجود | Change Password endpoint غير موجود في الـ Controller |
| AUTH-08 & AUTH-09 | ✅ مكتمل | Logout + Refresh Token مع Cookie httpOnly |
| AUTH-10 | ✅ مكتمل | Admin User Management — Users page موجودة |
| AUTH-11 | ✅ مكتمل | Document Verification — admin-documents.controller مع PATCH |

### Client Features
| ID | الوصف | الحالة |
|----|-------|--------|
| US-01 | إنشاء حساب | ✅ مكتمل |
| US-02 | تحديث الموقع | ⚠️ جزئي — Flutter Geolocator موجود + MapScreen، لكن لا يوجد تكامل مع Backend لتحديث location |
| US-03 | تصفح فئات الخدمات | ✅ مكتمل — `GET /api/v1/services` + HomeScreen مع Categories |
| US-04 | البحث عن خدمة | ✅ مكتمل — SearchScreen مع expansion |
| US-05 | عرض الحرفيين مرتبة | ✅ مكتمل — Ranking Algorithm + GeoSearch مع cursor pagination |
| US-06 | مشاهدة ملف الحرفي | ✅ مكتمل — ArtisanProfileScreen مع full data |
| US-07 | الاتصال بالحرفي | ✅ مكتمل — Phone + WhatsApp باستخدام url_launcher |
| US-08 | تقييم الحرفي | ✅ مكتمل — ReviewScreen + Backend ReviewsService مع Trust Detection |
| US-09 | المفضلة | ❌ **غير مكتمل** — Flutter فية `ApiConstants.favorites` ولكن لا يوجد FavoritesController على Backend ولا FavoritesService |
| US-10 | الإبلاغ عن حرفي | ✅ مكتمل — ComplaintScreen + ComplaintsService + Admin Complaints page |
| US-11 | عرض الطلبات السابقة | ❌ **غير مكتمل** — AccountScreen بها "طلباتي السابقة" ولكن لا يوجد Backend endpoint ولا Flutter Business Logic |

### Artisan Features
| ID | الوصف | الحالة |
|----|-------|--------|
| US-12 | إنشاء حساب حرفي | ✅ مكتمل — `register/artisan` + WizardScreen |
| US-13 | بطاقة تعريفية | ✅ مكتمل — `PUT /artisans/:id/profile` + artisan profile fields |
| US-14 | تحديد الخدمات والأسعار | ✅ مكتمل — ArtisanService add/update/remove + Service management |
| US-15 | صور الأعمال | ✅ مكتمل — Portfolio Gallery + Upload with thumbnail + sharp compression |
| US-16 | إشعارات الطلبات الجديدة | ✅ مكتمل — FCM + HMS + NotificationService + Flutter notification handling |
| US-17 | عرض الملف الشخصي (Preview) | ✅ مكتمل — ArtisanProfileViewScreen موجودة |
| US-18 | الاشتراك بباقة | ✅ مكتمل — Subscription plans + CMI Payment + WebSocket real-time |
| US-19 | مشاهدة الإحصائيات | ⚠️ جزئي — DashboardScreen بها Quick Stats لكنها بيانات وهمية (بدون تكامل API) |
| US-20 | الرد على التقييمات | ❌ **غير مكتمل** — لا يوجد reply endpoint في Reviews ولا Flutter UI للرد |

### Admin Features
| ID | الوصف | الحالة |
|----|-------|--------|
| US-21 | إدارة المستخدمين | ✅ مكتمل — Users page |
| US-22 | التحقق من وثائق الحرفيين | ✅ مكتمل — AdminDocumentsController + Artisans page |
| US-23 | إدارة فئات الخدمات | ✅ مكتمل — Categories page |
| US-24 | إدارة الاشتراكات والمدفوعات | ✅ مكتمل — Subscriptions page مع payment tracking |
| US-25 | معالجة الشكايات | ✅ مكتمل — Complaints page مع status update |
| US-26 | عرض إحصائيات المنصة | ⚠️ جزئي — Dashboard موجودة لكنها تستخدم fallback data (ما فيش API حقيقي للإحصائيات) |
| US-27 | إرسال إشعارات للمستخدمين | ✅ مكتمل — Notifications page + `sendToAllArtisans` |

---

## 🟡 2️⃣ الفجوات الرئيسية (Gaps)

### Gap 1: المفضلة (Favorites) — US-09
| البند | الواقع | ما هو مطلوب |
|-------|--------|-------------|
| Flutter Route | ✅ موجود `/favorites` في ApiConstants | ✅ — |
| Backend API | ❌ **غير موجود** — لا يوجد FavoritesController أو FavoritesService | إضافة موديول Favorites: POST/GET/DELETE |
| Prisma Model | ✅ موجود `Favorite` model مع composite id | ✅ — |
| UI في Account | ⚠️ موجود في القائمة (مفضلتي) لكن بدون navigate | تشغيل الـ navigation وإضافة شاشة FavoritesList |

### Gap 2: الطلبات السابقة (History) — US-11
| البند | الواقع | ما هو مطلوب |
|-------|--------|-------------|
| Flutter Route | ❌ غير موجود | شاشة History/Orders مع عمودي |
| Backend Endpoint | ❌ غير موجود | `GET /api/v1/orders/history` |
| نموذج بيانات | ❌ ما فيش Order/Request model في Prisma | الحاجة إلى Order/Request model لربط العميل بالحرفي |

**ملاحظة مهمة:** هذا يسلط الضوء على فجوة جوهرية — **لا يوجد نموذج "طلب/Order" في أي مكان**. التطبيق حالياً يربط العميل بالحرفي عبر الاتصال المباشر (هاتف/واتساب) دون توثيق الطلب. هذا يعني:
- لا يمكن تتبع حالة الطلب
- لا يوجد سجل طلبات للعميل
- لا يمكن لحساب "عدد الطلبات" للحرفي (totalOrders في Prisma ولكن لا يتم تحديثه)

### Gap 3: الرد على التقييمات (Reply) — US-20
| البند | الواقع | ما هو مطلوب |
|-------|--------|-------------|
| Backend | ❌ لا يوجد reply endpoint في ReviewsController | إضافة PATCH/POST لتحديث حقل `reply` في الـ Review |
| Prisma Model | ✅ حقل `reply` موجود في Review model | ✅ — |
| Flutter UI | ❌ غير موجود | إضافة حقل reply في ArtisanProfileScreen + شاشة replies |

### Gap 4: الإحصائيات في Dashboard (US-19, US-26)
| البند | الواقع | ما هو مطلوب |
|-------|--------|-------------|
| Admin Dashboard | ⚠️ يستخدم fallback data | إضافة StatsController يوفر: عدد المستخدمين، الحرفيين، الإيرادات، مستخدمين جدد/أسبوع |
| Artisan Dashboard | ⚠️ بيانات وهمية | ربط الـ Dashboard بالـ API endpoint للإحصائيات |
| Backend Stats | ❌ غير موجود | إضافة Stats/Analytics Module |

### Gap 5: Forgot/Change Password (AUTH-06, AUTH-07)
| البند | الواقع |
|-------|--------|
| `POST /auth/forgot-password` | ❌ Non-existent in controller (DTO present but unused) |
| `POST /auth/change-password` | ❌ Non-existent in controller |

### Gap 6: تكامل API في Flutter
| البند | الواقع |
|-------|--------|
| ApiClient (Dio) | ✅ موجود في `core/network/api_client.dart` |
| التكامل الفعلي | ❌ **جميع الشاشات الحالية تستخدم بيانات وهمية (hardcoded/mock)** |
| Auth Flow | ⚠️ Login/Register UI موجود لكن onPressed فاضية |
| Artisan List | ❌ تستخدم mock data من نوع _mockArtisans |
| Map | ❌ 4 حرفيين فقط hardcoded في الخريطة |
| States | ✅ Error/Empty/Loading widgets جاهزة — تحتاج ربط |

### Gap 7: الاختبارات (Tests)
| المكون | الواقع | المطلوب لـ Beta |
|--------|--------|-----------------|
| Backend | ملف e2e واحد فقط | Unit + Integration لكل سيرفيس |
| Flutter | اختبار widget واحد فقط | Widget + Integration tests |
| Admin Panel | ❌ لا توجد اختبارات | — |

### Gap 8: أمان إضافي
| البند | الحالة |
|-------|--------|
| Rate Limiting | ✅ موجود مع رسائل عربية |
| JWT Validation | ✅ موجود |
| RBAC Roles Guard | ✅ موجود |
| CMI HMAC | ✅ موجود مع idempotency |
| Antivirus للصور | ✅ موجود (ClamAV) |
| تشفير الملفات | ✅ موجود للوثائق |
| إخفاء الحقول الحساسة (PII) | ✅ موجود في Payments |
| HTTPS/TLS | ⚠️ غير موثق — يستخدم env var NODE_ENV |
| 2FA للإدارة | ❌ غير موجود |

---

## 📋 3️⃣ تحليل المخاطر للفجوات

| الفجوة | درجة الخطورة | التأثير على Beta Launch | التوصية |
|--------|-------------|------------------------|---------|
| لا يوجد Order/Request Model | 🔴 عال جداً | العميل لا يستطيع تتبع طلباته، الحرفي لا يستطيع إدارة الطلبات — هذا جوهر التطبيق | **يجب حلّه قبل Sprint 10** |
| Flutter — لا تكامل API | 🔴 عال | التطبيق غير قابل للاستخدام الفعلي — كل شيء وهمي | **أولوية Beta Launch** |
| المفضلة | 🟡 متوسط | تجربة مستخدم ناقصة لكن ليست حرجة | Sprint 10 |
| الرد على التقييمات | 🟢 منخفض | ميزة تحسينية | Sprint 11 |
| الإحصائيات | 🟡 متوسط | الإدارة لا تستطيع اتخاذ قرارات مبنية على بيانات | Sprint 10 |
| Forgot/Change Password | 🟡 متوسط | أمني — المستخدم لا يستطيع تغيير كلمة المرور | **Sprint 10** |
| الاختبارات | 🟡 متوسط | مخاطر الجودة مرتفعة | قبل الإطلاق |

---

## ✅ 4️⃣ ما تم إنجازه فعلاً (يُشكر عليه الفريق)

### Backend (جيد جداً)
1. **Auth Module كامل** — Registration, Login, OAuth (Google/Facebook), OTP, JWT مع Refresh Rotation
2. **Ranking Algorithm متطور** — 4 معايير مع Geo-Spatial Calculatio + Caching باستخدام Redis + Subscription Boosts
3. **CMI Payment Integration** — مع WebSocket real-time notifications + HMAC security + Idempotency
4. **Subscription System** — 3 باقات، Cron لتجديد الاشتراكات، Upgrade/Cancel
5. **Upload Service** — مع Antivirus scanning, Thumbnail generation, File encryption للوثائق
6. **Review Trust Detection** — يحارب التقييمات الوهمية
7. **Rate Limiting مع رسائل عربية** — تفاصيل صغيرة لكنها مهمة
8. **Audit Logs** — لكل عملية مهمة
9. **RTL Readiness** — Enum labels بالعربية في DTOs

### Flutter (واجهات جاهزة لكن تحتاج ربط)
1. **Routing كامل** — كل الشاشات تقريباً مسجلة في GoRouter
2. **UI Components جاهزة** — AppBottomNav, AppCard, RatingBar, VerifiedBadge, Empty/Error/Loading states
3. **RTL Support** — MaterialApp.router مع locale resolution للتحدث
4. **Notification Handling** — foreground/background/killed مع FCM + local notifications
5. **Map Integration** — flutter_map + OpenStreetMap مع تحديد الموقع
6. **Artisan Registration Wizard** — 4 خطوات كاملة مع image picking + subscription plan selection

### Admin Panel
1. **جميع الشاشات الأساسية** — Dashboard, Users, Artisans, Categories, Complaints, Reviews, Subscriptions, Notifications
2. **RTL Theme** موجود

---

## 🚨 5️⃣ التوصيات العاجلة (قبل Sprint 10)

### 🔴 أولوية قصوى (Beta Blockers)
1. **إنشاء Order/Request Module** — هذا هو العمود الفقري للتطبيق
   - نموذج: Order { id, clientId, artisanId, serviceId, status, price, scheduledAt, location, createdAt }
   - API: CRUD Orders + real-time WebSocket للطلب الجديد
   - UI Flutter: قائمة طلبات للعميل + لوحة طلبات للحرفي (RequestScreen حالياً mock)
   
2. **ربط Flutter بالـ API** — كل الشاشات تحتاج Dio calls حقيقية
   - البدء بـ: Auth Flow (Login/Register)
   - ثم: Services -> Artisans search -> Artisan profile
   - ثم: Reviews, Complaints

### 🟡 أولوية عالية
3. **إكمال المفضلة** — Backend Controller سهل (Favorites model موجود في Prisma)
4. **إضافة Stats Module** — للإدارة وللحرفيين
5. **إكمال Forgot/Change Password**
6. **اختبارات أساسية** — على الأقل coverage لـ Auth + Ranking

### 🟢 أولوية متوسطة
7. **الرد على التقييمات**
8. **ربط SEntry/Monitoring**
9. **إضافة Loading/Skeleton على كل الشاشات** (الموجودة جاهزة لكن تحتاج تفعيل)

---

## 📈 6️⃣ خارطة طريق مقترحة للإغلاق (Sprint 10)

| الأسبوع | المهمة | المسؤول |
|---------|--------|---------|
| **الأسبوع 1** | Order Module (Model + API + WebSocket + UI) | Backend + Flutter |
| **الأسبوع 1** | ربط Auth Flow في Flutter | Flutter |
| **الأسبوع 2** | ربط Services + Artisans في Flutter | Flutter |
| **الأسبوع 2** | Favorites Backend | Backend |
| **الأسبوع 2** | Stats Module | Backend |
| **الأسبوع 3** | Forgot/Change Password | Backend |
| **الأسبوع 3** | ربط Reviews + Complaints في Flutter | Flutter |
| **الأسبوع 3** | Admin Dashboard real data | Admin |
| **الأسبوع 4** | اختبارات شاملة | QA |
| **الأسبوع 4** | Deploy + Final Testing | DevOps |

---

— محلل الأعمال (BA Agent)
