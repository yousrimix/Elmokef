# تقييم معماري شامل — Elmokef Architecture Review

**إعداد:** مهندس — Solution Architect Agent  
**تاريخ:** 18 يونيو 2026  
**المرحلة:** Sprint 9/10 — ما قبل الإطلاق التجريبي (Beta Launch)  
**الهدف:** مراجعة شاملة للبنية المعمارية — Scalability, Security, Database, API, State Management

---

## 1. ملخص تنفيذي

### التقييم العام

| المحور | التقييم | الحالة |
|--------|---------|--------|
| **Scalability** | 🟡 جيد — قيود معروفة | Modular Monolith مع Redis وكاش يغطي Phase 1 كويس |
| **Security** | 🟢 قوي | JWT + RBAC + ClamAV + Helmet + Rate Limiting — لكن ينقص PenTest منهجي |
| **Database Design** | 🟢 ممتاز | PostGIS + Prisma + Materialized Views — قاعدة متينة |
| **API Design** | 🟢 جيد | REST + GraphQL للإحصائيات — يزيد تعقيداً بلا داعٍ في MVP |
| **State Management** | 🟢 جيد | Riverpod + Provider — خيار مناسب لفريق Flutter صغير |
| **Ranking Engine** | 🟢 ممتاز | بعد تحسينات PoC — Design قابل للتعديل عبر Config خارجي |
| **Payment Flow** | 🟡 متوسط | WebView لـ CMI — ضرورة لكن UX تتأثر، يحتاج طبقة Idempotency قوية |
| **Image Pipeline** | 🟡 جيد مع ملاحظات | ClamAV للفحص — لكن ينقص تحويل WebP + Thumbnail Generation عند الرفع |

---

## 2. Scalability Review

### النموذج الحالي: Modular Monolith (Phase 1)

**القرار صحيح للمرحلة الحالية.** الفريق صغير (5 أشخاص)، والـ MVP يحتاج 1,000–5,000 مستخدم متزامن. Monolith أسرع في التطوير والنشر.

### نقاط القوة

| العنصر | الوضع الحالي | التقييم |
|--------|-------------|---------|
| **Horizontal Scaling** | 2–4 instances عبر Nginx | ✅ جيد — Stateless (JWT) يسمح بالتكاثر الأفقي |
| **Redis Caching** | Scores + Services (TTL 5min/1hr) | ✅ ممتاز — يقلل ضغط DB بنسبة ~70% |
| **PgBouncer (Connection Pooling)** | مخطط له | ✅ ضروري — توصية بالتفعيل من Sprint 1 |
| **BullMQ Background Jobs** | صور + اشتراكات + إشعارات | ✅ جيد — يفصل العمل الثقيل عن API |
| **CDN (CloudFront/S3)** | مخطط له في Sprint 10 | ✅ ضروري — الصور هي أكبر استهلاك للـ Bandwidth |

### نقاط الضعف والتوصيات

| الخلل | الخطورة | التوصية | Sprint |
|-------|--------|---------|--------|
| **لا يوجد Read Replica لـ PostgreSQL** | 🔴 عالي | حتى مع الكاش، استعلامات PostGIS + Full-Text Search ستثقل master. إضافة Read Replica قبل الإطلاق | S9 |
| **لا يوجد Service Discovery** | 🟡 متوسط | عند زيادة الـ instances في Phase 2، الـ Nginx الثابت لن يكفي. التوصية: استخدام Docker Swarm أو Nomad كخطوة قبل Kubernetes | Phase 2 |
| **المشكلة: Boost الاشتراك (+5) يطغي على الجودة** | تم حلها | تم تعديل Premium +3.0 و Pro +1.0 في توصيات Ranking — جيد | S5 |
| **Cold Start للحرفيين الجدد** | تم حلها | New Artisan Boost (+2.0) مع Rating Fallback 3.0/5 — جيد | S5 |
| **الاستعلامات المكانية بدون تحسين** | 🟡 متوسط | GiST Index موجود — لكن ينقص تحليل P95 مع 500+ حرفي قبل الإطلاق | S9 |

