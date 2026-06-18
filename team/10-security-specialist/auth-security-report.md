# تقرير أمني — Auth Module (Sprint 2)

**المعد:** فيصل المطيري — Security Specialist (CISSP, CEH)  
**المشروع:** Elmokef  
**التاريخ:** 17 يونيو 2026  
**النسخة:** v1.0  
**الحالة:** 🔴 يحتاج معالجة قبل الانتقال لـ Sprint 3

---

## ملخص تنفيذي

تمت مراجعة تنفيذ Auth Module من Mohammed Al-Ali بناءً على:
- `team/06-backend-developer/inbox.md` — API endpoints المنفذة
- `team/03-solution-architect/discussion-phase2.md` — البنية المعمارية
- `team/10-security-specialist/discussion-phase2.md` — المخاوف الأمنية المسجلة مسبقاً

**النتيجة:** 7 ثغرات (2 خطيرة، 3 متوسطة، 2 منخفضة) + 8 توصيات تحسينية.

| المستوى | العدد |
|---------|-------|
| 🔴 خطر | 2 — OAuth token verification + Role escalation via register |
| 🟡 متوسط | 3 — OTP exposed in dev, Body-based refresh token, CSRF |
| 🟢 منخفض | 2 — Password policy, JWT secret rotation |

---

## 1. مراجعة JWT

### 1.1 التصميم المطبق
| المكون | القيمة | الحالة |
|--------|--------|--------|
| Access Token Expiry | 15 دقيقة | ✅ مناسب |
| Refresh Token Expiry | 7 أيام | ✅ مناسب |
| Refresh Storage | HttpOnly Cookie (sameSite:strict, Secure) | ✅ ممتاز |
| Refresh Token Rotation | إبطال القديم + إصدار جديد مع كل استخدام | ✅ ممتاز |
| Token Hashing | SHA-256 للتخزين | ✅ ممتاز |
| Logout | إبطال جميع Refresh Tokens للمستخدم | ✅ ممتاز |

### 1.2 الثغرات والتوصيات — JWT

| # | الثغرة | المستوى | التوصية |
|---|--------|---------|---------|
| **JWT-01** | `POST /auth/refresh` يقبل Refresh Token من **Body أو Cookie**. قبوله من Body يعرض المستخدم لسرقة التوكن عبر XSS إذا كان هناك أي vector (حتى بسيط). | 🟡 متوسط | إزالة دعم Body بالكامل. Cookie فقط مع `httpOnly: true, secure: true, sameSite: 'strict'`. |
| **JWT-02** | لا يوجد CSRF protection. استخدام Cookie للمصادقة بدون CSRF token يسمح بتنفيذ طلبات عبر المواقع الضارة (مثل logout). | 🟡 متوسط | تطبيق CSRF token (Double Submit Cookie pattern) أو استخدام `sameSite: 'lax'` بدلاً من `strict` على الـ auth cookie (مع تقييم المخاطر). |
| **JWT-03** | لا توجد استراتيجية لتدوير Secret Key (JWT signing secret). إذا تسرب الـ secret، جميع التوكنات سابقة وقابلة للإصدار. | 🟢 منخفض | تطبيق Key Rotation: استخدام JWKS endpoint أو تخزين secret versioned مع فترة صلاحية (مثلاً 90 يوماً). إبطال جميع التوكنات عند التبديل. |
| **JWT-04** | لم يُحدد إذا كان الـ JWT يحتوي على `jti` (JWT ID). بدون jti، لا يمكن إبطال Access Token فردي (لا يمكن تطبيق logout على مستوى access token). | 🟢 منخفض | إضافة `jti` (UUID v4) لكل Access Token. تخزين الـ jti في Redis مع TTL مساوٍ لصلاحية التوكن. إبطال الـ jti عند logout. |
| **JWT-05** | لم يُذكر خوارزمية JWT. خوارزمية `none` أو `HS256` الضعيفة قد تُستخدم في هجمات Algorithm Confusion. | 🟢 استفسار | تأكيد استخدام **RS256** (RSA) أو **ES256** (ECDSA). حظر خوارزمية `none`. استخدام `jsonwebtoken` مع `algorithms` explicit list. |

---

## 2. مراجعة RBAC

### 2.1 التصميم المطبق
- 3 أدوار: `CLIENT`, `ARTISAN`, `ADMIN`
- `RolesGuard` + `@Roles(ArtisanRole.ADMIN)` decorator
- تسجيل دور تلقائي مع إنشاء `ClientProfile` / `ArtisanProfile`

### 2.2 الثغرات والتوصيات — RBAC

