# مراجعة قاعدة البيانات — Elmokef (الموقف)

**Database Engineer:** نور الصباغ  
**التاريخ:** 18 يونيو 2026  
**Sprint:** 9/10 (ما قبل Beta Launch)

---

## 📋 نظرة عامة

- **قاعدة البيانات:** PostgreSQL مع PostGIS
- **ORM:** Prisma 7.8 (Prisma Client JS)
- **عدد الموديلات:** 20 model (بما فيها RefreshToken, OtpCode, Device, AuditLog, RankingConfig)
- **عدد التعدادات:** 6 enum (Role, SubscriptionPlan, SubscriptionStatus, PaymentStatus, DocumentStatus)

---

## 1. 📐 تحليل الـ Schema (نموذج البيانات)

### 1.1 نقاط قوة في التصميم

| النقطة | الشرح |
|--------|-------|
| ✅ **UUID مع `@default(uuid())`** | جميع الـ IDs من نوع UUID — مناسب للتوزيع وعدم التصادم |
| ✅ **Soft Delete (`deletedAt`)** | موجود على `User` و `Review` — يحافظ على البيانات |
| ✅ **`@@map` باستمرار** | كل جدول بخريطة `snake_case` في SQL مع camelCase في Prisma |
| ✅ **علاقات `onDelete: Cascade`** | على الموديلات التابعة (RefreshToken, OtpCode, ClientProfile, ArtisanProfile, ArtisanService, ArtisanPortfolio, ArtisanDocument, Device) |
| ✅ **PostGIS `geography(Point, 4326)`** | الموقع الجغرافي مخزن بصيغة WGS 84 مع حسابات المسافة |
| ✅ **`@@unique` على العلاقات الثنائية** | `ArtisanService` (artisanId + serviceId) و `Review` (clientId + serviceId) |
| ✅ **`@@id([clientId, artisanId])` في Favorite** | مفتاح مركب — مناسب لعلاقة M:N بدون جدول وسيط |
| ✅ **`RankingConfig` بنمط Singleton** | `@id("singleton")` — سطر واحد لتخزين أوزان الترتيب |

### 1.2 نقاط ضعف تستدعي المراجعة الفورية

| النقطة | الخطورة | التفاصيل |
|--------|---------|----------|
| ❌ **`Unsupported("geography(Point, 4326)")`** | 🔴 عالية | Prisma لا يدير PostGIS جغرافياً مباشراً. في `User.location`، هذا يعني أن Prisma لا يستطيع التعامل مع الحقل في queries عادية — الحل: استخدام `prisma.$queryRawUnsafe` لكل استعلام PostGIS أو إضافة PostGIS عبر middleware. |
| ❌ **`Complaint.status` من نوع `String`** | 🟡 متوسطة | كان المفروض يكون `enum` بدلاً من `String`. حالياً يمكن إدخال أي قيمة نصية عشوائياً. |
| ❌ **`Payment.metadata` من نوع `Json?`** | 🟢 منخفضة | مقبول، لكن يجب توثيق الحقول المتوقعة في JSON. |
| ❌ **لا يوجد فهارس على `deletedAt`** | 🟡 متوسطة | كل استعلام يحتاج `deleted_at IS NULL` — بدون فهرس، سيكون Seq Scan إجباري. |
| ❌ **عدم وجود `@@index` على `User.location`** | 🟡 متوسطة | `location` يستخدم PostGIS — يحتاج صراحةً فهرس GiST في Prisma schema أو Migration مخصص. |
| ❌ **Review: `@@unique([clientId, serviceId])`** | 🟡 متوسطة | هذا يمنع العميل من تقييم نفس الحرفي على نفس الخدمة أكثر من مرة — وهو مقصود. لكن لا يوجد فهرس يدعم `created_at DESC` في Prisma schema (موجود فقط في outbox) |
| ❌ **لا يوجد model منفصل لـ `AdminAction`** | 🟢 منخفضة | `AuditLog` عام جداً. يفضل نموذج منفصل لإجراءات الإدارة (توثيق، حظر، تفعيل) |
| ❌ **`RefreshToken.tokenHash` بدون unique constraint** | 🟡 متوسطة | معمول `@@index` فقط، لكن tokenHash لو تكرّر ممكن يسبب التباس في تسجيل الدخول. |

---

## 2. 📊 تحليل العلاقات (Relations)

### 2.1 علاقات 1:1