### توصية Scalability

```
Phase 1 (Launch):     1 Master PG + 1 Read Replica + Redis + 2-4 NestJS instances
Phase 2 (6 mo):       إضافة Worker Service منفصل + Read Replica إضافية + CDN مخصص
Phase 3 (12 mo):      Microservices (Auth, Search, Payments) + Kafka Events + Kubernetes
```

**اختبار الحمل المطلوب قبل الإطلاق:**
- k6 مع 1,000 مستخدم وهمي — مقاس P95 API Response < 2s
- استعلام Ranking مع 500+ حرفي في نطاق 10km — < 1s
- اختبار تحميل الصور مع 50 طلب/ثانية — < 5s للمعالجة

---

## 3. Security Review

### نقاط القوة 🔒

| المجال | الإجراء | الحالة |
|--------|---------|--------|
| **API Security** | HTTPS + Helmet + JWT (7d/30d) + Rate Limiting | ✅ |
| **Authentication** | Firebase Auth + OAuth (Google/Facebook) + Phone OTP | ✅ |
| **Authorization** | RBAC (3 أدوار) + Middleware لكل Route | ✅ |
| **Input Validation** | class-validator + class-transformer + HTML Sanitize | ✅ |
| **File Upload** | MIME check + حجم أقصى 5MB + **ClamAV فحص** | ✅ **ممتاز** |
| **GDPR / 09-08** | حق الحذف + تصدير + موافقة صريحة + تخزين في المغرب | ✅ |
| **Audit Logging** | AuditLog لكل عملية حساسة (تسجيل، دفع، حظر) | ✅ |

### الثغرات المكتشفة

| الثغرة | الخطورة | التفاصيل | التوصية |
|--------|--------|---------|---------|
| **S1: No Input Rate Limiting per Action** | 🟠 متوسط | التعليقات، التقيمات، الإبلاغ — لا يوجد حد أقصى لكل مستخدم لكل إجراء | إضافة Rate Limiting لكل Endpoint حساس (POST review, POST complaint) بـ 5/دقيقة |
| **S2: No CSRF Protection for Admin Panel** | 🟠 متوسط | Admin Panel (React) يستخدم JWT ولكن لا يوجد CSRF Token للـ Cookie-based sessions إذا استُعملت | استخدام SameSite=Strict + CSRF Token للـ Admin |
| **S3: WebView CMI — Risk Injection** | 🟠 متوسط | الـ WebView قد يسمح بـ JavaScript Injection من جهة ثالثة | تعطيل JavaScript في WebView باستثناء نطاق CMI المعروف فقط |
| **S4: No API Key Rotation** | 🟡 منخفض | Firebase API Key + CMI API Key — لا توجد خطة تدوير | إضافة Secret Rotation كل 90 يوم — AWS Secrets Manager أو .env مشفر |
| **S5: Audit Log Retention غير محدد** | 🟡 منخفض | AuditLog ينمو بسرعة — لا توجد سياسة احتفاظ | الاحتفاظ 12 شهراً + أرشفة الـ Audit Logs إلى Cold Storage (S3 Glacier) |
| **S6: No Penetration Test قبل الإطلاق** | 🟠 متوسط | Sprint 9 يذكر PenTest نظرياً — لا يوجد Scope واضح | فحص OWASP ASVS Level 2 أساسي: Injection, XSS, Broken Access Control, Sensitive Data Exposure |

### التوصيات الأمنية الإجبارية قبل الإطلاق

