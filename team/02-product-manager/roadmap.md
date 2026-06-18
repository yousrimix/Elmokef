# Roadmap النهائي — Elmokef

**إعداد:** عمر الحسيني — Product Manager  
**تاريخ:** 17 يونيو 2026  
**المدة الإجمالية:** 20 أسبوعاً (10 Sprints)  
**تاريخ الإطلاق:** 9 نوفمبر 2026  

**الاعتماد على:** تحليل سارة (BA)، وثيقة د. أحمد النجار (Architecture)، آراء جميع الأعضاء

---

## جدول المحتويات
1. [النطاق — MVP الحقيقي](#1-النطاق--mvp-الحقيقي)
2. [الجدول الزمني — 10 Sprints](#2-الجدول-الزمني--10-sprints)
3. [التوزيع على الأعضاء](#3-التوزيع-على-الأعضاء)
4. [التبعيات (Dependencies)](#4-التبعيات-dependencies)
5. [المخاطر وخطة التخفيف](#5-المخاطر-وخطة-التخفيف)
6. [KPIs ومعايير النجاح](#6-kpis-ومعايير-النجاح)
7. [Phase 2 و Phase 3](#7-phase-2-و-phase-3)

---

## 1. النطاق — MVP الحقيقي

تم تقليص الـ MVP إلى **18 User Story** (بدلاً من 27) بناءً على توصيتي في النقاش الداخلي.

### ما هو Inside MVP (Sprint 1-8)

| القطاع | US ID | الوصف | Must/Should |
|--------|-------|-------|-------------|
| **العميل** | US-01 | إنشاء حساب (Email/Phone/OAuth) | Must |
| | US-02 | تحديد الموقع GPS + يدوي | Must |
| | US-03 | تصفح فئات الخدمات هرمياً | Must |
| | US-04 | بحث نصي بخدمة | Should |
| | US-05 | عرض حرفيين مرتبين (خوارزمية) | Must |
| | US-06 | مشاهدة ملف الحرفي | Must |
| | US-07 | الاتصال (هاتف/واتساب) | Must |
| | US-08 | تقييم ومراجعة (1-5 نجوم + نص) | Must |
| **الحرفي** | US-12 | تسجيل حساب مع توثيق هوية | Must |
| | US-13 | إدارة بطاقة تعريفية (Bio، شهادات) | Must |
| | US-14 | تحديد الخدمات والأسعار | Must |
| | US-15 | رفع صور الأعمال (معرض) | Must |
| | US-16 | إشعارات الطلبات الجديدة | Should |
| | US-18 | الاشتراك بباقة (مجاني/احترافي/مميز) | Must |
| **الإدارة** | US-21 | إدارة المستخدمين (حظر/تفعيل) | Must |
| | US-22 | التحقق من وثائق الحرفيين | Must |
| | US-23 | إدارة فئات الخدمات | Must |
| | US-24 | إدارة الاشتراكات والمدفوعات | Must |

### ما هو مؤجل إلى Phase 2

| القطاع | US ID | السبب |
|--------|-------|-------|
| العميل | US-09 | المفضلة — يمكن الاستغناء عنها في الإطلاق |
| العميل | US-10 | الإبلاغ — إدارة الشكايات تكفي مؤقتاً |
| العميل | US-11 | سجل الطلبات — لا يوجد تدفق طلبات داخلي في MVP |
| الحرفي | US-17 | معاينة الملف — ميزة تحسين وليست أساسية |
| الحرفي | US-19 | إحصائيات الحرفي — dashboard معقد |
| الحرفي | US-20 | الرد على التقييمات — تفاعل ثانوي |
| الإدارة | US-25 | الشكايات — إدارة يدوية في البداية |
| الإدارة | US-26 | الإحصائيات — basic dashboard فقط في MVP |
| الإدارة | US-27 | إشعارات جماعية — تكامل إضافي |

---

## 2. الجدول الزمني — 10 Sprints

كل Sprint = أسبوعان. إجمالي المدة: 20 أسبوعاً.

### Sprint 1 — Infrastructure & Foundation
| البند | التفاصيل |
|-------|---------|
| **التاريخ** | 22 يونيو – 3 يوليو 2026 |
| **الهدف** | إعداد البنية الأساسية للمشروع |
| **التسليمات** | NestJS Monorepo + Prisma Schema + PostgreSQL + Flutter Skeleton + CI/CD Pipeline |
| **الأعمال** | • إشاء NestJS Monorepo مع Modular Structure (Clean Architecture)\n• إعداد Prisma ORM + PostgreSQL مع PostGIS\n• إنشاء Flutter project مع Riverpod + GoRouter\n• إعداد GitHub Actions CI/CD (DEV Pipeline)\n• Docker Compose للبيئة المحلية\n• إعداد ESLint, Prettier, Husky\n• Design System Foundation في Figma (ألوان، خطوط، أيقونات)\n• إعداد Swagger/OpenAPI في NestJS |
| **المسؤول** | د. أحمد (Architecture)، محمد (Backend)، خالد (Flutter)، ليلى (UI/UX)، ياسر (DevOps) |
| **التبعيات** | لا توجد — Sprint تأسيسي |

### Sprint 2 — Auth Module
| البند | التفاصيل |
|-------|---------|
| **التاريخ** | 6 يوليو – 17 يوليو 2026 |
| **الهدف** | نظام المصادقة الكامل للعميل والحرفي والمشرف |
| **التسليمات** | API Auth + OAuth (Google/Facebook) + JWT + RBAC + شاشات Flutter للمصادقة |
| **الأعمال** | • Backend: Auth Module (تسجيل، دخول، Refresh Token، OAuth)\n• Backend: RBAC (3 أدوار: Client, Artisan, Admin)\n• Backend: Rate Limiting + Helmet + Security Middleware\n• Backend: واجهة Phone OTP (اختياري)\n• Flutter: شاشات تسجيل ودخول مع RTL\n• Flutter: تكامل Firebase Auth + OAuth\n• UI/UX: شاشات Onboarding المبسّطة\n• UI/UX: Design System — مكونات Auth (Input, Button, OTP)\n• Security: مراجعة صلاحية JWT + Refresh Token Rotation |
| **المسؤول** | محمد (Backend)، خالد (Flutter)، فيصل (Security)، ليلى (UI/UX) |
| **التبعيات** | Sprint 1 (البنية التحتية) |

### Sprint 3 — Services & Client Experience
| البند | التفاصيل |
|-------|---------|
| **التاريخ** | 20 يوليو – 31 يوليو 2026 |
| **الهدف** | تجربة العميل: تصفح الخدمات، البحث، فئات هرمية |
| **التسليمات** | API Services + Categories + Client-side browsing + شاشات Flutter |
| **الأعمال** | • Backend: Services Module (فئات هرمية، بحث نصي)\n• Backend: Categories CRUD + تصنيف هرمي (self-referencing)\n• Backend: Caching (Redis) لقوائم الخدمات\n• Flutter: شاشة الفئات + بحث + تصفح\n• Flutter: تكامل الخريطة (OpenStreetMap + MapTiler)\n• UI/UX: تصميم شاشات الخدمات والفئات\n• Database: إعداد الـ Full-Text Search (GIN index + pg_trgm)\n• QA: اختبار RTL على شاشات التصفح |
| **المسؤول** | محمد (Backend)، خالد (Flutter)، نور (Database)، ليلى (UI/UX)، رنا (QA) |
| **التبعيات** | Sprint 2 (Auth) |

### Sprint 4 — Artisan Module
| البند | التفاصيل |
|-------|---------|
| **التاريخ** | 3 أغسطس – 14 أغسطس 2026 |
| **الهدف** | نظام الحرفي الكامل: ملف شخصي، خدمات، أسعار، معرض صور |
| **التسليمات** | Artisan API + Profile + Portfolio + شاشات Flutter للحرفي |
| **الأعمال** | • Backend: Artisan Module (ملف شخصي، خدمات، أسعار)\n• Backend: Portfolio (رفع صور مع ضغط + Thumbnails)\n• Backend: File Upload Pipeline (S3/Backblaze + CDN)\n• Flutter: شاشات تسجيل الحرفي (Wizard 4 خطوات)\n• Flutter: معرض الصور + معاينة الملف\n• UI/UX: تصميم Simplified Mode للحرفيين (أزرار كبيرة، صور)\n• Database: تحسين استعلامات الملف الشخصي\n• Security: فحص الملفات المرفوعة + تشفير الوثائق |
| **المسؤول** | محمد (Backend)، خالد (Flutter)، نور (Database)، ليلى (UI/UX)، فيصل (Security) |
| **التبعيات** | Sprint 3 (Services) + Sprint 2 (Auth) |
| **ملاحظة** | يتم بالتوازي: استراتيجية اكتساب حرفيين من هدى (Marketing) — تجنيد 50-100 حرفي تجريبي |

### Sprint 5 — Ranking Engine & Search
| البند | التفاصيل |
|-------|---------|
| **التاريخ** | 17 أغسطس – 28 أغسطس 2026 |
| **الهدف** | خوارزمية الترتيب الذكية + عرض الحرفيين مع الخريطة |
| **التسليمات** | Ranking Engine + Combined Search + Map View + قائمة مرتبة |
| **الأعمال** | • Backend: Ranking Engine Service (NestJS)\n• Backend: Score calculation (distance×0.40 + rating×0.30 + price×0.20 + response×0.10 + subscriptionBoost)\n• Backend: Redis Cache للـ Scores + تحديث تلقائي عند التغيير\n• Backend: Cursor-based Pagination للقوائم\n• Flutter: دمج الـ Ranking مع القائمة\n• Flutter: عرض الحرفيين على الخريطة\n• Flutter: قائمة الحرفيين مرتبة حسب Score\n• Database: GiST index + Materialized View للترتيب\n• PoC: اختبار دقة OSM في الدار البيضاء + مراكش + فاس\n• QA: اختبار أداء القائمة مع 200+ حرفي (FPS ≥ 55) |
| **المسؤول** | محمد (Backend)، خالد (Flutter)، نور (Database)، رنا (QA)، د. أحمد (Architecture) |
| **التبعيات** | Sprint 3 (Services) + Sprint 4 (Artisan) |
| **خطر** | أداء الخوارزمية مع 500+ حرفي — PoC مسبق للأسبوع الأول من Sprint |

### Sprint 6 — Reviews & Complaints
| البند | التفاصيل |
|-------|---------|
| **التاريخ** | 31 أغسطس – 11 سبتمبر 2026 |
| **الهدف** | نظام التقييمات، الشكايات، التواصل بين العميل والحرفي |
| **التسليمات** | Review API + Rating + الاتصال هاتف/واتساب + الشكايات الأساسية |
| **الأعمال** | • Backend: Review Module (إضافة تقييم، عرض، moderation)\n• Backend: نظام الشكايات الأساسي (إبلاغ + معالجة يدوية)\n• Flutter: شاشة تقييم بعد الخدمة (1-5 نجوم + نص)\n• Flutter: زر اتصال هاتفي + واتساب مباشر\n• Flutter: عرض تقييمات الحرفي في ملفه\n• UI/UX: تصميم شاشة التقييم + Empty states\n• Database: Triggers لتحديث avg_rating + total_ratings تلقائياً\n• Database: Soft Delete للتقييمات\n• QA: اختبار دورة التقييم الكاملة + RTL |
| **المسؤول** | محمد (Backend)، خالد (Flutter)، نور (Database)، ليلى (UI/UX)، رنا (QA) |
| **التبعيات** | Sprint 5 (Ranking) — التقييم يؤثر على Score |

### Sprint 7 — Subscription & Payments (CMI)
| البند | التفاصيل |
|-------|---------|
| **التاريخ** | 14 سبتمبر – 25 سبتمبر 2026 |
| **الهدف** | نظام الاشتراكات الكامل + تكامل بوابة الدفع CMI |
| **التسليمات** | Subscription API + CMI Integration + WebView + تجديد تلقائي |
| **الأعمال** | • Backend: Subscription Module (باقات، ترقية، إلغاء)\n• Backend: Payment Integration مع CMI (WebHook + Idempotency)\n• Backend: جدولة التجديد التلقائي (pg_cron/BullMQ)\n• Backend: نظام الـ Audit Log للمدفوعات\n• Flutter: شاشة اختيار الباقة مع المقارنة\n• Flutter: WebView/SFSafariViewController للدفع\n• Flutter: تأكيد الدفع عبر WebSocket\n• UI/UX: تصميم شاشة الاشتراكات + حالات النجاح/الفشل\n• Database: جدول payments + subscriptions مع ACID\n• Security: مراجعة أمنية لتدفق الدفع (PCI-DSS Level 4)\n• QA: اختبار دورة الدفع الكاملة + سيناريوهات الفشل |
| **المسؤول** | محمد (Backend)، خالد (Flutter)، ياسر (DevOps)، فيصل (Security)، نور (Database) |
| **التبعيات** | Sprint 4 (Artisan) — الحرفي يجب أن يكون مسجلاً |
| **خطر** | CMI WebView قد يُرفض من Apple — البديل: SFSafariViewController + Chrome Custom Tabs |

### Sprint 8 — Admin Panel & Notifications
| البند | التفاصيل |
|-------|---------|
| **التاريخ** | 28 سبتمبر – 9 أكتوبر 2026 |
| **الهدف** | لوحة إدارة ويب + نظام إشعارات Firebase |
| **التسليمات** | Admin Panel (React) + Notifications (FCM/HMS/APNs) + Dashboard أساسي |
| **الأعمال** | • Frontend: Admin Panel (React + Vite + MUI مع RTL)\n• Frontend: صفحات إدارة المستخدمين والحرفيين\n• Frontend: إدارة الفئات + الاشتراكات\n• Frontend: Dashboard أساسي (إحصائيات)\n• Backend: Notifications Module (FCM + HMS + APNs)\n• Backend: التحقق من وثائق الحرفيين (رفض/قبول)\n• Flutter: استقبال الإشعارات (foreground + background + killed)\n• DevOps: إعداد Subdomain (admin.elmokef.ma)\n• DevOps: نشر Admin Panel + SSL\n• QA: اختبار الإشعارات على 3 حالات تطبيق × 2 منصة |
| **المسؤول** | محمد (Backend) — Notifications، خالد (Flutter) — إشعارات، ياسر (DevOps)، رنا (QA) |
| **التبعيات** | Sprint 2–7 (جميع الـ APIs يجب أن تكون جاهزة) |

### Sprint 9 — QA & Performance
| البند | التفاصيل |
|-------|---------|
| **التاريخ** | 12 أكتوبر – 23 أكتوبر 2026 |
| **الهدف** | اختبار شامل، تحسين الأداء، إصلاح الأخطاء، تجربة المستخدم النهائية |
| **التسليمات** | بيئة Staging كاملة + تقرير اختبارات + إصلاحات |
| **الأعمال** | • QA: اختبار شامل لجميع User Stories (18 قصة)\n• QA: اختبار RTL لكل شاشة بالعربية والفرنسية\n• QA: اختبار أجهزة (Redmi 9, Samsung A32, Pixel 6a, iPhone 11, iPhone 14)\n• QA: اختبار الإشعارات (FCM + HMS + APNs)\n• QA: اختبار الأداء (k6 — 1000 مستخدم وهمي)\n• QA: اختبار دفع CMI (6 سيناريوهات فشل)\n• Backend: تحسين أداء Ranking Engine + API Latency < 500ms\n• Flutter: تحسين FPS + Cold Start < 2s\n• Database: ضبط الاستعلامات + فحص الفهارس\n• DevOps: اختبار استرجاع النسخ الاحتياطي (RTO < 4h)\n• Security: مراجعة OWASP ASVS + Penetration Testing\n• UI/UX: اختبار المستخدم النهائي مع 5-8 عملاء حقيقيين |
| **المسؤول** | رنا (QA)، محمد (Backend)، خالد (Flutter)، نور (Database)، ياسر (DevOps)، فيصل (Security) |
| **التبعيات** | جميع Sprints 1–8 مكتملة |
| **ملاحظة** | هذا الـ Sprint هو بوابة الإطلاق (Gate). لا إطلاق بدون اجتياز KPIs |

### Sprint 10 — Beta Launch & Monitoring
| البند | التفاصيل |
|-------|---------|
| **التاريخ** | 26 أكتوبر – 6 نوفمبر 2026 |
| **الهدف** | الإطلاق التجريبي في الدار البيضاء + مراقبة + إصلاحات سريعة |
| **التسليمات** | Beta Launch في الدار البيضاء + Monitoring Stack + Hotfixes |
| **الأعمال** | • DevOps: نشر Production + Cloudflare + Backblaze B2\n• DevOps: تفعيل Monitoring (Prometheus + Grafana + Loki)\n• DevOps: تفعيل Alerting (Telegram + Email)\n• Marketing: إطلاق حملة الدار البيضاء (إعلانات + مؤثرون)\n• Marketing: تفعيل اكتساب الحرفيين (فريق ميداني)\n• Flutter: إصدار Beta عبر Firebase App Distribution\n• Flutter: إصدار TestFlight (iOS)\n• Backend: مراقبة API Error Rate + Response Time\n• All: Hotfixes سريعة خلال أول أسبوعين\n• All: جمع feedback من 100 مستخدم أول\n• PM: مراجعة KPIs اليومية и اتخاذ القرارات |
| **المسؤول** | جميع الفريق |
| **التبعيات** | Sprint 9 (QA) |
| **تاريخ الإطلاق:** | **9 نوفمبر 2026** 🚀 |

---

## 3. التوزيع على الأعضاء

### فريق MVP (4-5 أشخاص)

| العضو | الدور | Sprints الأساسية | المسؤوليات الرئيسية |
|-------|-------|-----------------|---------------------|
| **محمد العلي** | Backend Developer (NestJS) | S1–S8 + S10 | API، Auth، Ranking Engine، CMI Integration، Notifications |
| **خالد العمري** | Flutter Developer (Mobile) | S1–S8 + S10 | تطبيق العميل، تطبيق الحرفي، خرائط، إشعارات، RTL |
| **ليلى السعد** | UI/UX Designer | S1–S6 + S9 | Design System، شاشات، Prototype، User Testing، Simplified Mode |
| **ياسر القحطاني** | DevOps Engineer | S1 (Setup) + S8–S10 | CI/CD، خوادم، Monitoring، Domain, SSL, Backup |
| **رنا السعيد** | QA Engineer | S3–S10 | اختبارات، RTL، أداء، أجهزة، Penetration Test |

### أدوار استشارية (مشاركة جزئية)

| العضو | الدور | Sprints | المسؤوليات |
|-------|-------|---------|-------------|
| **د. أحمد النجار** | Solution Architect | S1–S2 (تأسيس) + S5 (Ranking) | Architecture oversight, ADRs, Technical decisions |
| **نور الصباغ** | Database Engineer | S3, S5–S6, S9 | Schema, Indexing, Performance, Backup |
| **فيصل المطيري** | Security Specialist | S2 (Auth), S4 (Files), S7 (Payments), S9 | Security review, Penetration test, Compliance |
| **هدى المنصور** | Marketing Manager | S4–S10 | Strategy, Campaigns, ASO, Artisan acquisition |

---

## 4. التبعيات (Dependencies)

```
Sprint 1 (Infrastructure)
    └──→ Sprint 2 (Auth) — يحتاج البنية التحتية
            ├──→ Sprint 3 (Services) — يحتاج Auth
            └──→ Sprint 4 (Artisan) — يحتاج Auth
                    └──→ Sprint 5 (Ranking) — يحتاج Services + Artisan
                            └──→ Sprint 6 (Reviews) — يحتاج Ranking
                                    └──→ Sprint 7 (Subscriptions) — يحتاج Artisan
                                            └──→ Sprint 8 (Admin) — يحتاج جميع APIs
                                                    └──→ Sprint 9 (QA) — يحتاج كل شيء
                                                            └──→ Sprint 10 (Launch) — يحتاج اجتياز QA
```

### تبعيات حرجة (Critical Path)
- **Sprint 1 → 2 → 5 → 6 → 9 → 10** — المسار الحرج (12 أسبوعاً)
- **Sprint 4 → 7** — مسار Parallel (يحتاج 4 قبل 7)
- **Sprint 8** يمكن أن يبدأ بالتوازي مع Sprint 6–7 إذا كانت APIs جاهزة

### توصيات لضغط الجدول
1. **Sprint 3 + 4 بالتوازي** (أسبوعين إضافيين) — Services Client + Artisan يمكن تطويرهما معاً
2. **بدء Sprint 8 مبكراً** — Admin Panel يمكن البدء به من Sprint 5 إذا كانت APIs Auth + Services + Artisan جاهزة (هذا يقلص الجدول أسبوعين)

---

## 5. المخاطر وخطة التخفيف

| الرمز | المخاطرة | الاحتمال | التأثير | خطة التخفيف |
|-------|---------|---------|---------|-------------|
| R1 | **صعوبة اكتساب الحرفيين** — لا يوجد حرفيون عند الإطلاق | عالي | عالي | بدء حملة تجنيد قبل Sprint 4، اشتراك مجاني مدى الحياة لأول 500، فريق ميداني |
| R2 | **تأخر تكامل CMI** — WebView معقد أو مرفوض من Apple | متوسط | عالي | البدء بـ PoC للـ CMI في Sprint 1، تحضير SFSafariViewController |
| R3 | **أداء Ranking Engine** — بطء مع 500+ حرفي | متوسط | عالي | PoC في Sprint 1، Materialized Views، Redis Cache، Cursor Pagination |
| R4 | **تأخر DevOps** — إعداد البنية التحتية يستغرق أطول من 8 أيام | منخفض | متوسط | استخدام Hetzner (بساطة)، Docker Compose (لا Kubernetes في MVP) |
| R5 | **مشاكل RTL** — تشوه الشاشات مع العربية | متوسط | متوسط | اختبار RTL في كل Sprint من اليوم الأول، QA مخصص |
| R6 | **الامتثال القانوني 09-08** — عدم الالتزام بقانون الخصوصية المغربي | منخفض | عالي | تضمين سياسة الخصوصية من Sprint 2، استشارة قانونية قبل Sprint 9 |
| R7 | **تأخر تسليم Flutter** — حجم العمل كبير لمطور واحد | متوسط | عالي | البدء بـ 2 Flutter Developer إذا أمكن، أو تقليص MVP أكثر |

### ميزانية الطوارئ (Buffer)
- **Sprint 9 (QA):** 2 أسابيع كاملة — هذا هو الـ Buffer الأساسي
- **Sprint 10:** أسبوعان إضافيان للإصلاحات
- **إجمالي Buffer:** 4 أسابيع (ضمن الخطة، وليس إضافياً)

---

## 6. KPIs ومعايير النجاح

### KPIs الإطلاق (نوفمبر 2026)

| المؤشر | الهدف | طريقة القياس |
|--------|-------|-------------|
| عدد الحرفيين المسجلين عند الإطلاق | 100+ | Firebase Analytics |
| عدد العملاء المسجلين في أول أسبوعين | 1,000+ | Firebase Analytics |
| متوسط التقييم في App Store | ≥ 4.0 نجوم | Apple App Store + Google Play |
| زمن استجابة API (P95) | < 1.5 ثانية | Grafana + Prometheus |
| وقت تحميل التطبيق (Cold Start) | < 3 ثوانٍ | Firebase Performance |
| الإشعارات — نسبة الوصول | ≥ 95% | Firebase Analytics |
| نسبة المستخدمين الذين أكملوا تقييماً | ≥ 40% | Database |
| وقت تشغيل الخدمة (Uptime) | 99.5%+ | Uptime Kuma |
| اختراقات أمنية حرجة | 0 | Sentry + Penetration Test |

### KPIs المرحلة الأولى (3 أشهر بعد الإطلاق)

| المؤشر | الهدف |
|--------|-------|
| الحرفيون النشطون (اشتراك مدفوع) | 200+ |
| العملاء النشطون شهرياً | 5,000+ |
| متوسط الاتصالات لكل حرفي/أسبوع | 3+ |
| CAC للعميل | < 15 MAD |
| CAC للحرفي | < 50 MAD |
| الإيرادات الشهرية | 30,000+ MAD |
| NPS (Net Promoter Score) | ≥ 40 |

---

## 7. Phase 2 و Phase 3

### Phase 2 — التوسع (يناير–مارس 2027)

**الهدف:** توسع جغرافي إلى الرباط وفاس + ميزات متقدمة

| الميزة | الأولوية | التقدير | التبعية |
|--------|---------|---------|---------|
| نظام المفضلة (US-09) | عالية | أسبوع 1 | User base كافٍ |
| الإبلاغ عن الحرفيين (US-10) | عالية | أسبوع 1 | نظام الشكايات قائم |
| سجل الطلبات (US-11) | متوسطة | أسبوع 2 | Contact Log |
| معاينة الملف الشخصي (US-17) | متوسطة | أسبوع 1 | Artisan Module |
| إحصائيات الحرفي (US-19) | متوسطة | أسبوعان | Data pipeline |
| الرد على التقييمات (US-20) | منخفضة | أسبوع 1 | Review Module |
| الشكايات الكاملة (US-25) | عالية | أسبوعان | Admin Panel |
| لوحة إحصائيات متقدمة (US-26) | متوسطة | أسبوعان | Database |
| إشعارات جماعية (US-27) | منخفضة | أسبوع 1 | Notifications |
| محادثة فورية (Chat) — In-App Messaging | عالية | 3-4 أسابيع | WebSocket + Socket.IO |
| دفع إلكتروني داخل التطبيق | عالية | 2-3 أسابيع | CMI Integration |
| التوسع إلى الرباط + فاس | عالية | 4 أسابيع | فريق ميداني + حملات |
| **المدة الإجمالية:** | | **~12 أسبوعاً** | |

### Phase 3 — النمو (أبريل–سبتمبر 2027)

**الهدف:** 20,000+ مستخدم + بنية تحتية قابلة للتوسع

| الميزة | الوصف |
|--------|-------|
| التوسع إلى باقي المدن المغربية (مراكش، طنجة، أكادير) | تغطية وطنية |
| الترحيل إلى Kubernetes (K3s/EKS) | قابلية التوسع |
| Microservices (فصل Auth, Search, Payments) | استقلالية الخدمات |
| حجز مواعيد داخل التطبيق | تقليل الاحتكاك |
| نظام ولاء ونقاط مكافآت | زيادة الاحتفاظ |
| باقة إعلانات للحرفيين (Sponsored Listings) | مصدر إيرادات جديد |
| تطبيق ويب كامل | وصول أوسع |
| تكامل مع وسائل التواصل الاجتماعي | تسويق فيروسي |
| Bug Bounty Program | أمن المجتمع |
| **المدة الإجمالية:** | **~6 أشهر** |

---

## الخلاصة

| البند | القيمة |
|-------|--------|
| **إجمالي المدة** | 20 أسبوعاً (10 Sprints) |
| **تاريخ البدء** | 22 يونيو 2026 |
| **تاريخ الإطلاق** | 9 نوفمبر 2026 |
| **MVP User Stories** | 18 (من أصل 27) |
| **حجم الفريق الأساسي** | 5 أشخاص |
| **التكلفة المقدرة للبنية التحتية (شهرياً)** | 40-60 يورو (Hetzner + Cloudflare + Backblaze) |
| **أكبر خطر** | اكتساب الحرفيين (جانب العرض) |
| **الأولوية القصوى** | إطلاق الدار البيضاء + 100 حرفي + 1,000 عميل |

**الموافقة:** [] — الرئيس التنفيذي  
**التاريخ:** 17 يونيو 2026

---
*تم إعداد هذا الـ Roadmap بناءً على تحليل سارة الخالد (BA)، وثيقة د. أحمد النجار (Architecture)، وآراء جميع أعضاء الفريق.*