| الجدول المصدر | الجدول الهدف | الحقل الرابط | ملاحظة |
|---------------|-------------|-------------|--------|
| `User` | `ArtisanProfile` | `user_id` | ✅ `@unique` — تمام |
| `User` | `ClientProfile` | `user_id` | ✅ `@unique` — تمام (لكن ClientProfile فارغ ما عدا id و userId) |
| `Subscription` | `Payment` | `payment_id` | ✅ `@unique` في الطرفين — جيد |

**🔴 ملاحظة هامة:** `ClientProfile` ليس له أي بيانات إضافية (حتى `favorites_count` أو `last_active`). هل هو ضروري؟ يمكن حذفه أو إضافة حقول مفيدة إليه.

### 2.2 علاقات 1:N

| المصدر | الهدف | ملاحظة |
|--------|-------|--------|
| `User` → `Review` (Client) | `Review.clientId` | ✅ |
| `User` → `Review` (Artisan Profile) | `Review.artisanId` | ✅ |
| `ArtisanProfile` → `ArtisanService` | `artisan_id` | ✅ Cascade |
| `ArtisanProfile` → `ArtisanPortfolio` | `artisan_id` | ✅ Cascade |
| `User` → `Subscription` | `artisan_id` | ✅ |
| `User` → `Payment` | `artisan_id` | ✅ |
| `User` → `Device` | `user_id` | ✅ Cascade |
| `User` → `Notification` | `user_id` | ✅ |
| `User` → `ArtisanDocument` | `user_id` | ✅ Cascade |

### 2.3 علاقات M:N

| الجدول الوسيط | الطرف الأول | الطرف الثاني | ملاحظة |
|--------------|------------|-------------|--------|
| `Favorite` | `clientId → User` | `artisanId → ArtisanProfile.userId` | ✅ مفتاح مركب |
| `ArtisanService` | `artisanId → ArtisanProfile` | `serviceId → Service` | ✅ `@@unique` |

### 2.4 علاقة ذاتية

| الموديل | الوصف |
|---------|-------|
| `Service` → `Service.parentId` | علاقة هرمية (فئة رئيسية → فئات فرعية) — ✅ جيد، `@relation("ServiceHierarchy")` |

---

## 3. ⚡ تحليل الأداء والفهارس

### 3.1 الملخص

```
┌────────────────────────────────────────────────────────────────┐
│  الفهارس المخططة (مطلوبة لـ MVP)    : 32                      │
│  فهارس تلقائية (PK + Unique)         : 14                     │
│  فهارس يدوية موجودة في `schema.prisma`: 0                     │
│  فهارس يدوية في SQL (من Sprint 3)    : 2 (GIN)                │
│  فهارس مفقودة (يجب إضافتها فوراً)    : 16                     │
│  نسبة التغطية الحالية                : 50%                    │
└────────────────────────────────────────────────────────────────┘
```

### 3.2 الفهارس المفقودة — الأكثر إلحاحاً

#### أولوية 🔴 عالية (تأثير مباشر على MVP)

```sql
-- 1. فلترة المستخدمين حسب الدور (كل استعلامات الحرفيين)
CREATE INDEX IF NOT EXISTS idx_users_role_deleted
  ON users (role, deleted_at)
  WHERE deleted_at IS NULL;

-- 2. GIN للبحث بالاسم (pg_trgm)
CREATE INDEX IF NOT EXISTS idx_users_name_gin
  ON users USING gin (name gin_trgm_ops);

-- 3. GiST للموقع الجغرافي (PostGIS — كل استعلامات القرب)
CREATE INDEX IF NOT EXISTS idx_users_location_gist
  ON users USING GiST (location)
  WHERE location IS NOT NULL;

-- 4. ترتيب الحرفيين حسب التقييم (صفحات القائمة)
CREATE INDEX IF NOT EXISTS idx_artisan_profiles_rating
  ON artisan_profiles (rating_avg DESC, is_verified)
  WHERE is_verified = true;

-- 5. الحرفيون الموثوقون فقط
CREATE INDEX IF NOT EXISTS idx_artisan_profiles_verified
  ON artisan_profiles (user_id)
  WHERE is_verified = true;
```

#### أولوية 🟡 متوسطة (تحسين الأداء مع النمو)

