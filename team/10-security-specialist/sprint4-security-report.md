# تقرير أمني — Artisan Module (Sprint 4)

**المعد:** فيصل المطيري — Security Specialist (CISSP, CEH)  
**المشروع:** Elmokef  
**التاريخ:** 17 يونيو 2026  
**النسخة:** v1.0  
**المراجع:** `team/06-backend-developer/inbox.md`, `ba-analysis.md` (US-12 → US-15)

---

## ملخص تنفيذي

| المجال | التقييم |
|--------|---------|
| رفع الملفات | 🟡 متوسط — أساسيات قوية لكن ينقصها ClamAV + تشفير + EXIF |
| Artisan API | 🟢 جيد — ملكية البيانات + Guards |
| الثغرات | 2 🔴 + 3 🟡 + 2 🟢 |

---

## 1. مراجعة أمن رفع الملفات

### 1.1 المطبق حالياً
| الإجراء | الحالة |
|---------|--------|
| MIME validation (Multer + Service) | ✅ |
| حجم أقصى 5MB | ✅ |
| Sharp resize 1920px max | ✅ |
| Thumbnail 150×150 WebP 70% | ✅ |
| حذف الملف الفعلي عند حذف الصورة | ✅ |
| Soft-delete للخدمات | ✅ |

### 1.2 الثغرات

| # | الثغرة | المستوى | التوصية |
|---|--------|---------|---------|
| **FU-01** | **🔴 لا فحص مضاد فيروسات (ClamAV).** أي ملف ضار (PHP webshell, exe, script) يمكن رفعه إذا اجتاز MIME check. Backend يعمل في NestJS (Node.js) — الملفات الضارة تُخدم كـ static files وقد تُنفذ. | 🔴 خطر | إضافة ClamAV scan عبر `clamscan` أو خدمة سحابية (VirusTotal API). رفض أي ملف بنتيجة إيجابية. تطبيق scan قبل save. |
| **FU-02** | **🔴 `POST /api/v1/upload` بدون مصادقة.** أي شخص — حتى غير مسجل — يمكنه رفع ملفات. هذا يفتح باب هجوم Storage Exhaustion ورفع محتوى غير قانوني باسم المنصة. | 🔴 خطر | إضافة `JwtAuthGuard` + `@Roles(ARTISAN)` على الأقل. تحديد max uploads لكل مستخدم (مثلاً 50 ملف/يوم). |
| **FU-03** | **🟡 لا تشفير للوثائق الحساسة (ArtisanDocuments).** صور الهوية (CIN, passport) تُخزن على القرص بدون تشفير. إذا تم اختراق السيرفر أو S3، الوثائق مكشوفة بالكامل. | 🟡 متوسط | تشفير AES-256-GCM للملفات الحساسة قبل التخزين. استخدام envelope encryption (KMS) في Production. فك التشفير فقط عند الطلب من Admin. |
| **FU-04** | **🟡 Auto-deletion بعد 90 يوماً غير مطبق.** وثائق الحرفيين ستبقى إلى الأبد — مخالفة للقانون المغربي 09-08 (حق النسيان). | 🟡 متوسط | إضافة BullMQ Job (Cron) يحذف ArtisanDocuments بعد 90 يوماً من verification. إضافة `scheduled_deletion_date` في Schema. |
| **FU-05** | **🟡 EXIF data و metadata غير مُجرّدة.** صور الهواتف تحتوي على GPS coordinates, device info, timestamp. تسريب هذه البيانات يخرق خصوصية المستخدمين. | 🟡 متوسط | استخدام Sharp `withMetadata(false)` لحذف EXIF. إضافة `sharp({ pages: -1 }).jpeg()` لتحويل كل الصور إلى JPEG نظيف. |
| **FU-06** | **🟢 Static file serving (`/uploads/*`).** إذا تمت خدمة الملفات من نفس domain التطبيق، قد يكون هناك Path Traversal (مثلاً `/uploads/../../etc/passwd`). | 🟢 منخفض | استخدام `express.static('uploads')` مع `dotfiles: 'deny'`. أو الأفضل: خدمة الملفات عبر subdomain منفصل (cdn.elmokef.ma). |
| **FU-07** | **🟢 لا Rate Limiting على رفع الملفات.** مهاجم يمكنه رفع آلاف الملفات لملء التخزين واستنزاف الموارد. | 🟢 منخفض | تطبيق Rate Limiting مخصص للرفع: 10 رفع/دقيقة/مستخدم. و 20MB/دقيقة/مستخدم حد للحجم الإجمالي. |

---

## 2. مراجعة Artisan API

### 2.1 المطبق حالياً
| الإجراء | الحالة |
|---------|--------|
| JwtAuthGuard على protected endpoints | ✅ |
| RolesGuard (ARTISAN) | ✅ |
| التحقق من ملكية الحساب (`req.user.userId === id`) | ✅ |
| Soft-delete للخدمات | ✅ |
| حذف الملف الفعلي مع الصورة | ✅ |

### 2.2 الثغرات