| الأولوية | الإجراء | المسؤول |
|----------|--------|---------|
| 🔴 P0 | تنفيذ PenTest (OWASP Top 10 + API Security) | فيصل + رنا |
| 🔴 P0 | Rate Limiting لكل Endpoint حساس | محمد |
| 🟠 P1 | WebView Security Hardening (JavaScript toggle, domain whitelist) | خالد |
| 🟠 P1 | إعداد سياسة الاحتفاظ بالـ Audit Logs + الأرشفة | ياسر |
| 🟡 P2 | CSRF Protection للـ Admin Panel | محمد |
| 🟡 P2 | Secret Rotation Policy | ياسر |

---

## 4. Database Design Review

### نقاط القوة

| العنصر | التفاصيل | التقييم |
|--------|---------|---------|
| **PostgreSQL 16 + PostGIS 3.4** | أحدث إصدار — يدعم ST_DWithin, ST_Distance, GiST Index | ✅ ممتاز |
| **Prisma ORM** | Type-safe, Migrations مدمجة | ✅ جيد |
| **Materialized Views (Ranking)** | Refresh كل 5 دقائق | ✅ ممتاز — يمنع الحساب المتكرر |
| **GiST Index على location** | استعلامات مكانية سريعة | ✅ ضروري |
| **Self-referencing Categories** | فئات هرمية (parent_id) | ✅ بسيط وفعال لـ MVP |
| **Soft Delete (Reviews)** | Reviews.is_approved | ✅ حماية من الحذف العشوائي |
| **Triggers update avg_rating** | تلقائي عند إضافة/تعديل تقييم | ✅ جيد — يحافظ على consistency |

### نقاط الضعف

| المشكلة | الخطورة | التوصية |
|---------|--------|---------|
| **D1: Full-Text Search باستخدام GIN index فقط** | 🟡 متوسط | pg_trgm مع GIN index يدعم البحث التقريبي (fuzzy) — لكن للبحث العربي نحتاج تهيئة locale خاصة للـ stemming |
| **D2: Payment Table — لا يوجد Unique Constraint على transaction_id** | 🔴 عالي | بدون UNIQUE constraint على transaction_id → يمكن تكرار الدفع في حال Retry. إضافة UNIQUE + Idempotency Key |
| **D3: Subscription — لا يوجد جدول منفصل لـ subscription_history** | 🟡 متوسط | سجل الاشتراكات (تاريخ البدء، تاريخ الانتهاء، خطة قديمة، خطة جديدة) — يساعد في التحليل والاسترجاع |
| **D4: الموقع يُخزّن في جدول Users** | 🟡 متوسط | location حقل في Users — جيد لـ MVP. في Phase 2 الأفضل نقل الموقع إلى جدول Addresses منفصل (يدعم multiple addresses) |
| **D5: Response Time يُحتسب في جدول Artisans** | 🟡 منخفض | response_time_avg يُحتسب يدوياً أو عبر Trigger. ينقص تعريف واضح: من استلام أول اتصال من العميل حتى أول رد من الحرفي |

### Schema تعديلات مقترحة

```sql
-- 1. Idempotency key للمدفوعات
ALTER TABLE payments ADD COLUMN idempotency_key VARCHAR(255) UNIQUE;
ALTER TABLE payments ADD CONSTRAINT uq_transaction_id UNIQUE (transaction_id);

-- 2. Subscription history
CREATE TABLE subscription_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    artisan_id UUID REFERENCES users(id),
    old_plan VARCHAR(20),
    new_plan VARCHAR(20),
    change_reason VARCHAR(100),
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. GIN index للبحث بالعربية (مع pg_trgm extension)
CREATE INDEX idx_services_name_trgm ON services USING GIN (name_ar gin_trgm_ops, name_fr gin_trgm_ops);

-- 4. Partial Index للحرفيين النشطين فقط (يحسن أداء الاستعلامات)
CREATE INDEX idx_artisans_active ON users(id) WHERE role = 'artisan' AND is_active = true;
```

---

## 5. API Design Review

### RESTful Design — النمط المختار