| # | الثغرة | المستوى | التوصية |
|---|--------|---------|---------|
| **RBAC-01** | **🔴 POST /auth/register يقبل `role?` اختياري.** هذا يسمح لأي مستخدم بتسجيل حساب بدور ADMIN إذا لم يتم التحقق من صحة الدور على Backend. ثغرة OWASP A1 (Broken Access Control). | 🔴 خطر | حظر تسجيل دور ADMIN عبر API نهائياً. السماح فقط بـ `CLIENT` و `ARTISAN` عند التسجيل. إنشاء ADMIN عبر Seeder خاص أو أمر Console فقط. التحقق من `role` ضد قائمة بيضاء صارمة. |
| **RBAC-02** | عدم وجود Hierarchical Roles. كل دور معزول — ADMIN لا يرث صلاحيات CLIENT. هذا قد يسبب مشاكل إذا احتاج ADMIN لأداء وظائف CLIENT للاختبار. | 🟢 تحسين | إضافة `role hierarchy` (ADMIN > ARTISAN > CLIENT) مع إمكانية التجاوز في RolesGuard. |
| **RBAC-03** | عدم وجود Permission-based Authorization (Fine-grained). `@Roles(ArtisanRole.ADMIN)` يعطي ADMIN جميع الصلاحيات — لا يمكن تقييد وصول ADMIN إلى موارد محددة. | 🟡 تحسين | تطبيق `@Permissions()` decorator إضافي مع PermissionGuard. مثال: `@Permissions('users:delete')` مع PermissionsGuard. |
| **RBAC-04** | عدم التحقق من أن ARTISAN لا يمكنه تعديل ملف CLIENT والعكس. يجب اختبار أن `GET /auth/profile` يُرجع فقط بيانات المستخدم نفسه. | 🟡 استفسار | تأكيد أن JwtAuthGuard يتحقق من `userId` من JWT ويمنع الوصول cross-role. |

---

## 3. مراجعة OAuth (Google + Facebook)

### 3.1 التصميم المطبق
- تكامل OAuth عبر Firebase Auth
- Endpoint: `POST /auth/oauth` يستقبل (provider, token, email?)
- تمرير token من العميل إلى Backend الذي يتواصل مع Firebase

### 3.2 الثغرات والتوصيات — OAuth

| # | الثغرة | المستوى | التوصية |
|---|--------|---------|---------|
| **OAUTH-01** | **🔴 لم يُذكر التحقق من Firebase ID Token على Backend.** إذا لم يتم التحقق من صحة التوكن، يمكن للمهاجم تمرير أي token (أو token منتهي الصلاحية) لإنشاء جلسة مزيفة. Backend يجب ألا يثق بما يرسله العميل مباشرة. | 🔴 خطر | استخدام `admin.auth().verifyIdToken(token)` للتحقق من Firebase ID Token على Backend قبل إنشاء/تحديث المستخدم. التحقق من `aud` (App ID) و `iss` و `exp`. |
| **OAUTH-02** | `email?` اختياري في الـ endpoint — قد لا يكون متاحاً من Firebase. إذا لم يكن موجوداً، كيف سيتم ربط الحساب مع OAuth؟ | 🟡 استفسار | استخدام `firebaseUid` (Firebase User ID) كمعرّف أساسي في جدول Users، مع `email` كحقل إضافي يُسحب من Firebase verified email. |
| **OAUTH-03** | Account Linking. إذا سجل مستخدم بـ Email/Password ثم حاول تسجيل الدخول بـ Google (نفس البريد)، ماذا يحدث؟ | 🟡 تحسين | التحقق من وجود البريد الإلكتروني مسبقاً. إذا موجود، ربط Firebase UID مع الحساب الحالي (Link accounts). |
| **OAUTH-04** | لم يُذكر `state` parameter في تدفق OAuth. هذا يعرّض لـ CSRF attack على OAuth callback. | 🟢 تحسين | تطبيق OAuth state parameter (PKCE) لمنع CSRF في تدفق OAuth. |

---

## 4. مراجعة حماية Endpoints

### 4.1 التصميم المطبق
- Rate Limiting: 10 محاولات/دقيقة للتسجيل
- Account Lockout: بعد 5 محاولات فاشلة
- جميع الـ Auth endpoints ما عدا `/profile` غير محمية بـ JWT (حقاً، لأنها نقاط تسجيل/دخول)

### 4.2 الثغرات والتوصيات — Endpoint Protection