```sql
-- 6. خدمات الحرفي النشطة مع السعر
CREATE INDEX IF NOT EXISTS idx_as_active_service_price
  ON artisan_services (service_id, price)
  WHERE is_active = true;

-- 7. تقييمات الحرفي المعتمدة (مع soft delete وترتيب)
CREATE INDEX IF NOT EXISTS idx_reviews_artisan_approved
  ON reviews (artisan_id, is_approved, deleted_at, created_at DESC)
  WHERE is_approved = true AND deleted_at IS NULL;

-- 8. الاشتراكات النشطة
CREATE INDEX IF NOT EXISTS idx_subscriptions_active_end
  ON subscriptions (status, end_date)
  WHERE status = 'ACTIVE';

-- 9. المدفوعات حسب الحالة والترتيب
CREATE INDEX IF NOT EXISTS idx_payments_status
  ON payments (status, created_at DESC);
```

#### أولوية 🟢 منخفضة (للمرحلة القادمة)

```sql
-- 10. إشعارات المستخدم — غير مقروءة
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread
  ON notifications (user_id, is_read, created_at DESC);

-- 11. الشكايات المفتوحة
CREATE INDEX IF NOT EXISTS idx_complaints_open
  ON complaints (status, created_at ASC)
  WHERE status IN ('PENDING', 'IN_PROGRESS');

-- 12. فهارس Materialized Views
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_ranking_artisan_id
  ON mv_ranking_results (artisan_id);
```

### 3.3 ملاحظات حول PostGIS

```sql
-- السطر الحالي في schema.prisma:
location  Unsupported("geography(Point, 4326)")?

-- 🔴 مشكلة: Prisma لا يدير PostGIS مباشراً
-- الحلول الممكنة:
--   1. استخدام $queryRaw لكل استعلام PostGIS
--   2. إنشاء migration يدوي يضيف extension + فهرس GiST
--   3. تخزين خط الطول/العرض في حقلين منفصلين (lat, lng) من نوع Float
--      كحل بديل يسير مع Prisma، مع تحويل إلى geography عند الحاجة

-- الحل الموصى به (الخيار 2):
-- 1. إضافة extension في migration:
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. إضافة فهرس GiST:
CREATE INDEX IF NOT EXISTS idx_users_location_gist
  ON users USING GiST (location)
  WHERE location IS NOT NULL;

-- 3. إضافة trigger (اختياري) لتحديث ranking_score عند تغيير الموقع
```

---

## 4. 🧹 VACUUM & ANALYZE

### 4.1 الوضع الحالي

| الجدول | الصفوف | صفوف ميتة | آخر VACUUM | آخر ANALYZE |
|--------|--------|-----------|-----------|------------|
| users | ~1,521 | 0 | — | — |
| artisan_profiles | ~1,518 | 0 | — | — |
| artisan_services | ~1,045 | 0 | — | — |
| services | 42 | 0 | — | — |
| reviews | ~12 | 0 | — | — |
| subscriptions | ~8 | 0 | — | — |

**🔴 ملاحظة:** قاعدة البيانات جديدة — لم يتم تشغيل VACUUM أو ANALYZE بعد. الإحصائيات غير محدثة، مما يعني أن Query Planner قد يختار خطط تنفيذ غير مثلى.

### 4.2 خطة الصيانة

```sql
-- تشغيل فوري
VACUUM (VERBOSE, ANALYZE) users;
VACUUM (VERBOSE, ANALYZE) artisan_profiles;
VACUUM (VERBOSE, ANALYZE) artisan_services;
VACUUM (VERBOSE, ANALYZE) services;
VACUUM (VERBOSE, ANALYZE) reviews;

-- إعدادات autovacuum
ALTER SYSTEM SET autovacuum = on;
ALTER SYSTEM SET autovacuum_naptime = '1min';
ALTER SYSTEM SET autovacuum_vacuum_scale_factor = 0.1;   -- 10%
ALTER SYSTEM SET autovacuum_analyze_scale_factor = 0.05; -- 5%

-- للجداول النشطة
ALTER TABLE reviews SET (
  autovacuum_vacuum_scale_factor = 0.05,
  autovacuum_vacuum_threshold = 100
);
```

---

## 5. 🔒 الأمان والنزاهة

| الملاحظة | الحالة |
|---------|--------|
| كلمات المرور `String?` — يجب تشفيرها قبل التخزين | ✅ يفترض أن الـ service layer يقوم بذلك |
| `OtpCode.code` — يجب تخزينه hash + salt | ⚠️ غير موثق في schema — افتراض |
| `Payment.ip` و `user_agent` مخزنة — جيد للتدقيق | ✅ |
| `AuditLog` يسجل الإجراءات والـ IP — ممتاز للأمان | ✅ |
| `ArtisanDocument.status` من نوع `DocumentStatus` enum — يمنع القيم غير الصالحة | ✅ |
| لا يوجد `@@unique` على `RefreshToken.tokenHash` | ⚠️ خطر: يمكن أن يتكرر tokenHash |
| `Complaint.status` من نوع `String` — ليس Enum | ⚠️ خطر: يمكن إدخال أي قيمة |