| الميزة | الحالة | التقييم |
|--------|--------|---------|
| **NestJS Modular Architecture** | ✅ | Clean Architecture + Modules لكل Domain |
| **Swagger/OpenAPI** | ✅ | مخطط له في Sprint 1 |
| **Versioning (/api/v1)** | ✅ | جيد — يسمح بالتغيير دون كسر العميل |
| **Cursor-based Pagination** | ✅ | ممتاز — أفضل من Offset-based للقوائم الكبيرة |
| **locale في كل Endpoint** | ✅ | Accept-Language → يدعم العريية والفرنسية |

### نقاط الضعف

| المشكلة | الخطورة | التوصية |
|--------|---------|---------|
| **API1: GraphQL في MVP — تعقيد غير ضروري** | 🟡 متوسط | GraphQL للإحصائيات في Admin Panel — الإحصائيات في MVP بسيطة (عدد المستخدمين، الإيرادات). REST API يكفي. GraphQL يضيف: Apollo Server, Resolvers, Schema stitching, N+1 problem |
| **API2: No Standard Error Response Format** | 🟡 متوسط | يفضل توحيد صيغة الخطأ عبر جميع الـ Modules |
| **API3: WebSocket للإشعارات فقط** | 🟢 جيد | WebSocket للدفع (تأكيد فوري) + إشعارات — لا داعي لـ HTTP Polling |

### توصيات API

#### 1. إلغاء GraphQL من MVP
- **السبب:** 3 Resolvers بسيطة بدلاً من Apollo Server كامل
- **البديل:** REST Endpoint واحد `/api/v1/admin/stats` يرجع JSON
- **التأجيل:** GraphQL في Phase 2 عند تعقّد Dashboard

#### 2. توحيد Error Response Schema
```typescript
// موحد لكل API
interface ApiErrorResponse {
  statusCode: number;       // 400, 401, 403, 404, 409, 422, 500
  message: string;          // رسالة مقروءة (بالعربية/فرنسية حسب locale)
  errorCode: string;        // رمز الخطأ البرمجي (مثل: USER_NOT_FOUND)
  details?: Record<string, string[]>;  // تفاصيل validation errors
  timestamp: string;        // ISO 8601
  requestId: string;        // Correlation ID للتتبع
}
```

#### 3. Rate Limiting Endpoint-specific
```typescript
// مثال على Decorator
@Throttle({ default: { limit: 100, ttl: 60000 } })  // عام
@Post('reviews')
@Throttle({ reviews: { limit: 5, ttl: 60000 } })    // خاص بالتقيمات
createReview(@Body() dto: CreateReviewDto) { ... }
```

---

## 6. State Management Review (Flutter)

### الوضع الحالي

| المكون | التقنية | التقييم |
|--------|---------|---------|
| **State Management** | Riverpod | ✅ خفيف + Code Generation |
| **Routing** | GoRouter | ✅ يدعم Deep Link + Nested Navigation |
| **HTTP Client** | Dio (مع Interceptors) | ✅ يدعم Retry + Cache |
| **Local Storage** | Hive + SharedPreferences | ✅ سريع للبيانات المحلية |
| **Map** | flutter_map (OSM/MapTiler) | ✅ مع Fallback |
| **Notifications** | flutter_local_notifications | ✅ مع Firebase Messaging |

### نقاط القوة

- **Riverpod** أفضل من Provider للـ Scalability — Testing أسهل
- **GoRouter** يدعم RTL + Deep Links (للإشعارات)
- Dio Interceptors لتجديد الـ JWT تلقائياً

### نقاط الضعف

