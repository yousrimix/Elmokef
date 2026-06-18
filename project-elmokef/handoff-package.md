# 📦 Elmokef — حزمة التسليم للفريق الجديد

**تاريخ التسليم:** 18 يونيو 2026  
**المشروع:** Elmokef (الميقف) — منصة تربط العملاء بالحرفيين في المغرب  
**الهدف:** إطلاق 9 نوفمبر 2026 (Beta 26 أكتوبر)

---

## 🏗️ نظرة عامة على الكود

```
E:\charika\
├── backend/          ← NestJS API (68 ملف، 10 موديولات)
├── almawqef/         ← Flutter App (56 ملف، 22 شاشة)
├── elmokef-admin/    ← React Admin Panel (24 ملف، 9 صفحات)
├── infra/            ← Docker + Nginx + Scripts
├── project-elmokef/  ← وثائق المشروع
└── team/             ← وثائق الفريق (12 عضواً)
```

---

## 🔧 1. Backend — NestJS (جاهز ✅)

| الموديول | الوظيفة | API Endpoints |
|----------|---------|--------------|
| **auth** | تسجيل + دخول + OAuth + OTP + RBAC | 8 endpoints |
| **artisans** | ملفات حرفيين + توثيق وثائق (Admin) | 9 endpoints |
| **services** | فئات وخدمات CRUD | 5 endpoints |
| **reviews** | تقييمات + Trust Layer + Moderation | 7 endpoints |
| **complaints** | شكايات + إدارة | 4 endpoints |
| **subscriptions** | اشتراكات + تجديد تلقائي (Cron) | 6 endpoints |
| **payments** | دفع CMI + WebHook + WebSocket | 3 endpoints |
| **notifications** | FCM/HMS + إشعارات + أجهزة | 5 endpoints |
| **ranking** | ترتيب ذكي (مسافة/تقييم/سعر/سرعة) | 3 endpoints |
| **upload** | رفع صور + تشفير AES + ClamAV | 2 endpoints |

### Prisma — 18 Models
User, ClientProfile, ArtisanProfile, Service, ArtisanService, ArtisanPortfolio, ArtisanDocument, Review, Favorite, Subscription, Payment, Complaint, Notification, Device, AuditLog, RefreshToken, OtpCode, RankingConfig

**Database:** PostgreSQL + PostGIS + Redis

---

## 📱 2. Flutter App — 22 شاشة (جاهز ✅)

| الميزة | الشاشات |
|--------|---------|
| **Auth** | Splash, Login, Register |
| **Client** | Home, Search, ArtisanList, Map, ArtisanProfile, Review, Account, Complaint |
| **Artisan** | Dashboard, Requests, Reviews, Account, Subscriptions, Payment, SubscriptionSettings, Wizard, ProfileView, PortfolioGallery |
| **Notifications** | NotificationsScreen (آخر 50) |

**التقنيات:** Riverpod, GoRouter, Dio, flutter_map, webview_flutter, firebase_messaging, huawei_push, flutter_local_notifications

---

## 🖥️ 3. Admin Panel — React (جاهز منشور ✅)

**9 صفحات:** Dashboard, Users, Artisans, Categories, Subscriptions, Complaints, Reviews, Notifications, Login

