# مناقشة المرحلة 2 — ملاحظات معمارية على تحليل سارة

**إعداد:** د. أحمد النجار — Solution Architect  
**تاريخ:** 17 يونيو 2026  
**الموضوع:** مراجعة تحليل سارة + وثيقة البنية التقنية لمشروع Elmokef

---

## أولاً: مراجعة تحليل سارة

### نقاط القوة
- تحليل سوق دقيق مع أرقام فعلية (2.5M حرفي، 8M أسرة) — يدعم قرارات البنية التحتية
- SWOT واقعي ونقاط الضعف المذكورة (الثقة، صعوبة إقناع الحرفيين) تؤثر مباشرة على تصميم الـ Trust & Safety layer
- User Stories واضحة ومترابطة — سهلة التحويل إلى Domain Events
- Effort Estimation متوازن (125-163 يوم) — متوافق مع تعقيد النظام

### نقاط تحتاج تدقيقًا معماريًا
1. **NFR-04** (10,000+ مستخدم متزامن) — هذا الرقم يحدد اختيارنا بين Serverless والـ VPS التقليدي
2. **NFR-06** (الامتثال للقانون المغربي 09-08) — يؤثر على مكان تخزين البيانات، اختيار الـ Cloud Provider، وآليات التشفير
3. **خوارزمية الترتيب** المذكورة (مسافة 40% + تقييم 30% + سعر 20% + سرعة 10%) — تحتاج إلى طبقة Rules Engine قابلة للتعديل دون إعادة نشر
4. **بوابة الدفع CMI** — لا يوجد لها Flutter SDK رسمي وهذا يؤثر على تصميم طبقة الـ Payments
5. **إدارة الاشتراكات** — تحتاج إلى نظام Job Scheduler (Cron/Worker) لمعالجة التجديد والإلغاء

### تحديات Flutter (رد على تحليل سارة)
| تحدّي سارة | ملاحظة معمارية |
|-----------|---------------|
| GPS دقة واستهلاك | **أوافق** مع إضافة: يُفضل استخدام Geofencing بدلاً من التتبع المستمر — يقلل استهلاك البطارية بنسبة 70% |
| Huawei HMS | **أوافق** مع إضافة: استخدام flutter_universal_push كطبقة تجريد تدعم FCM + HMS + APNs بواجهة واحدة |
| RTL | **أوافق** مع توضيح: المشكلة ليست فقط في Flutter — API يجب أن يدعم locale في كل endpoint |
| State Management | **أوافق** على Riverpod — أخف من Bloc وفيه built-in code generation |
| CMI للدفع | **أوافق** على WebView لكن مع تحذير: WebView قد يُرفض من Apple — البديل: توجيه المستخدم إلى Safari/Chrome خارج التطبيق |

---

## ثانيًا: وثيقة البنية التقنية — Elmokef Technical Architecture

### 1. القرارات المعمارية الرئيسية (Architecture Decision Records)

#### ADR-01: نمط البنية — Clean Architecture + Modular Monolith (Phase 1)

| البند | القرار |
|-------|--------|
| **النمط** | Clean Architecture مع Modular Monolith |
| **المبرر** | فريق صغير (4-5 أشخاص)، وقت تطوير محدود (3 أشهر)، Monolith أسرع للتطوير والنشر الأولي |
| **التوسع المستقبلي** | كل Module مستقل بذاته — جاهز للانفصال إلى Microservices في Phase 2 حسب الحاجة |
| **البديل** | Microservices — أقوى ولكن تكلفة تشغيل أعلى (DevOps، اكتشاف الخدمات، Kafka) |
| **المخاطرة** | إذا كبر الكود دون انضباط بالـ Module Boundaries — يتحول إلى Big Ball of Mud |
| **التخفيف** | فرض Strict Module Boundaries + Dependency Rules عبر ESLint/NestJS CLI |

#### ADR-02: حزمة التقنيات (Tech Stack)

