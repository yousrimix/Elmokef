# خطة Sprint 10 — الإطلاق التجريبي (Beta Launch)

**إعداد:** عمر الحسيني — Product Manager  
**تاريخ الخطة:** 18 يونيو 2026  
**الهدف:** Beta Launch — 9 يوليو 2026  
**المدة:** 3 أسابيع (19 يونيو – 9 يوليو 2026)

---

## 0. تحليل الوضع الحالي — قراءة Sprint 9

### ✅ تم الإنجاز — جاهز

| المجال | الحالة | التفاصيل |
|--------|--------|----------|
| **Backend (NestJS)** | ✅ جاهز (100%) | Build ناجح، كل bugs أُصلحت، Ranking p95 < 500ms، CMI Integration كاملة |
| **Flutter (Mobile)** | ✅ جاهز (95%) | 0 errors, 0 warnings, RTL كامل، إشعارات، S8-004 و S8-005 أُصلحا |
| **Admin Panel (React)** | ✅ جاهز (95%) | 9 صفحات مع APIs حقيقية، RTL كامل، Build ناجح — فقط Bundle size (951kB) يحتاج تحسين |
| **QA — User Stories** | ✅ 18/18 E2E | Ranking Engine, CMI (8/8), Notifications كلها مجتازة |
| **QA — Performance (k6)** | ✅ p95 < 500ms | 200 VUs, 5 دقائق — جميع APIs أقل من الهدف |
| **BA Analysis** | ✅ مكتمل | سوق، منافسون، Personas، User Stories، Scope |
| **UI/UX Design** | ✅ مكتمل | Design System + Screens في Figma |
| **Security Review** | ✅ جزئي | مطلوب Penetration Test نهائي |

### ❌ غير جاهز — يحتاج Sprint 10

| المجال | الحالة | التفاصيل |
|--------|--------|----------|
| **DevOps — CI/CD** | ❌ 0% | لا `.github/workflows/` — النشر يدوي بالكامل |
| **DevOps — Monitoring** | ❌ 0% | لا Prometheus/Grafana, لا Alerting, لا Uptime |
| **DevOps — Staging** | ❌ 0% | لا بيئة Staging منفصلة |
| **DevOps — Backup** | ❌ 0% | لا استراتيجية Backup/Restore موثقة |
| **DevOps — Production Server** | ❌ لم يُشترَ | لا خادم Hetzner بعد |
| **QA — Unit Tests** | ❌ 0% | Flutter 0%, Backend 0% — خطر كبير |
| **QA — Bug S9-001** | ❌ غير مُصلح | CMI WebView iPhone 14 Pro — لوحة المفاتيح العربية لا تظهر |
| **QA — Bug S9-002** | ❌ غير مُصلح | Bottom Nav RTL انحراف 2px على iPhone 11 |
| **Security — Penetration Test** | ❌ لم يبدأ | مطلوب OWASP ASVS + اختبار اختراق |

### ⚠️ المخاطر الحرجة

1. **M1 — DevOps**: CI/CD + Server + Monitoring + Staging كلها 0%. هذا هو العنق الزجاجة الحقيقي.
2. **M2 — S9-001**: Bug iPhone CMI keyboard — يؤثر على تجربة الدفع لمستخدمي iOS (قطاع مهم في المغرب).
3. **M3 — Unit Tests**: 0% على Flutter و Backend — يزيد احتمالية رجوع Bugs في أي Hotfix.
4. **M4 — Timeline**: 3 أسابيع فقط حتى 9 يوليو. الجدول الأصلي للـ Roadmap كان 10 Sprints × 2 أسابيع. نحن متقدمون كثيراً (FTC) لكن DevOps تأخر.

---

## 1. أهداف Sprint 10

### الهدف الرئيسي
> **إطلاق Beta Version في الدار البيضاء بحلول 9 يوليو 2026 مع 100+ حرفي و 500+ عميل في أول أسبوعين.**

### الأهداف الفرعية