| # | الثغرة | المستوى | التوصية |
|---|--------|---------|---------|
| **EP-01** | **Rate Limiting مطبق فقط على التسجيل.** Login, OTP send, OTP verify ليس لديهم Rate Limiting. هذا يسمح بهجمات Brute Force على login و Enumeration على OTP. | 🟡 متوسط | تطبيق Rate Limiting على جميع Auth endpoints: Login (10/dقيقة/IP), OTP Send (3/dقيقة/رقم), OTP Verify (5/dقيقة/IP). |
| **EP-02** | **Account Lockout بعد 5 محاولات فاشلة فقط — بدون إشعار للمستخدم.** المستخدم لا يعرف أن حسابه مقفل، وقد يظن أن الخدمة معطلة. | 🟡 متوسط | إضافة إشعار (Email/SMS) للمستخدم عند قفل الحساب: "تم قفل حسابك مؤقتاً بسبب 5 محاولات دخول فاشلة. سيتم فتحه خلال 15 دقيقة." |
| **EP-03** | إرسال OTP (`POST /auth/otp/send`) بدون Rate Limiting مخصص للرقم. المهاجم يمكنه إغراق رقم هاتف المستخدم برسائل OTP (SMS bombing). | 🟡 متوسط | Rate Limiting: 3 OTP/ساعة/رقم هاتف. 5 OTP/ساعة/IP. Cooldown بين كل إرسال: 60 ثانية. |
| **EP-04** | **حلياً الـ OTP يعيد الكود في الـ Response للتطوير.** هذا خطر أمني حتى في التطوير — قد يتسرب الكود إلى logs, monitoring, أو error tracking. | 🟡 خطر | استخدام خدمة SMS حقيقية حتى في بيئة التطوير (مع Sandbox/Test mode). أو إنشاء `.env` flag `OTP_DEV_MODE` يُظهر الكود فقط في terminal ولا يُرجعه في API Response. |
| **EP-05** | Account Lockout: هل ينطبق فقط على `login` أم أيضاً على `otp/verify`؟ التحقق من OTP 5 مرات فاشلة يجب أن يقفل OTP verification وليس حساب المستخدم. | 🟡 استفسار | Lockout منفصل لـ OTP verification (5 محاولات خاطئة → حظر OTP لمدة 30 دقيقة). Lockout لحساب المستخدم فقط عبر login (5 محاولات → حظر 15 دقيقة). |

---

## 5. ثغرات عامة