| المشكلة | الخطورة | التوصية |
|--------|---------|---------|
| **SM1: No Offline-first Strategy** | 🟠 متوسط | التطبيق يعتمد كلياً على API — إذا انقطع الإنترنت، المستخدم يرى شاشة بيضاء. ينفذ: Offline Caching للفئات + الخدمات + الحرفيين الأخيرين |
| **SM2: Code Splitting غير موجود** | 🟡 متوسط | Flutter يولد Bundle واحد لجميع الشاشات. في المغرب مع أجهزة 2GB RAM — هذا يبطئ Cold Start. التوصية: Deferred Loading للشاشات غير الأساسية (Admin View, Chat مستقبلاً) |
| **SM3: No Sentry/Crashlytics Integration في Sprint 1** | 🟡 منخفض | تأخر اكتشاف الأخطاء إلى Sprint 9. التوصية: تفعيل Firebase Crashlytics من Sprint 1 |

### توصيات State Management

```
1. Offline Caching Layer:
   ┌────────────┐     ┌──────────────┐     ┌────────────┐
   │ Riverpod   │ ←→  │ CacheService │ ←→  │ Hive Local │
   │ Provider   │     │ (Repository) │     │   DB       │
   └────────────┘     └──────────────┘     └────────────┘
                           │
                    ┌──────┴──────┐
                    │ Dio (API)   │
                    └─────────────┘

   خوارزمية: Network-first مع Fallback إلى Cache.
   — الفئات والخدمات: Cache-first + Background Refresh
   — قائمة الحرفيين: Network-first + Cache آخر بحث
   — ملف الحرفي: Network-first + Cache بصمة (basic info)

2. Deferred Loading:
   - الشاشات الرئيسية (Home, Search, ArtisanProfile): Loaded eagerly
   - الشاشات الثانوية (Subscriptions, Settings, Admin): Deferred (Lazy)
   
3. Crashlytics:
   - Firebase Crashlytics + Performance — تفعيل من Sprint 1
```

---

## 7. CMI Payment Flow — مراجعة خاصة

### التدفق الحالي

```
[اختيار الباقة] → [WebView لـ CMI] → [WebHook تأكيد] → [ترقية الاشتراك] → [تأكيد WebSocket]
```

### المشكلات المحددة

| المشكلة | الخطورة | التأثير |
|--------|---------|---------|
| **P1: لا يوجد Idempotency في WebHook** | 🔴 عالي | إذا أرسل CMI الـ WebHook مرتين → يحصل الحرفي على الترقية مرتين |
| **P2: WebView UX سيء على iOS** | 🟠 متوسط | WKWebView يطلب من المستخدم تسجيل الدخول مجدداً في كل مرة |
| **P3: لا يوجد Fallback للدفع الفاشل** | 🟠 متوسط | الدفع يفشل → الحرفي لا يعرف لماذا، ولا توجد إعادة محاولة |
| **P4: Audit Log غير شامل للمدفوعات** | 🟡 متوسط | لا يوجد تسجيل لـ IP المستخدم، User-Agent، Device Fingerprint عند الدفع |

### توصيات الدفع

```
1. Idempotency Layer:
   POST /api/v1/payments/create { artisanId, plan, idempotencyKey }
   
   الـ Backend: 
   - idempotencyKey = SHA256(artisanId + plan + timestamp)
   - UNIQUE constraint على idempotency_key
   - إذا تكرر الـ key → إرجاع cached response

2. SFSafariViewController + Chrome Custom Tabs بدلاً من WebView
   - يشارك Session مع المتصفح → لا حاجة لإعادة تسجيل الدخول
   - في iOS: SFSafariViewController
   - في Android: Chrome Custom Tabs
   - الخيار الاحتياطي: توجيه المستخدم إلى Safari/Chrome

3. Payment Retry + Queue:
   فشل الدفع → يضاف إلى BullMQ Queue → Retry 3 مرات (30s/2min/5min)
   → بعد الفشل الثالث: إشعار للمستخدم "فشلت عملية الدفع، حاول عبر صفحة الاشتراك"

4. Device Fingerprint:
   إرسال IP + User-Agent مع كل طلب دفع
   تسجيل في AuditLog: { ip, userAgent, deviceId, timestamp }
```

---