| الهدف | المعيار | الأولوية |
|-------|---------|----------|
| **1. بنية تحتية إنتاجية** | خادم حي + SSL + Domain + CI/CD + Monitoring | 🔴 حرجة |
| **2. جميع Bugs مقفولة** | S9-001 مصلح، S9-002 و S9-003 مقفولين | 🔴 حرجة |
| **3. Unit Tests ≥ 40%** | Flutter + Backend — تغطية أساسية | 🟡 عالية |
| **4. اختبار إطلاق Beta** | 18/18 User Stories + CMI (8/8) + k6 + RTL | 🔴 حرجة |
| **5. خطة اكتساب حرفيين** | 100+ حرفي مسجل في الدار البيضاء | 🔴 حرجة |
| **6. خطة تسويق Beta** | إعلانات + مؤثرون + فريق ميداني | 🟡 عالية |

---

## 2. المهام التفصيلية — حسب الفريق

### 2.1 🐳 ياسر (DevOps) — الأولوية القصوى

الوضع: CI/CD 0% | Monitoring 0% | Staging 0% | Server ❌

| # | المهمة | الأولوية | الأيام | التبعية |
|---|--------|----------|--------|---------|
| D-01 | شراء خادم Hetzner (CX32 للتجارب + AX102 للإنتاج) | 🔴 حرجة | 1 | لا شيء |
| D-02 | تثبيت Docker + Docker Compose على الخادم | 🔴 حرجة | 0.5 | D-01 |
| D-03 | إعداد Domain DNS (api.elmokef.ma, admin.elmokef.ma, app.elmokef.ma) | 🔴 حرجة | 1 | D-01 |
| D-04 | إصدار شهادات SSL (Let's Encrypt) | 🔴 حرجة | 0.5 | D-03 |
| D-05 | تشغيل Docker Compose Production (PostGIS + Redis + ClamAV + Backend + Nginx + Certbot) | 🔴 حرجة | 1 | D-04 |
| D-06 | **بناء GitHub Actions CI/CD** (3 Pipelines: Backend CI + Backend Deploy + Admin Deploy) | **🔴 حرجة** | 2 | D-02 |
| D-07 | إعداد Backup Strategy (pg_dump + Backblaze B2 + cron daily) | 🟡 عالية | 1 | D-05 |
| D-08 | إعداد Monitoring Stack (Prometheus + Grafana + Loki + cAdvisor) | 🟡 عالية | 1.5 | D-05 |
| D-09 | إعداد Alerting (Telegram Bot + Email) | 🟡 عالية | 0.5 | D-08 |
| D-10 | إعداد Staging Environment (Docker Compose منفصل أو نفس الخادم بمنفذ مختلف) | 🟡 عالية | 1 | D-02 |
| D-11 | تفعيل Cloudflare (DNS, CDN, WAF, DDoS Protection) | 🟡 عالية | 1 | D-03 |
| D-12 | إعداد Backblaze B2 لتخزين صور الحرفيين | 🟡 عالية | 0.5 | D-05 |
| D-13 | نشر Admin Panel (`dist/` → `admin.elmokef.ma`) | 🟡 عالية | 0.5 | D-04 |
| D-14 | اختبار استرجاع النسخ الاحتياطي (RTO < 4h) | 🟡 عالية | 0.5 | D-07 |
| D-15 | **إخفاق أمني: إضافة CSP Header + server_tokens off في Nginx** | 🟡 عالية | 0.5 | D-05 |
| D-16 | إنشاء Runbook (خطوات استرجاع الطوارئ) | 🟢 تحسين | 1 | D-07 |

**إجمالي أيام DevOps:** ~13 يوم (يمكن بالتوازي 7-8 أيام تقويمية مع فريقين)

### 2.2 📱 خالد + فاطر (Flutter) — إكمال وتثبيت

الوضع: ✅ 0 errors, 0 warnings — يحتاج Bugs + Unit Tests

| # | المهمة | الأولوية | الأيام | التبعية |
|---|--------|----------|--------|---------|
| F-01 | **إصلاح S9-001 — CMI WebView iPhone Keyboard AR** (Bug Major — عائق الإطلاق) | **🔴 حرجة** | 2 | لا شيء |
| F-02 | إصلاح S9-002 — Bottom Nav RTL 2px (iPhone 11) | 🟡 عالية | 0.5 | لا شيء |
| F-03 | إصلاح S9-003 — نص مكرر "حرفيين حرفيين" | 🟢 سريع | 0.25 | لا شيء |
| F-04 | **كتابة Unit Tests (Flutter)** — استهداف ≥ 40% تغطية: Data Layer (repositories + API), BLoC/Cubit (auth, search, ranking), Utils (localization, validation) | **🔴 حرجة** | 5 | لا شيء |
| F-05 | تحسين Cold Start (< 2s) — deferred imports + lazy loading | 🟡 عالية | 1 | لا شيء |
| F-06 | تحسين FPS في القائمة — إضافة `const` حيثما أمكن (~20 info → 0) | 🟢 تحسين | 0.5 | لا شيء |
| F-07 | اختبار HMS (Huawei Push) — تأكيد عمل الإشعارات على Huawei P40 | 🟡 عالية | 1 | لا شيء |
| F-08 | بناء APK + AAB للإصدار التجريبي | 🟡 عالية | 0.5 | F-01 |
| F-09 | إعداد Firebase App Distribution (Android) + TestFlight (iOS) | 🟡 عالية | 1 | F-08 |

**إجمالي أيام Flutter:** ~12 يوم (يمكن بالتوازي 7 أيام تقويمية)

### 2.3 🖥️ محمد (Backend) — تثبيت + تحسينات

الوضع: ✅ Build ناجح، كل Bugs مصلحة

| # | المهمة | الأولوية | الأيام | التبعية |
|---|--------|----------|--------|---------|
| B-01 | **تفعيل Review Trust Service** في `reviews.service.ts:create()` — اكتشاف التقييمات المشبوهة | 🟡 عالية | 1 | لا شيء |
| B-02 | **إضافة Prisma `$transaction` في `handleWebhook()`** — منع inconsistency بين payment status و subscription | 🟡 عالية | 0.5 | لا شيء |
| B-03 | ربط SubscriptionRenewalService مع Payment flow — الفوترة الفعلية للتجديد | 🟡 عالية | 1.5 | لا شيء |
| B-04 | **كتابة Unit Tests (Backend)** — استهداف ≥ 40%: Auth Module, Payments Module, Ranking Engine, Reviews Module | **🔴 حرجة** | 5 | لا شيء |
| B-05 | تحسين N+1 في Reviews (findByArtisan + findModerationQueue) — استخدم Prisma batch | 🟢 تحسين | 0.5 | لا شيء |
| B-06 | إعداد Swagger Documentation كاملة لجميع APIs | 🟢 تحسين | 1 | لا شيء |
| B-07 | إعداد seeding data لقاعدة البيانات (حرفيون تجريبيون، خدمات، فئات) | 🟡 عالية | 1 | لا شيء |
| B-08 | دعم محمد لياسر في CI/CD Backend Pipeline (Docker image build) | 🟡 عالية | 0.5 | D-06 |

**إجمالي أيام Backend:** ~11 يوم (يمكن بالتوازي 6 أيام تقويمية)

### 2.4 ⚛️ رؤوف (React Admin) — تحسينات + تسليم

الوضع: ✅ 9 صفحات مع API، Build ناجح

| # | المهمة | الأولوية | الأيام | التبعية |
|---|--------|----------|--------|---------|
| R-01 | **Code Splitting** — `React.lazy()` لجميع الصفحات (هدف: تقليل Bundle < 500kB) | 🟡 عالية | 1 | لا شيء |
| R-02 | نقل `sendNotification` من `auth.ts` إلى ملف `notifications.ts` | 🟢 تحسين | 0.25 | لا شيء |
| R-03 | مراجعة وتصحيح تصدير `rtl.ts` — `cacheRtl` vs `rtlCache` | 🟢 تحسين | 0.25 | لا شيء |
| R-04 | إضافة اختبارات أساسية للـ Components (render tests) | 🟢 تحسين | 1 | لا شيء |
| R-05 | إنشاء `Dockerfile` للـ Admin Panel (إذا لم يكن موجوداً) | 🟡 عالية | 0.5 | لا شيء |
| R-06 | **تسليم `dist/` لياسر للنشر على `admin.elmokef.ma`** | 🔴 حرجة | 0.25 | D-04 |

**إجمالي أيام React:** ~3.5 أيام (يمكن بالتوازي)

### 2.5 🧪 رنا (QA) — ختم الإطلاق

الوضع: ✅ 18/18 US, k6 p95 < 500ms, CMI 8/8

| # | المهمة | الأولوية | الأيام | التبعية |
|---|--------|----------|--------|---------|
| Q-01 | **إعادة اختبار S9-001 بعد الإصلاح** — CMI iPhone + تأكيد لوحة المفاتيح AR | 🔴 حرجة | 1 | F-01 |
| Q-02 | اختبار إشعارات FCM + HMS + APNs (إعادة كاملة) | 🟡 عالية | 1.5 | F-07 |
| Q-03 | **اختبار Beta Checklist كامل (18/18)** — تأكيد قبل الإطلاق | 🔴 حرجة | 2 | Q-01 |
| Q-04 | **اختبار CMI (8/8 سيناريوهات)** — إعادة كاملة | 🔴 حرجة | 1 | D-05 |
| Q-05 | **اختبار أداء k6 (200 VUs)** — تأكيد p95 < 500ms | 🔴 حرجة | 1 | D-05 |
| Q-06 | اختبار RTL على 5 أجهزة — تأكيد 50/50 شاشة | 🟡 عالية | 1 | F-02 |
| Q-07 | **اختبار استرجاع النسخ الاحتياطي (RTO < 4h)** | 🟡 عالية | 0.5 | D-14 |
| Q-08 | اختبار المستخدم النهائي مع 5-8 عملاء حقيقيين (Beta Testers) | 🟡 عالية | 2 | Q-03 |
| Q-09 | Smoke Test قبل الإطلاق — قائمة Go/No-Go | 🔴 حرجة | 0.5 | Q-03 - Q-06 |
| Q-10 | تقرير الجودة النهائي لـ Sprint 10 | 🟢 وثيقة | 1 | Q-09 |

**إجمالي أيام QA:** ~11.5 يوم (يمكن بالتوازي 7 أيام تقويمية)

### 2.6 🔒 فيصل (Security) — المراجعة النهائية

| # | المهمة | الأولوية | الأيام |
|---|--------|----------|--------|
| S-01 | تنفيذ OWASP ASVS Checklist — اختبار API Security | 🔴 حرجة | 2 |
| S-02 | **اختبار اختراق (Penetration Test)** — Auth, Payments, User Data | 🔴 حرجة | 2 |
| S-03 | مراجعة تخزين البيانات والتشفير — الامتثال لـ Law 09-08 | 🟡 عالية | 1 |
| S-04 | تقرير أمني نهائي + توصيات | 🟡 عالية | 1 |

**إجمالي أيام Security:** ~6 أيام (يمكن بالتوازي)

### 2.7 📢 هدى (Marketing) — حملة الإطلاق

| # | المهمة | الأولوية | الأيام |
|---|--------|----------|--------|
| M-01 | إعداد حسابات App Store + Google Play Developer | 🔴 حرجة | 2 |
| M-02 | **ASO Package** — Keywords + Description + Screenshots بالعربية | 🟡 عالية | 2 |
| M-03 | **حملة اكتساب حرفيين** — 100+ حرفي في الدار البيضاء (فريق ميداني + إعلانات) | 🔴 حرجة | طوال Sprint |
| M-04 | إعداد حملة إعلانات (Meta Ads + Google Ads) لمنطقة الدار البيضاء | 🟡 عالية | 3 |
| M-05 | تسويق مؤثر — قائمة مؤثرين مغاربة (5-10) في مجال الخدمات المنزلية | 🟡 عالية | 3 |
| M-06 | خطة محتوى (Social Media) — 10 منشورات قبل الإطلاق | 🟢 تحسين | 3 |
| M-07 | إعداد صفحة هبوط (Landing Page) بسيطة للـ Beta | 🟡 عالية | 2 |

**إجمالي أيام Marketing:** طوال الـ Sprint

---

## 3. الجدول الزمني — Gantt

### الأسبوع 1: 19 – 25 يونيو (التهيئة)

| اليوم | DevOps | Flutter | Backend | React | QA | Security | Marketing |
|-------|--------|---------|---------|-------|----|----------|-----------|
| **السبت 19** | D-01 شراء خادم | F-01 CMI Keyboard S9-001 | B-01 Review Trust | R-01 Code Split | Q-01 إعادة CMI | S-01 OWASP | M-01 App Store |
| **الأحد 20** | D-02 Docker + D-03 DNS | F-01 CMI Keyboard | B-02 $transaction | R-01 Code Split | Q-01 CMI iPhone | S-01 OWASP | M-02 ASO |
| **الاثنين 21** | D-04 SSL + D-05 Compose | F-04 Unit Tests | B-03 Renewal + Payment | R-02+R-03 تحسينات | Q-02 Notifications | S-02 Pen Test | M-03 حرفيون |
| **الثلاثاء 22** | D-06 CI/CD Pipeline | F-04 Unit Tests | B-04 Unit Tests | R-04 Tests | Q-02 Notifications | S-02 Pen Test | M-03 حرفيون |
| **الأربعاء 23** | D-06 CI/CD Pipeline | F-04 Unit Tests | B-04 Unit Tests | R-05 Dockerfile | Q-03 Beta Checklist | S-02 Pen Test | M-04 إعلانات |
| **الخميس 24** | D-07 Backup | F-04 Unit Tests | B-04 Unit Tests | R-06 تسليم dist | Q-03 Beta Checklist | S-03 Data Privacy | M-04 إعلانات |
| **الجمعة 25** | D-08 Monitoring | F-04 Unit Tests | B-07 Seeding Data | — | Q-04 CMI 8/8 | S-04 تقرير | M-05 مؤثرون |

### الأسبوع 2: 26 يونيو – 2 يوليو (الاختبار)

| اليوم | DevOps | Flutter | Backend | React | QA | Security | Marketing |
|-------|--------|---------|---------|-------|----|----------|-----------|
| **السبت 26** | D-08 Monitoring | F-04 Unit Tests | B-05 N+1 Fix | — | Q-04 CMI 8/8 | — | M-05 مؤثرون |
| **الأحد 27** | D-09 Alerting | F-05 Cold Start | B-06 Swagger | — | Q-05 k6 Performance | — | M-06 محتوى |
| **الاثنين 28** | D-10 Staging | F-06 FPS + const | B-08 CI/CD Docker | — | Q-06 RTL 5 devices | — | M-06 محتوى |
| **الثلاثاء 29** | D-11 Cloudflare | F-07 HMS Test | — | — | Q-07 Backup Restore | — | M-07 Landing Page |
| **الأربعاء 30** | D-12 Backblaze B2 | F-08 Build APK | — | — | Q-08 User Testing | — | M-07 Landing Page |
| **الخميس 1** | D-13 Admin Deploy | F-09 Firebase Dist | — | — | Q-08 User Testing | — | M-03 حرفيون |
| **الجمعة 2** | D-14 Backup Test | — | — | — | Q-09 Smoke Test | — | M-03 حرفيون |

### الأسبوع 3: 3 – 9 يوليو (الإطلاق)

| اليوم | DevOps | Flutter | Backend | QA | Marketing |
|-------|--------|---------|---------|----|-----------|
| **السبت 3** | D-15 Nginx CSP + D-16 Runbook | Fix Hotfixes | Fix Hotfixes | Final Checks | Final Checks |
| **الأحد 4** | مراجعة كل الـ Configs | تحسينات أخيرة | تحسينات أخيرة | Q-10 تقرير جودة | تجهيز الإطلاق |
| **الاثنين 5** | **Go/No-Go التقني** | — | — | **Go/No-Go QA** | — |
| **الثلاثاء 6** | نشر Production Final | — | — | — | — |
| **الأربعاء 7** | Monitoring + Alerting نشط | — | — | — | — |
| **الخميس 8** | Smoke Test أخير | — | — | — | — |
| **الجمعة 9 يوليو** | 🚀 **BETA LAUNCH — الدار البيضاء** | 🚀 | 🚀 | 🚀 | 🚀 |

---

## 4. خطة الطوارئ (Contingency)

### سيناريوهات الطوارئ

| السيناريو | الإجراء | المسؤول |
|-----------|---------|---------|
| **تأخر CI/CD (أسبوع 1)** | النشر اليدوي إلى Sprint 10 — خادم واحد يدوي الإدارة. لكن CI/CD يُبنى بعد الإطلاق | ياسر |
| **S9-001 لم يُصلح بحلول 25 يونيو** | إطلاق Beta بدون iOS (Android فقط) + إصدار TestFlight لاحقاً | خالد + رنا |
| **تأخر خادم Hetzner** | استخدام VPS مؤقت (DigitalOcean أو Vultr) كبداية — €6-12/شهر | ياسر |
| **تأخر وحدة الاختبارات** | اختبارات يدوية أساسية + تأجيل التغطية الآلية إلى Sprint 11 | محمد + خالد + رنا |
| **قلة الحرفيين (< 50)** | اشتراك مجاني مدى الحياة لأول 500 حرفي + حوافز نقدية + فريق ميداني | هدى + الرئيس التنفيذي |
| **مشكلة CMI Production** | العودة إلى CMI Sandbox للإطلاق التجريبي + الدفع اليدوي للحرفيين الأوائل | محمد + ياسر |

### ميزانية الطوارئ (Buffer)

| اليوم | الوظيفة |
|-------|---------|
| 3 يوليو | يوم احتياطي — لأي تأخير |
| 4 يوليو | يوم احتياطي — لأي تأخير |
| 8 يوليو | Smoke Test + Go/No-Go |
| **3 أيام Buffer** | |

---

## 5. Go/No-Go Checklist

### 🟢 الشروط الأساسية (قبل الإطلاق)

| # | الشرط | المسؤول | ✅ |
|---|-------|---------|---|
| 1 | جميع الخدمات تعمل (Docker compose ps — كل containers UP) | ياسر | ☐ |
| 2 | SSL سليم — https://api.elmokef.ma/health → 200 | ياسر | ☐ |
| 3 | PostgreSQL قابلة للاتصال + بيانات أولية موجودة (seeding) | محمد | ☐ |
| 4 | Redis ping → PONG | محمد | ☐ |
| 5 | CMI Sandbox اتصال + Webhook يعمل | محمد | ☐ |
| 6 | S9-001 مصلح (CMI iPhone Keyboard AR) | خالد + رنا | ☐ |
| 7 | 18/18 Beta Checklist — ✅ | رنا | ☐ |
| 8 | CMI 8/8 سيناريوهات — ✅ | رنا | ☐ |
| 9 | k6 p95 < 500ms — ✅ | رنا | ☐ |
| 10 | Backup Restore Test — RTO < 4h | ياسر + رنا | ☐ |
| 11 | Cloudflare — Proxied ✅ + WAF ✅ | ياسر | ☐ |
| 12 | Flutter Beta — Firebase App Distribution + TestFlight جاهز | خالد | ☐ |
| 13 | Admin Panel على admin.elmokef.ma — ✅ | ياسر + رؤوف | ☐ |
| 14 | 50+ حرفي مسجل في الدار البيضاء | هدى | ☐ |
| 15 | لا Critical Bugs مفتوحة | رنا | ☐ |

### 🟡 التحذيرات (يفضل لكن ليس إلزامياً)

| # | الشرط | المسؤول | ✅ |
|---|-------|---------|---|
| 1 | Unit Tests ≥ 40% (Flutter + Backend) | محمد + خالد | ☐ |
| 2 | Penetration Test — لا High Severity findings | فيصل | ☐ |
| 3 | CSP Headers في Nginx | ياسر | ☐ |
| 4 | Runbook طوارئ جاهز | ياسر | ☐ |
| 5 | 100+ حرفي مسجل | هدى | ☐ |
| 6 | Code Splitting — Admin Bundle < 500kB | رؤوف | ☐ |

### 🔴 فشل الإطلاق

إذا لم يستوفِ الشرطان **#6 (S9-001)** و **#7 (18/18 US)** بحلول **5 يوليو**، يتم تأجيل الإطلاق أسبوعاً واحداً إلى **16 يوليو**.

---

## 6. الموارد والتكاليف

### البنية التحتية (شهرياً)

| الخدمة | التكلفة (€) |
|--------|-------------|
| Hetzner CX32 (تجارب) | ~€15 |
| Hetzner AX102 (Production) | ~€35 |
| Cloudflare Pro | ~€20 |
| Backblaze B2 | ~€1 |
| **الإجمالي** | **~€71/شهر** |

### التسويق (مرة واحدة)

| البند | التكلفة (MAD) |
|-------|---------------|
| إعلانات Meta + Google — شهر | ~20,000 MAD |
| فريق ميداني لاكتساب حرفيين (أسبوعان) | ~10,000 MAD |
| مؤثرون (5 مؤثرين) | ~15,000 MAD |
| **الإجمالي** | **~45,000 MAD** |

---

## 7. KPIs Sprint 10

| المؤشر | الهدف | طريقة القياس |
|--------|-------|-------------|
| ✅ S9-001 مصلح | ✅ (قبل 25 يونيو) | اختبار على iPhone 14 Pro |
| ✅ 18/18 US E2E | ✅ | تقرير QA |
| ✅ Unit Tests (Flutter) | ≥ 40% | `dart test --coverage` |
| ✅ Unit Tests (Backend) | ≥ 40% | `npx jest --coverage` |
| ✅ k6 p95 | < 500ms | k6 report |
| ✅ CMI 8/8 | ✅ | QA report |
| ✅ خادم Production | متصل + SSL | ping + curl |
| ✅ CI/CD | يعمل | GitHub Actions ✅ |
| ✅ Monitoring | Grafana → Métriques | Grafana dashboard |
| ✅ حرفيون | 100+ | قاعدة البيانات |
| ✅ Beta Launch Date | 9 يوليو 2026 | 🚀 |

---

## 8. المسؤوليات

| الفريق | الأعضاء | المهام الرئيسية | الأولوية |
|--------|---------|-----------------|----------|
| **DevOps** | ياسر | خادم، CI/CD، Monitoring، SSL، Staging، Backup | 🔴 العنق الزجاجة |
| **Flutter** | خالد + فاطر | S9-001، Unit Tests، Build Beta، HMS | 🔴 حرجة |
| **Backend** | محمد | Review Trust، $transaction، Unit Tests، Seeding | 🟡 عالية |
| **React Admin** | رؤوف | Code Splitting، تسليم dist | 🟢 تسليم |
| **QA** | رنا | إعادة اختبار CMI، Beta Checklist، k6، RTL | 🔴 حرجة |
| **Security** | فيصل | OWASP، Pen Test، Data Privacy | 🟡 عالية |
| **Marketing** | هدى | اكتساب حرفيين، إعلانات، مؤثرون | 🔴 حرجة |
| **PM** | عمر الحسيني | متابعة، تقارير، قرارات، Go/No-Go | 🔴 حرجة |

---

## 9. الخلاصة

| البند | القيمة |
|-------|--------|
| **الهدف** | Beta Launch — الدار البيضاء |
| **تاريخ الإطلاق** | 9 يوليو 2026 |
| **المدة** | 3 أسابيع (19 يونيو – 9 يوليو) |
| **العنق الزجاجة** | 🐳 **DevOps** (CI/CD + Monitoring + خادم) |
| **أكبر عائق فني** | 📱 **S9-001** (CMI iPhone Keyboard) |
| **أكبر خطر** | 😱 0% Unit Tests + 0% CI/CD = لا أمان تقني |
| **ميزانية الطوارئ** | 3 أيام |
| **Go/No-Go** | 5 يوليو 2026 |

> **"ما تبقاش حرفة — التطبيق جاهز، البنية التحتية هي اللي ما زالت."**