| # | الثغرة | المستوى | التوصية |
|---|--------|---------|---------|
| **GEN-01** | لا توجد سياسة لكلمة المرور (Password Policy). bcrypt يستخدم لكن بدون minimum length أو complexity requirements. | 🟢 منخفض | تطبيق: minimum 8 characters, يجب أن تحتوي على حرف كبير وحرف صغير ورقم. استخدام `class-validator` مع `@MinLength(8)` و custom validator. |
| **GEN-02** | لا يوجد Forgot Password / Reset Password flow. إذا نسي المستخدم كلمته، لا توجد طريقة لاستعادتها. | 🟡 تحسين | إضافة `POST /auth/forgot-password` (إرسال رابط إعادة تعيين عبر email) و `POST /auth/reset-password` (مع reset token). |
| **GEN-03** | CORS لم يُذكر. إذا كان Frontend على domain مختلف عن Backend، الـ HttpOnly Cookie لن يعمل بدون CORS صارم. | 🟡 تحسين | تطبيق CORS مع `origin` محدد (قائمة بيضاء) و `credentials: true`. عدم استخدام `origin: '*'`. |
| **GEN-04** | Audit Logging محدود. `AuditLog` مذكور في Schema لكن هل يتم تسجيل جميع محاولات الدخول الفاشلة والناجحة؟ | 🟢 تحسين | تسجيل: كل محاولة login (ناجحة/فاشلة مع IP و User-Agent), كل OAuth login, كل OTP request. ربط AuditLog بـ SIEM (مرحلة لاحقة). |
| **GEN-05** | Security Headers لم تُذكر. بدون `helmet.js`، التطبيق عرضة لـ Clickjacking, MIME sniffing, وغيرها. | 🟢 تحسين | تطبيق `helmet()` middleware في NestJS مع: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Strict-Transport-Security: max-age=31536000`, `Content-Security-Policy`. |

---

## 6. قائمة التحقق النهائية (Checklist)

### 6.1 ✅ معتمد — مطبق بشكل آمن
- [x] Access Token: 15 دقيقة (مدة قصيرة مناسبة)
- [x] Refresh Token: 7 أيام (مناسبة للموبايل)
- [x] HttpOnly Cookie: Secure + SameSite:strict
- [x] Refresh Token Rotation: إبطال + إصدار جديد
- [x] Logout: إبطال جميع Refresh Tokens
- [x] SHA-256 لتخزين Refresh Tokens في DB
- [x] bcrypt لكلمات المرور
- [x] RolesGuard + @Roles decorator
- [x] تقسيم واضح للأدوار (CLIENT, ARTISAN, ADMIN)
- [x] OAuth عبر Firebase Auth كطبقة وسيطة

### 6.2 ❌ مرفوض — يحتاج معالجة فورية
- [ ] قبول Refresh Token في Body (يجب Cookie فقط)
- [ ] دور ADMIN متاح في `POST /auth/register` (يجب حظره)
- [ ] OAuth token غير موثّق على Backend (يجب `verifyIdToken`)

### 6.3 ⚠️ يحتاج تحسين — Sprint 2.1 أو Sprint 3
- [ ] CSRF Protection (إذا تم استخدام Cookie للمصادقة)
- [ ] JWT Key Rotation strategy
- [ ] JWT jti للإبطال الفردي
- [ ] Password Policy (min 8 chars + complexity)
- [ ] Rate Limiting على جميع Auth endpoints
- [ ] Account Lockout notification (Email/SMS)
- [ ] OTP Rate Limiting (مخصص للرقم وليس IP فقط)
- [ ] OTP في Dev mode (لا يُعاد في Response)
- [ ] Permission-based authorization (Fine-grained)
- [ ] Forgot Password flow
- [ ] CORS configuration
- [ ] Security Headers (Helmet)
- [ ] Audit Logging شامل

---

## 7. خطة المعالجة (Remediation Plan)

### عاجل (قبل Sprint 3) — 3 أيام
| الأولوية | المهمة | المسؤول | المدة |
|----------|--------|---------|-------|
| P0 | إزالة دعم `role` الاختياري من register — ADMIN فقط عبر Seeder | Mohammed | 1 يوم |
| P0 | إضافة `verifyIdToken` في OAuth endpoint | Mohammed | 1 يوم |
| P0 | إزالة OTP من Response — استخدام `OTP_DEV_MODE` env flag | Mohammed | 0.5 يوم |
| P1 | حصر Refresh Token في Cookie فقط — إزالة Body | Mohammed | 0.5 يوم |

### المدى القصير (Sprint 2.1) — 5 أيام
| الأولوية | المهمة | المسؤول | المدة |
|----------|--------|---------|-------|
| P1 | Rate Limiting على /login, /otp/send, /otp/verify | Mohammed | 1 يوم |
| P1 | Account Lockout + Email notification | Mohammed | 1.5 يوم |
| P1 | OTP Send Rate Limit (3/ساعة/رقم) | Mohammed | 0.5 يوم |
| P2 | Password Policy (class-validator) | Mohammed | 0.5 يوم |
| P2 | CSRF Protection (Double Submit Cookie) | Mohammed | 1.5 يوم |

### المدى البعيد (Sprint 3-4) — خارج Sprint 2
| المهمة | Sprint |
|--------|--------|
| JWT Key Rotation | Sprint 3 |
| Forgot Password flow | Sprint 3 |
| CORS Configuration | Sprint 3 |
| Security Headers (Helmet) | Sprint 3 |
| Permission-based Authorization | Sprint 4 |
| Audit Logging شامل | Sprint 4 |

---

## 8. اختبار الاختراق المقترح (Penetration Testing Checklist)

عند اكتمال المعالجة، يجب اختبار:

- [ ] **Injection Attacks**: SQL Injection في phone/email fields
- [ ] **Broken Authentication**: Brute force login, OTP brute force, timing attacks
- [ ] **Token Theft**: XSS stealing HttpOnly cookie, token reuse with rotation
- [ ] **Privilege Escalation**: Trying to register as ADMIN, modify other users
- [ ] **CSRF**: Cross-site request forgery on auth endpoints
- [ ] **Rate Limiting Bypass**: IP rotation, distributed attacks
- [ ] **OTP Attacks**: OTP replay, OTP enumeration, SMS bombing
- [ ] **OAuth Attacks**: Token forgery, token replay, account takeover
- [ ] **JWT Attacks**: Algorithm confusion (`none`), expired token reuse
- [ ] **Information Disclosure**: Stack traces, error messages, timing side-channels

---

## 9. الخلاصة

**التقييم العام:** التنفيذ الأساسي قوي (Refresh Token Rotation, HttpOnly Cookie, SHA-256 hashing, bcrypt). لكن الثغرات المكتشفة خطيرة بما يكفي لمنع الانتقال إلى Sprint 3 دون معالجتها.

**الثلاثة الأكثر خطورة:**
1. **OAuth token غير موثّق** — احتيال على الهوية بالكامل
2. **دور ADMIN متاح عند التسجيل** — استيلاء على المنصة
3. **OTP معاد في Response** — تسريب رموز التحقق

**التوصية النهائية:** معالجة P0/P1 قبل التوجه لـ Sprint 3. التكلفة التقديرية للمعالجة: 3-5 أيام عمل إضافية (ضمن Sprint 2 الحالي).

---

**النهاية — فيصل المطيري | Security Specialist**  
التوقيع الرقمي: `/signed/fsal-mutairi-2026-06-17-auth-sprint2/`