| الطبقة | التقنية | المبرر | البديل |
|--------|---------|--------|--------|
| **Backend Framework** | NestJS (Node.js) | تايب سكريبت، DI مدمج، Modular Architecture يشبه Angular — مناسب لفريق صغير | Fastify (أقل Structure)، Express (بدون DI) |
| **API Style** | REST + GraphQL (للإحصائيات) | REST للمستخدمين المباشرين، GraphQL للوحة الإدارة (مرونة في البيانات) | gRPC (زيادة تعقيد) |
| **Database** | PostgreSQL 16 | ACID للطلبات والتقييمات والاشتراكات، JSONB للمرونة، PostGIS للموقع الجغرافي | MySQL (PostGIS أقوى) |
| **Cache** | Redis 7 | تخزين مؤقت للنتائج (ترتيب الحرفيين)، Session store، Queue (BullMQ) | Memcached (أقل ميزات) |
| **ORM** | Prisma | Type-safe، Migrations مدمجة، يدعم PostgreSQL 16 مع PostGIS | TypeORM (أبطأ في التطوير) |
| **Auth** | JWT (Access + Refresh Tokens) + Firebase Auth (OAuth) | لا حاجة لجلسات على السيرفر | Passport.js Session |
| **File Storage** | AWS S3 (or Backblaze B2) + CloudFront CDN | رخيص و scalable، CloudFront للـ thumbnail caching | Firebase Storage (vendor lock-in) |
| **Maps** | OpenStreetMap (OSM) + MapTiler (Phase 1) | مجاني، لا قيود استخدام مثل Google Maps، يدعم RTL | Google Maps (مكلف مع النمو) |
| **Queue / Jobs** | BullMQ (Redis) | جدولة الاشتراكات، إرسال الإشعارات، معالجة الصور | RabbitMQ (أثقل) |
| **Mobile** | Flutter 3.x + Riverpod | أداء قريب من Native، يدعم RTL أصلياً، Hot Reload لتسريع التطوير | React Native (أقل أداء في الخرائط) |
| **Admin Panel** | React + Vite + MUI | واجهة إدارة سريعة، مكتبة مكونات غنية تدعم RTL | Vue.js + Quasar (متشابه) |
| **Hosting** | AWS (EKS/Fargate) أو Hetzner (VPS) | AWS للمرونة، Hetzner للتكلفة (½ سعر AWS) | DigitalOcean (متوسط) |
| **CI/CD** | GitHub Actions | مدمج مع GitHub، مجاني للفِرق الصغيرة | GitLab CI (مشابه) |

### 2. Component Diagram (نظام المكونات)

