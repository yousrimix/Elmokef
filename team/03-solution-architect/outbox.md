# 📬 Outbox — مهندس (Solution Architect Agent)

**تاريخ:** 18 يونيو 2026  
**المرحلة:** Sprint 9 — ما قبل الإطلاق  
**الحالة:** مكتمل — architecture-review.md جاهز

---

## ✅ المنجز

### 1. تقييم معماري شامل
تم حفظ التقييم في `architecture-review.md` ويغطي 11 محوراً:

| المحور | النتيجة |
|--------|---------|
| Scalability | 🟡 جيد — Read Replica مطلوب قبل الإطلاق |
| Security | 🟢 قوي — ينقص PenTest و Rate Limiting |
| Database Design | 🟢 ممتاز — PostGIS + Prisma |
| API Design | 🟢 جيد — GraphQL يُرجى تأجيله لـ Phase 2 |
| State Management | 🟢 جيد — ينقص Offline Layer |
| CMI Payment Flow | 🟡 متوسط — Idempotency أساسي |
| Infrastructure | 🟡 جيد — Healthcheck + Backup |

**النتيجة النهائية:** 82/100 — جاهز مع 8 إجراءات إلزامية

### 2. المستندات التي تمت مراجعتها
- `project-brief.md` — سجل الفكرة
- `ba-analysis.md` — تحليل سارة (BA)
- `discussion-phase2.md` — وثيقة د. أحمد النجار (Architecture)
- `poc-osm-ranking-report.md` — PoC الخرائط + Ranking Engine
- `roadmap.md` — خريطة الطريق (Sprint 1–10)
- `docker-compose.yml` — البنية التحتية الحالية

### 3. المصادر التي تم الاطلاع عليها
- المسار الرئيسي: `E:\charika\`
- فريق الـ Solution Architect: `team\03-solution-architect\`
- الـ Roadmap: `project-elmokef\roadmap.md`
- Docker Compose: `backend\docker-compose.yml`

---

## 📋 الإجراءات الإلزامية قبل الإطلاق (P0)

| # | الإجراء | لماذا | المسؤول |
|---|---------|-------|---------|
| 1 | **Idempotency Key للمدفوعات** | يمنع تكرار الدفع من WebHook CMI | محمد (Backend) |
| 2 | **Read Replica PostgreSQL** | يمنع عنق الزجاجة مع 1,000+ مستخدم | ياسر (DevOps) |
| 3 | **PenTest OWASP ASVS Level 2** | غير مفحوص — خطر اختراق | فيصل + رنا |
| 4 | **Rate Limiting لكل Endpoint** | يحمي من Spam والإساءة | محمد |
| 5 | **Healthcheck في docker-compose** | يضمن توفر الخدمات بعد إعادة التشغيل | ياسر |
| 6 | **Backup Strategy (pg_dump + Point-in-time)** | يضمن استرجاع البيانات في أقل من 4 ساعات | ياسر + نور |

## 📋 الإجراءات الموصى بها بقوة (P1)

| # | الإجراء | المسؤول |
|---|---------|---------|
| 7 | إلغاء GraphQL من MVP — استخدم REST للإحصائيات المؤقتة | محمد |
| 8 | Offline-first Layer — Hive Cache للفئات والخدمات | خالد |
| 9 | Payment Retry Queue عبر BullMQ | محمد |
| 10 | SFSafariViewController + Chrome Custom Tabs بدلاً من WebView | خالد |
| 11 | Standard Error Response Schema (ApiErrorResponse) | محمد |
| 12 | تفعيل Crashlytics + Firebase Performance فوراً | خالد |
| 13 | Subscription History جدول | نور |
| 14 | Staging Environment + GitHub Actions workflow | ياسر |

---

## ⚠️ مخاطر تم رصدها

| رمز | المخاطرة | الحل |
|-----|---------|------|
| CR-01 | CMI Idempotency — تكرار الدفع | Idempotency Key |
| CR-02 | PostGIS بدون Read Replica — اختناق مع 1,000+ مستخدم | Read Replica |
| CR-03 | لا يوجد PenTest — OWASP غير مفحوص | PenTest قبل الإطلاق |
| CR-04 | OSM غير دقيق في فاس البالي ومراكش Medina (±25m) | Google Maps Fallback |
| CR-05 | Cold Start للحرفيين الجدد | New Artisan Boost (+2.0) + Rating Fallback |
| CR-06 | Offline-first مفقود — مستخدم بدون إنترنت | Hive Cache |

---

## 📎 ملاحظات إضافية

### نقاط القوة في التصميم الحالي
1. **ClamAV** في Docker — فحص الفيروسات للملفات المرفوعة، ممارسة ممتازة
2. **RBAC مع 3 أدوار** — يغطي حالات الاستخدام الأساسية
3. **AuditLog** — سجل لجميع العمليات الحساسة
4. **Ranking Engine قابل للتعديل** — Config خارجي من Redis يسمح بتعديل الوزنات بدون إعادة نشر
5. **فصل BullMQ للـ Background Jobs** — يمنع تأثير معالجة الصور والإشعارات على API

### نقاط التحسين الطفيفة
- الـ `docker-compose.yml` لا يستخدم `.env` لكلمات المرور — تمت التوصية بالتعديل
- إصدار ClamAV `latest` — الأفضل تحديد إصدار ثابت (مثل `1.0.4`) لمنع الكسر المفاجئ
- لا يوجد `depends_on` في Compose — PostgreSQL و Redis لا ينتظران بعضهما

---

## 🔜 الخطوة التالية

الملف جاهز لـ:
1. عرضه على الفريق في اجتماع Sprint 9 Kickoff
2. توزيع المهام (الإجراءات الإلزامية أولاً)
3. المراجعة مع د. أحمد النجار لاعتماد التوصيات

---
*تم الإعداد بواسطة مهندس — Solution Architect Agent*
*التقييم يستند إلى الملفات الموجودة وأفضل الممارسات للـ Systems Design*