**منشور على:** `https://admin.elmokef.ma` (Let's Encrypt + HSTS)

**التقنيات:** React 19 + Vite 8 + MUI 9 + TypeScript 6 + RTL

---

## 🚨 النواقص الحرجة — يجب إكمالها قبل الإطلاق

| # | المشكلة | Priority | المسؤول المقترح |
|---|---------|----------|----------------|
| 1 | **GitHub** — رفع المشروع على GitHub | P0 | فريق جديد |
| 2 | **خادم إنتاج** — شراء VPS (Hetzner ~€41/شهر) | P0 | DevOps |
| 3 | **CI/CD** — تفعيل GitHub Actions (الـ workflows جاهزة) | P0 | DevOps |
| 4 | **S9-001** — لوحة مفاتيح CMI لا تظهر في iPhone | P0 | Flutter |
| 5 | **حسابات متاجر** — Apple Developer ($99) + Google Play ($25) | P0 | PM |
| 6 | **تغطية اختبارات** — Unit Tests (حالياً 1 فقط) | P1 | Backend + Flutter |
| 7 | **صفحة هبوط العملاء** — `elmokef.ma/client` | P1 | DevOps |
| 8 | **Screenshots + Posters** — 6 لـ App Store + 3 إعلانات | P1 | UI/UX |
| 9 | **HMS Huawei** — `agconnect-services.json` لإشعارات Huawei | P1 | DevOps |
| 10 | **تشفير JWT → RS256** + JWKS endpoint | P1 | Backend |
| 11 | **اختبارات الأداء k6** — 1000 مستخدم وهمي | P1 | QA |
| 12 | **فيصل أمن:** Helmet, CSRF, Rate Limit, SSL Pinning (6 توصيات) | P1 | Backend + Flutter |

---

## 📅 الجدول الزمني

| المرحلة | التاريخ | المدة |
|---------|---------|-------|
| **Sprint 10 — Beta Launch** | 26 أكتوبر – 6 نوفمبر | 12 يوماً |
| **🚀 الإطلاق الرسمي** | **9 نوفمبر 2026** | — |

---

## 🔗 روابط مهمة

| المورد | الرابط |
|--------|--------|
| Admin Panel | https://admin.elmokef.ma |
| API Base | https://api.elmokef.ma/api/v1 |
| Swagger | https://api.elmokef.ma/api/docs |
| Firebase Console | (أنشئ حساباً جديداً) |
| CMI Sandbox | https://test.cmi.co.ma |
| CMI Production | https://pay.cmi.co.ma |
| Docker Registry | ghcr.io/elmokef-ma/ |

---

## 📂 وثائق الفريق السابق

كل مجلد في `team/` يحتوي على تقارير كاملة:

| المجلد | المحتوى |
|--------|---------|
| `01-business-analyst` | تحليل السوق + SWOT + User Stories |
| `02-product-manager` | Roadmap + خطة Sprint 10 |
| `03-solution-architect` | ADR + Ranking Engine PoC |
| `04-ui-ux-designer` | Design System + Wireframes + كل التصاميم |
| `05-flutter-developer` | تقارير Sprints 1-10 |
| `06-backend-developer` | تقارير Sprints 1-9 |
| `07-database-engineer` | فهارس + تحسينات ×13.5 |
| `08-devops-engineer` | (لم ينجز — إنذار) |
| `09-qa-engineer` | خطط اختبار Sprints 3-9 |
| `10-security-specialist` | تقارير أمنية Sprints 4, 7, 9 |
| `11-marketing-manager` | خطة إطلاق Beta + مواد تسويقية |
| `12-react-developer` | Admin Panel |

---

## ✅ ما تم إنجازه (9 Sprints)

| Sprint | المحتوى | % |
|--------|---------|---|
| S1 | Infrastructure (Flutter + NestJS + PostgreSQL + Docker) | 100% |
| S2 | Auth Module (تسجيل، دخول، OAuth، OTP، RBAC) | 100% |
| S3 | Services & Search (فئات، بحث، خريطة OSM) | 100% |
| S4 | Artisan Module (Wizard، ملف، Simplified Mode) | 100% |
| S5 | Ranking Engine (خوارزمية ترتيب ×39 تحسين) | 100% |
| S6 | Reviews & Complaints (تقييمات، شكايات، Trust Layer) | 100% |
| S7 | Subscriptions & Payments (CMI، WebSocket، تجديد) | 100% |
| S8 | Admin Panel + Notifications (FCM/HMS) | 100% |
| S9 | QA & Performance (18 US، k6، RTL، أمن) | ~90% |

**بقي Sprint 10 (Beta Launch) + النواقص أعلاه.**

---

## 🚀 البداية للفريق الجديد

1. `git init` و `git add .` و `git commit -m "init: elmokef project handoff"`
2. ارفع على GitHub
3. اشترِ VPS (Hetzner CX42 ~€41/شهر)
4. شغّل `docker-compose.prod.yml`
5. اربط Firebase + CMI production
6. ابدأ Sprint 10

**حظاً موفقاً! 🚀**