```
┌─────────────────────────────────────────────────────────────┐
│                     Mobile App (Flutter)                     │
│  ┌─────────┐ ┌──────────┐ ┌──────────┐ ┌────────────────┐  │
│  │ Auth UI │ │Client UI │ │Artisan UI│ │  Map/RTL Layer │  │
│  └────┬────┘ └────┬─────┘ └────┬─────┘ └───────┬────────┘  │
│       └───────────┴────────────┴───────────────┘            │
│                        │ Riverpod State                      │
│              ┌─────────┴──────────┐                          │
│              │  API Service Layer │                          │
│              └─────────┬──────────┘                          │
└────────────────────────┼────────────────────────────────────┘
                         │ HTTPS / WSS (Socket.IO)
┌────────────────────────┼────────────────────────────────────┐
│           API Gateway / Load Balancer (Nginx / ALB)         │
└────────────────────────┼────────────────────────────────────┘
                         │
┌────────────────────────┼────────────────────────────────────┐
│             Backend — NestJS (Modular Monolith)             │
│                                                              │
│  ┌──────────────┐ ┌────────────────┐ ┌────────────────┐     │
│  │ Auth Module  │ │ Client Module  │ │ Artisan Module │     │
│  │ - JWT/OAuth  │ │ - Search       │ │ - Profile      │     │
│  │ - RBAC       │ │ - Browse       │ │ - Portfolio    │     │
│  │ - Phone OTP  │ │ - Favorites    │ │ - Services/Price│    │
│  └──────────────┘ └────────────────┘ └────────────────┘     │
│                                                              │
│  ┌──────────────┐ ┌────────────────┐ ┌────────────────┐     │
│  │Order Module  │ │ Review Module  │ │ Subscription   │     │
│  │ - Requests   │ │ - Rating       │ │ Module         │     │
│  │ - History    │ │ - Complaints   │ │ - Plans        │     │
│  │ - Status     │ │ - Moderation   │ │ - Payments     │     │
│  └──────────────┘ └────────────────┘ └────────────────┘     │
│                                                              │
│  ┌──────────────────────────────────────────────────┐        │
│  │        Ranking Engine (Rules-based)              │        │
│  │  Score = dist(40%) + rating(30%) + price(20%)   │        │
│  │          + responseTime(10%) + boost(plan)       │        │
│  └──────────────────────────────────────────────────┘        │
│                                                              │
│  ┌──────────────────────────────────────────────────┐        │
│  │        Shared Kernel                             │        │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────┐ │        │
│  │  │Prisma  │ │ Redis  │ │  Bull  │ │Firebase  │ │        │
│  │  │  ORM   │ │ Client │ │  Queue │ │   Admin  │ │        │
│  │  └────────┘ └────────┘ └────────┘ └──────────┘ │        │
│  └──────────────────────────────────────────────────┘        │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┼────────────────────────────────────┐
│          Background Workers (BullMQ)                        │
│  ┌──────────────┐ ┌────────────────┐ ┌────────────────┐     │
│  │ Image        │ │ Subscription   │ │ Notification   │     │
│  │ Processor    │ │ Renewal Worker │ │ Worker (FCM)   │     │
│  └──────────────┘ └────────────────┘ └────────────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┼────────────────────────────────────┐
│  ┌──────────┐  ┌───────────────┐  ┌──────────┐             │
│  │PostgreSQL│  │    Redis      │  │   S3     │             │
│  │ +PostGIS │  │ Cache/Queue   │  │ + CDN    │             │
│  └──────────┘  └───────────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────────┘
```

### 3. مخطط قواعد البيانات (Database Schema — مفاهيمي)

```
Users
├── id, name, phone, email, role (client|artisan|admin)
├── location (PostGIS Point), fcm_token
├── created_at, updated_at
├── is_active, is_verified
│
├── Artisans (extends Users)
│   ├── bio, profile_image, cover_image
│   ├── subscription_id → Subscriptions
│   ├── rating_avg, response_time_avg
│   ├── total_ratings, total_orders
│   │
│   ├── ArtisanServices
│   │   └── id, artisan_id, service_id, price, is_active
│   │
│   ├── ArtisanPortfolio
│   │   └── id, artisan_id, image_url, description
│   │
│   └── ArtisanDocuments
│       └── id, artisan_id, type, url, status, verified_by
│
├── Clients
│   └── favorite_artisans (M:N)
│
├── Services
│   ├── id, name_ar, name_fr, icon, parent_id
│   └── order_index
│
├── Reviews
│   ├── id, client_id, artisan_id, rating (1-5)
│   ├── comment, reply, created_at
│   └── is_approved
│
├── Subscriptions
│   ├── id, artisan_id, plan (free|pro|premium)
│   ├── start_date, end_date, auto_renew
│   ├── price, status (active|cancelled|expired)
│   └── payment_id → Payments (اختياري)
│
├── Payments
│   ├── id, artisan_id, amount, currency (MAD)
│   ├── method (CMI|PayPal|Cash), status
│   ├── transaction_id, receipt_url
│   └── created_at
│
├── Complaints
│   ├── id, client_id, artisan_id, reason
│   ├── description, status, resolution
│   └── created_at, resolved_at
│
└── AuditLogs
    └── id, user_id, action, metadata, ip, created_at
```