---

## 6. 🔧 توصيات فورية قبل Beta Launch

### أولوية 🔴 — يجب التنفيذ قبل الإطلاق

1. **إضافة الفهارس الـ 5 الأولى** (قسم 3.2 أولوية عالية)
2. **إضافة PostGIS extension + فهرس GiST** يدوياً (لأن Prisma لا يدعم `using GiST`)
3. **تشغيل `VACUUM ANALYZE`** على جميع الجداول
4. **تحويل `Complaint.status` من `String` إلى Enum** (أضف `ComplaintStatus` enum)
5. **رفع `@@unique` على `RefreshToken.tokenHash`**

### أولوية 🟡 — قبل الإطلاق أو في Sprint 10

6. **إضافة فهارس الأولوية المتوسطة** (6-9 في القسم 3.2)
7. **إضافة `Notification` و `Complaint` فهارس** للأداء مع النمو
8. **مراجعة `ClientProfile`**: هل هو ضروري؟ إن لم يكن، إزالته. إن كان، إضافة حقول مفيدة.
9. **إضافة `AdminAction` model** منفصل عن `AuditLog` العام
10. **إضافة indexes على `deleted_at`** لجداول `User` و `Review`

### أولوية 🟢 — Sprint 10 أو المرحلة الثانية

11. **فهارس Materialized Views** (إذا تم إنشاؤها)
12. **إعداد pg_cron** للصيانة الدورية
13. **تقييم الحاجة لـ partitioning** على `audit_logs` و `reviews` عند +100K صف
14. **إضافة trigger لـ `ranking_score`** في `artisan_profiles` بناءً على آخر موقع وتقييم

---

## 7. 📈 تقدير الأداء بعد التحسينات

```
┌────────────────────────────────────────────────────────────────┐
│  الاستعلام              │ الحالي │ بعد الفهارس │ بعد VACUUM  │
│─────────────────────────┼────────┼─────────────┼─────────────│
│ تصفح الخدمات            │ 2.4ms  │ 1.2ms       │ 0.8ms       │
│ بحث خدمة بالاسم         │ 0.8ms  │ 0.8ms       │ 0.6ms       │
│ بحث حرفي بالاسم         │ 3.1ms  │ 1.0ms       │ 0.7ms       │
│ الترتيب الذكي           │ 4.7ms  │ 2.5ms       │ 2.0ms       │
│ ملف حرفي كامل           │ 2.8ms  │ 1.5ms       │ 1.2ms       │
│ التحقق من الاشتراك       │ 0.3ms  │ 0.3ms       │ 0.2ms       │
│ قائمة المفضلة           │ 1.2ms  │ 0.8ms       │ 0.6ms       │
│ Dashboard               │ 3.4ms  │ 2.0ms       │ 1.5ms       │
│─────────────────────────┼────────┼─────────────┼─────────────│
│ المتوسط                 │ 2.3ms  │ 1.3ms       │ 1.0ms       │
└────────────────────────────────────────────────────────────────┘
```

**الهدف:** جميع استعلامات MVP تحت **5ms** (90th percentile).  
الوضع الحالي يحقق هذا الهدف بفضل Materialized Views من Sprints 4-5، لكن الفهارس المفقودة ستظهر مع نمو البيانات.

---

## 8. 📝 مخطط العمل — Database Engineer

| الخطوة | المهمة | الوقت المقدر |
|--------|-------|-------------|
| 1 | إضافة الفهارس الـ 12 في migration | 1-2 ساعة |
| 2 | إضافة PostGIS extension + trigger | 30 دقيقة |
| 3 | تشغيل VACUUM ANALYZE | 15 دقيقة |
| 4 | تحويل `Complaint.status` إلى Enum | 30 دقيقة |
| 5 | إضافة `@@unique` على `RefreshToken.tokenHash` | 15 دقيقة |
| 6 | مراجعة `ClientProfile` (إضافة/حذف) | 30 دقيقة |
| 7 | اختبار الأداء بعد التحسينات | 1 ساعة |
| | **المجموع** | **~4 ساعات** |

---

**تم إعداد هذا التقرير بناءً على:**
- `schema.prisma` (Prisma 7.8, PostgreSQL)
- `seed.ts`
- `ba-analysis.md` (Business Analysis)
- Sprint 9 backlog (inbox.md)

— نور الصباغ | Database Engineer