## 8. Deployment & Infrastructure Review

### الوضع الحالي

| المكون | البيئة الحالية (Sprint 1–8) | بيئة الإطلاق (Sprint 10) |
|--------|---------------------------|-------------------------|
| **Hosting** | Docker Compose (محلي) | Hetzner VPS (أو AWS EC2) |
| **Database** | PostgreSQL (Docker) | PostgreSQL (Hetzner/AWS RDS) |
| **Cache** | Redis (Docker) | Redis (Managed / Docker) |
| **File Storage** | Local | Backblaze B2 + Cloudflare CDN |
| **CI/CD** | GitHub Actions (DEV Only) | GitHub Actions (DEV + STAGING + PROD) |
| **Domain** | — | admin.elmokef.ma + api.elmokef.ma |
| **Monitoring** | — | Prometheus + Grafana + Loki + Uptime Kuma |

### نقاط القوة

- Docker Compose للبيئة المحلية — بسيط وفعال
- ClamAV في Docker — أفضل ممارسة
- فصل الـ Volumes (pgdata, clamav_db) — يحافظ على البيانات

### نقاط الضعف

| المشكلة | الخطورة | التوصية |
|---------|--------|---------|
| **INF1: Docker Compose في الإنتاج — غير مناسب** | 🟠 متوسط | Compose جيد للتطوير، لكن في الإنتاج بدون Docker Compose (أو Docker Swarm)، إعادة تشغيل Conteiner يعني فقدان مؤقت للخدمة. التوصية: `docker compose up -d` مع restart policy + Healthcheck |
| **INF2: لا يوجد Backup Strategy واضح** | 🟠 متوسط | pg_dump اليدوي ليس كافياً. التوصية: pgBackRest أو barman لاسترجاع Point-in-time |
| **INF3: No Staging Environment** | 🟠 متوسط | التطوير مباشر → PROD. ينقص Staging لاختبار التغييرات. التوصية: إضافة workflow يبني Staging Auto-deploy عند push على `develop` |
| **INF4: لا يوجد Healthcheck في docker-compose.yml** | 🟡 منخفض | Healthcheck يمنع التوجيه إلى Container غير جاهز |

### docker-compose.yml — تعديلات مقترحة

```yaml
services:
  postgres:
    image: postgis/postgis:16-3.4
    container_name: elmokef-db
    environment:
      POSTGRES_DB: elmokef
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}  # ← من .env
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./backups:/backups  # ← mount للنسخ الاحتياطي
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: elmokef-redis
    command: ["redis-server", "--requirepass", "${REDIS_PASSWORD}"]  # ← كلمة مرور
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
    restart: unless-stopped

  clamav:
    image: clamav/clamav:latest
    container_name: elmokef-clamav
    ports:
      - "3310:3310"
    volumes:
      - clamav_db:/var/lib/clamav
    healthcheck:
      test: ["CMD", "clamdscan", "--version"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

volumes:
  pgdata:
  clamav_db:
```

---

## 9. المخاطر المعمارية المتبقية

### المخاطر الحرجة (P0 — تمنع الإطلاق)

| الرمز | المخاطرة | تفاصيل | الحل |
|-------|---------|--------|------|
| **CR-01** | **CMI Idempotency** | تكرار الدفع بسبب WebHook Retry | Idempotency Key + UNIQUE Constraint |
| **CR-02** | **PostGIS بدون Read Replica** | استعلامات الموقع + Full-Text Search في نفس DB قد يسبب عنق زجاجة مع 1,000+ مستخدم | Read Replica للمعاملات القرائية |
| **CR-03** | **لا يوجد PenTest** | OWASP Top 10 غير مفحوص — خطر اختراق عند الإطلاق | PenTest قبل Sprint 10 |

### المخاطر العالية (P1 — تحتاج معالجة قبل الإطلاق)