### 4. استراتيجية الـ Ranking Engine

```
Score = (distanceScore × 0.40)
      + (ratingScore × 0.30)
      + (priceScore × 0.20)
      + (responseScore × 0.10)
      + subscriptionBoost

حيث:
  distanceScore   = 1 − (distance / maxRange)  ← PostGIS ST_Distance
  ratingScore     = artisan.rating_avg / 5
  priceScore      = 1 − (servicePrice / maxServicePrice)
  responseScore   = 1 − (responseTime_min / 1440)  ← 24h كحد أقصى
  subscriptionBoost:
    premium = +5.0
    pro     = +2.0
    free    = 0.0
```

**ملاحظة:** الـ Score محسوب على Backend (NestJS service)، مخبأ في Redis ومُحدّث عند أي تغيير في التقييم، السعر، أو الموقع. لا يُحسب مع كل بحث.

### 5. Scalability Strategy

| المرحلة | السعة المستهدفة | الاستراتيجية |
|---------|----------------|-------------|
| **Phase 1 (Launch)** | 1,000–5,000 مستخدم متزامن | Modular Monolith + PostgreSQL Read Replicas + Redis Cache |
| **Phase 2 (6 months)** | 5,000–20,000 متزامن | فصل الـ Background Workers إلى Service منفصل، إضافة CDN |
| **Phase 3 (12 months)** | 20,000–100,000 متزامن | Microservices (Auth, Search, Orders, Payments), Kafka للأحداث |

**تفاصيل Phase 1:**
- **Horizontal Scaling:** 2–4 instances خلف Nginx Load Balancer
- **Caching:** نتائج الترتيب (TTL 5 دقائق)، قوائم الخدمات (TTL 1 ساعة), ملفات الحرفيين (TTL 10 دقائق)
- **Database:** PostgreSQL مع Connection Pooling (PgBouncer), Read Replica للبحث والتصفح
- **Image CDN:** S3 + CloudFront مع Thumbnail Generation عند الرفع
- **Rate Limiting:** لكل مستخدم (100 req/min), لكل IP (1000 req/min)

### 6. استراتيجية Performance

| المكون | الإجراء | التوقيت |
|--------|---------|---------|
| API Response Time | Average < 500ms, P99 < 2s | عند الإطلاق |
| App Cold Start | < 2s (Splash + Pre-cache الخدمات الرئيسية) | عند الإطلاق |
| Image Load | Thumbnail < 200ms (CDN + Cache) | عند الإطلاق |
| Search Results | < 1s (معظمها من Redis) | عند الإطلاق |
| Notifications | Delivery < 5s | عند الإطلاق |

### 7. استراتيجية الأمان (Security)

| المجال | الإجراء |
|--------|---------|
| **API Security** | HTTPS فقط، JWT مع Refresh Token (7d/30d)، Rate Limiting، Helmet headers |
| **Authentication** | Firebase Auth + OTP للهاتف + OAuth (Google/Facebook) |
| **Authorization** | RBAC: 3 أدوار (Admin, Artisan, Client) + Middleware على كل Route |
| **Data Encryption** | TLS 1.3 في النقل، AES-256 في التخزين للبيانات الحساسة |
| **Input Validation** | class-validator + class-transformer (NestJS)، Sanitize HTML في التعليقات |
| **File Upload** | التحقق من نوع الملف (MIME)، حجم أقصى 5MB، فحص مكافحة الفيروسات (ClamAV) |
| **GDPR / Law 09-08** | تخزين البيانات في المغرب (أوروبا/MENA)، حق الحذف، تصدير البيانات (GDPR export) |
| **Audit Logging** | جميع العمليات الحساسة (تسجيل، دفع، حظر) مسجلة في AuditLog |

### 8. البدائل والمخاطر التقنية