| # | الثغرة | المستوى | التوصية |
|---|--------|---------|---------|
| **API-01** | **🟡 `GET /api/v1/artisans/:id` عام بدون فلترة للحقول.** العميل يرى كل شيء — بما في ذلك بيانات قد تكون داخلية (مثل `subscription_id`, `is_active`, `fcm_token`). | 🟡 متوسط | إنشاء ArtisanPublicDTO يحوي فقط: name, bio, profile_image, services, portfolio, rating_avg, response_time, city. عدم إرجاع: fcm_token, subscription_id, is_active, وثائق. |
| **API-02** | **🟡 `GET /api/v1/artisans` (بحث عام) يعرض حرفيين غير نشطين.** إذا كان الحرفي موقوفاً (is_active=false)، لا يجب أن يظهر في نتائج البحث. | 🟡 متوسط | إضافة `WHERE is_active = true` في query البحث. إضافة `verified_at IS NOT NULL` (الحرفي غير الموثق لا يظهر في البحث). |
| **API-03** | **🟡 التحقق من الملكية: `req.user.userId === id`.** هذا يمنع ARTISAN من تعديل بيانات غيره ✅، لكن ماذا عن ADMIN؟ ADMIN يجب أن يتمكن من تعديل أي حرفي. | 🟡 تحسين | إضافة شرط: المسموح إذا كان ADMIN أو مالك الحساب. `if (req.user.role !== 'ADMIN' && req.user.userId !== id) → 403`. |
| **API-04** | **🟢 المدخلات النصية (bio, description) بدون Sanitize.** XSS attack عبر إدخال `<script>` في bio الحرفي — ينفذ عند عرض الملف. | 🟢 منخفض | استخدام `sanitize-html` على الحقول النصية قبل الحفظ. تفعيل `Content-Security-Policy` header لمنع تنفيذ inline scripts. |
| **API-05** | **🟢 IDOR (Insecure Direct Object Reference).** `DELETE /api/v1/artisans/:id/portfolio/:mediaId` — يجب التأكد من أن mediaId يعود للحرفي نفسه وليس لغيره. | 🟢 استفسار | التأكد من التحقق من ملكية الصورة: `where: { id: mediaId, artisanId: req.user.userId }` في Prisma query. |

---

## 3. قائمة التحقق

### 3.1 ✅ معتمد
- [x] MIME validation قبل Multer + مراجعة في Service
- [x] Sharp image processing مع resize + WebP
- [x] حذف الملف الفعلي عند DELETE
- [x] Soft-delete للخدمات (isActive=false)
- [x] JwtAuthGuard على جميع protected endpoints
- [x] RolesGuard للتحقق من دور ARTISAN
- [x] التحقق من ملكية الحساب (userId === id)
- [x] Thumbnail generation 150×150

### 3.2 ❌ يحتاج معالجة فورية
- [ ] ClamAV scan قبل حفظ الملفات (#FU-01)
- [ ] مصادقة على upload endpoint (#FU-02)
- [ ] تشفير وثائق الحرفيين (#FU-03)
- [ ] فلترة ArtisanPublicDTO (#API-01)

### 3.3 ⚠️ يحتاج جدولة
- [ ] Auto-deletion 90 يوماً (#FU-04)
- [ ] EXIF stripping (#FU-05)
- [ ] Rate Limiting رفع الملفات (#FU-07)
- [ ] XSS Sanitize (#API-04)
- [ ] IDOR check (#API-05)

---

## 4. خطة المعالجة

### عاجل (قبل Sprint 5)
| P | المهمة | المدة | المسؤول |
|---|--------|-------|---------|
| P0 | إضافة ClamAV scan في UploadService | 1 يوم | Mohammed |
| P0 | إضافة JwtAuthGuard على upload endpoint | 0.5 يوم | Mohammed |
| P1 | تشفير AES-256 للوثائق الحساسة (ArtisanDocuments) | 1.5 يوم | Mohammed |
| P1 | إنشاء ArtisanPublicDTO وحصره بالحقول العامة | 0.5 يوم | Mohammed |

### المدى القصير (Sprint 5)
| P | المهمة | المدة |
|---|--------|-------|
| P1 | EXIF stripping (Sharp withMetadata(false)) | 0.5 يوم |
| P2 | Auto-deletion job (BullMQ cron 90 يوم) | 1 يوم |
| P2 | XSS sanitize على bio/description | 0.5 يوم |
| P2 | Rate Limiting رفع الملفات | 0.5 يوم |
| P2 | تقوية IDOR check في Prisma query | 0.5 يوم |

---

## 5. الخلاصة

التنفيذ الأساسي قوي (MIME validation, Ownership check, Guards). لكن ثغرة **عدم فحص الفيروسات (#FU-01)** و **عدم مصادقة upload endpoint (#FU-02)** خطيرتان بما يكفي لتعطيل Sprint 5 حتى المعالجة.

**التوصية:** معالجة P0-P1 قبل الانتقال لـ Sprint 5 (تقدير 3.5 أيام).

— فيصل المطيري | Security Specialist  
`/signed/fsal-mutairi-2026-06-17-sprint4-artisan/`