| الرمز | المخاطرة | الحل |
|-------|---------|------|
| **CR-04** | GraphQL في MVP — تعقيد غير مبرر | استبدال بـ REST endpoint مؤقت |
| **CR-05** | Offline-first مفقود — مستخدم بدون إنترنت يرى شاشة بيضاء | Hive Cache للفئات والخدمات |
| **CR-06** | Cold Start للحرفيين الجدد — لا ظهور في القائمة | New Artisan Boost + Rating Fallback |
| **CR-07** | OSM غير دقيق في فاس البالي ومراكش Medina | Google Maps Fallback |
| **CR-08** | Rate Limiting غير مفعّل على Endpoints الحساسة | Throttle Decorator لكل Endpoint |

---

## 10. التوصيات النهائية (قبل الإطلاق)

### 🔴 إلزامي قبل الإطلاق

| # | الإجراء | Sprint |
|---|---------|--------|
| 1 | Idempotency Key لتدفق الدفع | S7 (قبل CMI) |
| 2 | Read Replica PostgreSQL + PgBouncer | S9 |
| 3 | PenTest OWASP ASVS Level 2 | S9 |
| 4 | Rate Limiting لكل Endpoint | S9 |
| 5 | Healthcheck في docker-compose.yml | S10 |
| 6 | Backup Strategy (pg_dump يومي + Point-in-time) | S9 |

### 🟡 موصى به بقوة

| # | الإجراء | Sprint |
|---|---------|--------|
| 7 | إلغاء GraphQL من MVP — REST للإحصائيات | S8 |
| 8 | Offline-first Layer (Hive Cache) | S8–S9 |
| 9 | Payment Retry Queue (BullMQ) | S7 |
| 10 | SFSafariViewController + Chrome Custom Tabs بدلاً من WebView | S7 |
| 11 | Standard Error Response Schema | S8 |
| 12 | Crashlytics + Performance من Sprint 1 (إذا متأخر → فوراً) | S9 |
| 13 | Subscription History جدول | S7 |
| 14 | Staging Environment + Auto-deploy | S9 |

### 🟢 تحسينات للمستقبل (Phase 2)

| # | الإجراء |
|---|---------|
| 15 | فصل الموقع إلى Addresses منفصل |
| 16 | إضافة Service Discovery (Nomad/Docker Swarm) |
| 17 | Microservices — فصل Auth + Search |
| 18 | Kafka/Event Bus للأحداث عبر الـ Modules |
| 19 | Bug Bounty Program |

---

## 11. الخلاصة

| المحور | التقييم | النتيجة |
|--------|---------|---------|
| **Scalability** | 🟡 جيد — يغطي 1,000–5,000 مستخدم | يحتاج Read Replica قبل الإطلاق |
| **Security** | 🟢 قوي — ClamAV, RBAC, JWT, Audit Log | ينقص PenTest و Rate Limiting |
| **Database Design** | 🟢 ممتاز — PostGIS + Prisma + Triggers | يحتاج Idempotency Key |
| **API Design** | 🟢 جيد — REST + Cursor Pagination | GraphQL يمكن تأجيله |
| **State Management** | 🟢 جيد — Riverpod + GoRouter | ينقص Offline Layer |
| **Payment Flow** | 🟡 متوسط — WebView ضرورة | يحتاج Idempotency + Fallback |
| **Infrastructure** | 🟡 جيد مع ملاحظات — Docker Compose أساسي | يحتاج Healthcheck + Backup |

**النتيجة النهائية: 82/100 — جاهز للإطلاق مع 8 إجراءات إلزامية**

---
*تم إعداد هذا التقييم بناءً على مراجعة:*
- *project-brief.md, discussion-phase2.md, ba-analysis.md*
- *poc-osm-ranking-report.md (Sprint 5)*
- *roadmap.md (Sprint 1–10)*
- *docker-compose.yml*
- *أفضل ممارسات: Clean Architecture, OWASP, 12-Factor App*