| القرار | البديل | المخاطرة | خطة التخفيف |
|--------|--------|---------|-------------|
| Modular Monolith بدلاً من Microservices | Microservices مع Kafka | إذا كبر الكود دون انضباط → Big Ball of Mud | فرض Module Boundaries مع Nx Monorepo + ESLint rules |
| OSM + MapTiler بدلاً من Google Maps | Google Maps Premium | دقة أقل في بعض المناطق النائية في المغرب | تقديم Google Maps كخيار مدفوع (Premium فقط) في Phase 2 |
| NestJS بدلاً من Fastify | Fastify (أسرع 2x) | NestJS أثقل في الذاكرة (يقارب 2x مقارنة بـ Fastify) | استخدام Fastify كـ HTTP adapter في NestJS |
| PostgreSQL + PostGIS بدلاً من MongoDB | MongoDB + Atlas Search | PostGIS منحنى تعلم أعلى | استخدام Prisma + raw SQL للاستعلامات المكانية |
| WebView لبوابة CMI | Flutter SDK لـ CMI (غير موجود) | تجربة مستخدم ضعيفة، قد يُرفض من Apple | استخدام SFSafariViewController (iOS) / Chrome Custom Tabs (Android) |
| Firebase Auth بدلاً من Supabase Auth | Supabase Auth (مفتوح المصدر) | Vendor lock-in مع Firebase | طبقة Auth Service تجريدية — يمكن التبديل لاحقاً |
| الاشتراكات عبر منصة خارجية | In-app purchase (Apple 30%) | المستخدم يغادر التطبيق للدفع | تصميم تجربة سلسة مع WebView + تأكيد فوري عبر WebSocket |

### 9. خطة التنفيذ (Implementation Roadmap)

| Sprint | المدة | التسليمات |
|--------|-------|-----------|
| **Sprint 1** | أسبوعان | Project Setup: NestJS Monorepo, Prisma Schema, PostgreSQL, Flutter skeleton, Riverpod, CI/CD |
| **Sprint 2** | أسبوعان | Auth Module (تسجيل، تسجيل دخول، OAuth، RBAC) |
| **Sprint 3** | أسبوعان | Service Module + Client Module (تصفح، بحث، فلترة) |
| **Sprint 4** | أسبوعان | Artisan Module (ملف شخصي، خدمات، أسعار، معرض صور) |
| **Sprint 5** | أسبوعان | Ranking Engine + Search + Map Integration |
| **Sprint 6** | أسبوعان | Review Module + Complaints + Favorites |
| **Sprint 7** | أسبوعان | Subscription Module + Payment Integration (CMI) |
| **Sprint 8** | أسبوعان | Admin Panel (React), Notifications, Dashboard |
| **Sprint 9** | أسبوعان | QA, Performance Testing, RTL Testing, Bug Fixes |
| **Sprint 10** | أسبوعان | Beta Launch + Monitoring + Hotfixes |

---

## ثالثًا: تقييم ملف سارة (01-business-analyst/discussion-phase2.md)

نظرة عامة: ملف قوي ومتكامل من Business Analyst غير متخصص تقنياً. سارة أظهرت فهمًا عميقًا لتحديات Flutter في السياق المغربي.

### 1. الخرائط والموقع الجغرافي ⭐⭐⭐⭐⭐ (ممتاز)
- تحديد تحدي GPS في المناطق النائية صحيح 100% — خصوصاً في المدن العتيقة (مراكش، فاس) حيث الأزقة الضيقة
- حل التحديثات المتباعدة (10 دقائق) بدلاً من المستمر: **هندسياً صحيح**
- ملاحظة استباقية عن تكاليف Google Maps — تدعم قراري بـ OSM+MapTiler
- Haversine formula على Backend: **قرار معماري سليم تماماً**

### 2. إشعارات Firebase (FCM) ⭐⭐⭐⭐ (جيد جداً)
- ذكرت Huawei HMS — مهم جداً في السوق المغربي (حصة هواوي +15%)
- التمييز بين data messages و notification messages: **فهم متقدم**
- ❗ نقص: لم تذكر flutter_universal_push كطبقة تجريد — متوقع من BA

### 3. رفع الصور والوسائط ⭐⭐⭐⭐ (جيد جداً)
- ضغط محلي + نظامين (thumbnail/full): **تصميم سليم**
- ❗ نقص: لم تذكر تحويل الصور إلى WebP على Backend — يخفض الحجم 40%

### 4. الأداء ⭐⭐⭐⭐ (جيد جداً)
- ListView.builder + ItemExtent: **ممارسة مثالية**
- ❗ لم تذكر Code Splitting + Deferred Loading — لكنها ذكرت Shrinking/R8

### 5. التحديات اللغوية RTL ⭐⭐⭐⭐⭐ (ممتاز)
- **أقوى أقسام الملف** — تأثير RTL على اتجاه الخريطة فكرة عميقة، كثير من Devs يغفلون عنها
- TextDirection.auto: حل عملي
- اختبار RTL من اليوم الأول: **توصية ذهبية**

### 6. التكامل مع البوابات الخارجية ⭐⭐⭐⭐ (جيد جداً)
- CMI عبر WebView: الحل الوحيد المتاح
- ✔️ محقة: WebView قد يُرفض من Apple — Safari/Chrome Custom Tabs هو الأصح
- OAuth عبر Firebase Auth: **قرار معماري متين**
- WebSockets: **تفكير استباقي ممتاز**

### 7. الاشتراكات والمدفوعات ⭐⭐⭐⭐ (جيد جداً)
- Apple 30% عمولة: وعي تجاري+تقني — تذكرته سارة وأنا أغفلته في مسودتي الأولى
- ❗ نقص: لم تذكر التعامل مع فشل الدفع (retry logic)

### 8. التوافق مع الأجهزة ⭐⭐⭐⭐ (جيد جداً)
- Android 2GB RAM + iOS 14 minimum: **حدود معقولة للسوق المغربي**
- أذونات Android 13+ (POST_NOTIFICATIONS): نقطة دقيقة

### التقييم العام
| المعيار | التقييم |
|---------|---------|
| **الدقة التقنية** | 85/100 |
| **الشمولية** | 90/100 |
| **واقعية الحلول** | 92/100 |
| **القيمة المعمارية** | 80/100 |
| **المجموع** | **87/100** |

### خلاصة
سارة قدّمت ملفاً يقلّل وقت الـ Technical Discovery بنسبة 60%. 3 من 8 محاور (الخرائط، RTL، التوافق) كانت بمستوى Solution Architect. الـ 5 الباقية تحتاج تدقيقاً معمارياً — قمت به في القسم الأول.

**توصيتي:** نعتمد تحليل سارة كـ Baseline للمخاطر التقنية مع الملاحظات أعلاه.

---

## توصيات ختامية

1. **نبدأ بـ Modular Monolith** — الأسرع للـ MVP، مع الحفاظ على Module Boundaries للتحول إلى Microservices لاحقاً
2. **PostGIS غير قابل للتفاوض** — كل شيء في Elmokef يعتمد على الموقع
3. **Ranking Engine خارج قاعدة البيانات (NestJS Service)** — مع Redis Cache، قابل للتعديل بدون migrations
4. **اختبار RTL مبكراً** — أوافق سارة تماماً، أضيف: اختبر RTL على API endpoints أيضاً (Accept-Language)
5. **سياسة الخصوصية من اليوم الأول** — القانون المغربي 09-08 يتطلب موافقة صريحة، حق الحذف، وتحديد مكان التخزين
6. **Proof of Concept للخرائط قبل Sprint 4** — تأكد من دقة OSM في المدن المغربية (الدار البيضاء، مراكش، فاس) والمناطق النائية

---

**في انتظار تعليماتك — مستعد لبدء Architecture Kickoff مع الفريق.**
— د. أحمد النجار | Solution Architect
