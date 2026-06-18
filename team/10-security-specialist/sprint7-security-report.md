# تقرير أمني — Sprint 7: PCI-DSS Level 4 (Subscriptions & Payments)

**المعد:** فيصل المطيري — Security Specialist (CISSP, CEH)  
**المشروع:** Elmokef  
**التاريخ:** 17 يونيو 2026  
**المراجع:** `team/06-backend-developer/inbox.md` (Sprint 7)  
**المعيار:** PCI-DSS Level 4 + OWASP ASVS (Authentication & Payments)

---

## ملخص تنفيذي

**التقييم:** 🔴 لا يمكن الانتقال لـ Sprint 8 دون معالجة — يوجد ثغرة حرجة (Webhook بدون HMAC) تسمح بتفعيل الاشتراكات مجاناً.

| النطاق | العدد | أبرز ثغرة |
|--------|-------|-----------|
| 🔴 خطر | 2 | Webhook بدون HMAC + بدون IP whitelist |
| 🟡 متوسط | 4 | Idempotency ناقصة + Payment.status بدون Auth + Metadata خام |
| 🟢 منخفض | 2 | No Rate Limiting + Auto-renewal بدون إشعار |

---

## 1. مراجعة Webhook HMAC

### الوضع الحالي
- `POST /api/v1/payments/webhook` ← بدون مصادقة (CMI callback)
- No authentication mechanism mentioned

### الثغرات

| # | الثغرة | المستوى | التفاصيل | التوصية |
|---|--------|---------|----------|---------|
| **WH-01** | **🔴 لا HMAC Verification.** أي شخص يرسل request إلى هذا webhook يمكنه تفعيل اشتراكات مزيفة بدون دفع. CMI يرسل حقل `signature` أو `hmac` في callback. إذا لم يتم التحقق منه، المهاجم يستطيع POST مباشرة `{ "transactionId": "fake", "status": "success" }`. | 🔴 خطر | استخدام `crypto.createHmac('sha256', CMI_SECRET_KEY).update(payload).digest('hex')`. مقارنة HMAC المُرسَل من CMI مع HMAC المُحسَب. رفض أي طلب لا يتطابق. |
| **WH-02** | **🔴 لا IP Whitelist.** أي IP يمكنه الوصول إلى webhook. CMI لديه نطاق IPs ثابت يجب حصر الوصول به. | 🔴 خطر | إضافة IP whitelist على مستوى التطبيق (middleware) + على مستوى البنية التحتية (Nginx/Firewall). استخدام `@nestjs/schedule` أو guard يتحقق من `req.ip` ضد قائمة CMIIPs. |

### خطة تطبيق HMAC

```
1. الحصول على CMI_SECRET_KEY من CMI dashboard
2. في webhook handler:
   const receivedHmac = req.body.HMAC || req.body.signature;
   const calculatedHmac = crypto
     .createHmac('sha256', CMI_SECRET_KEY)
     .update(JSON.stringify(sortedPayload))
     .digest('hex');
   if (receivedHmac !== calculatedHmac) throw new ForbiddenException();
3. إضافة Guard: IpWhitelistGuard مع قائمة CMIIPs
4. تسجيل كل محاولة فاشلة في audit_log
```

---

## 2. مراجعة Idempotency

### الوضع الحالي
- `findFirst({ transactionId })` يمنع معالجة نفس transactionId مرتين
- يُستخدم لمنع ازدواجية التفعيل عند تكرار webhook

### الثغرات

| # | الثغرة | المستوى | التوصية |
|---|--------|---------|---------|
| **ID-01** | **🟡 لا expiry على idempotency key.** transactionId يُخزّن إلى الأبد. CMI قد يُعيد استخدام transactionId بعد فترة (نادر لكن ممكن). | 🟡 متوسط | إضافة TTL: تخزين transactionId في Redis بدلاً من DB مع TTL 24 ساعة. أو إضافة `processed_at` timestamp في جدول Payment والتحقق من وجود transactionId خلال آخر 30 يوماً فقط. |
| **ID-02** | **🟡 لا Validate للـ transactionId format.** قد يتم إرسال transactionId ضار (SQL injection, XSS). | 🟡 متوسط | التحقق من أن `transactionId` UUID v4 pattern. رفض أي transactionId لا يتطابق مع `/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i`. |
| **ID-03** | **🟢 Idempotency Check متأخر.** يتم التحقق بعد بدء المعالجة. الأفضل التحقق مبكراً لتجنب العمل غير الضروري. | 🟢 تحسين | نقل idempotency check إلى بداية الـ handler (أو guard) قبل أي منطق آخر. Return 409 Conflict مع existing payment status. |

---

## 3. مراجعة PCI-DSS Level 4 Compliance

### 3.1 المتطلبات الأساسية لـ PCI-DSS Level 4

متطلبات PCI-DSS للـ Level 4 (< 20,000 transaction/ year, e-commerce):

| # | المتطلب | الحالة | ملاحظة |
|---|---------|--------|--------|
| 1 | Build and maintain a secure network | 🟡 جزئي | Firewall موجود لكن لا يوجد Network Segmentation |
| 2 | Do not use vendor default passwords | ✅ | يفترض تغيير الافتراضي |
| 3 | Protect stored cardholder data | 🔴 لا | **لا يوجد تخزين لبيانات البطاقة** ✅ مطلوب عدم تخزين PAN, CVV, Track Data— CMI يتولى الدفع خارجياً |
| 4 | Encrypt transmission of cardholder data | ✅ | HTTPS + TLS 1.3 (مذكور في ADR) |
| 5 | Use and regularly update antivirus | 🟡 جزئي | ClamAV مطلوب (مذكور في Sprint 4) |
| 6 | Develop and maintain secure systems | 🟡 جزئي | Patch management policy غير موثقة |
| 7 | Restrict access to cardholder data | 🟡 جزئي | RBAC موجود لكن Payment data متاح لـ ARTISAN نفسه فقط— مقبول |
| 8 | Identify and authenticate access | ✅ | JWT + MFA للمشرفين (مذكور في discussion-phase2) |
| 9 | Restrict physical access | ✅ | Cloud hosting — AWS/Hetzner |
| 10 | Track and monitor access | 🟡 جزئي | Audit log موجود لكن لا يوجد SIEM أو تنبيهات |
| 11 | Regularly test security systems | 🔴 لا | لا يوجد جدول اختبار اختراق منتظم |
| 12 | Maintain information security policy | 🟡 جزئي | سياسة مبدئية موجودة لكن غير موثقة رسمياً |

### 3.2 ثغرات PCI-DSS محددة

| # | الثغرة | المستوى | التوصية |
|---|--------|---------|---------|
| **PCI-01** | **🟡 Payment.metadata يُخزّن CMI raw response.** الـ raw response قد يحتوي على PAN مموّه (e.g. `"pan": "XXXXXXXXXXXX1234"`) أو بيانات حساسة. حتى الـ truncated PAN يعتبر cardholder data ويخضع لـ PCI-DSS. | 🟡 متوسط | Sanitize metadata قبل التخزين: حذف أي حقل يحتوي `pan`, `card`, `cvv`. تخزين فقط `transactionId`, `status`, `amount`, `currency`. |
| **PCI-02** | **🟡 `GET /api/v1/payments/status/:id` بدون مصادقة.** أي شخص يعرف payment ID يمكنه الاطلاع على حالة الدفع ومعلومات الحرفي. | 🟡 متوسط | إضافة `JwtAuthGuard` + التحقق من ملكية الـ payment (الحرفي صاحب الـ payment أو ADMIN). |
| **PCI-03** | **🟢 لا سياسة احتفاظ بالبيانات (Data Retention).** الـ audit_logs و payments ستبقى للأبد. PCI-DSS يتطلب تعريف فترة احتفاظ. | 🟢 منخفض | تعريف retention policy: Payments = 3 سنوات (حسب القانون المغربي), Audit logs = 1 سنة. تطبيق archiving job. |
| **PCI-04** | **🟢 لا ASV scan (Approved Scanning Vendor).** PCI-DSS Level 4 يتطلب فحص ربع سنوي للثغرات من ASV معتمد. | 🟢 منخفض | جدولة فحص ربع سنوي عبر ASV (مثل Trustwave، SecurityMetrics). تكلفة تقريبية: $200-500/ربع سنوي. |

---

## 4. مراجعة Endpoints Security

| # | الثغرة | المستوى | التوصية |
|---|--------|---------|---------|
| **EP-01** | **🟡 `POST /api/v1/payments/init` ليس لديه Rate Limiting.** مهاجم يمكنه إنشاء آلاف طلبات الدفع لاستنزاف موارد CMI API أو استنفاد credits. | 🟡 متوسط | Rate Limit: 5 init/دقيقة/حرفي. 100 init/ساعة/IP. |
| **EP-02** | **🟢 Auto-renewal يجدد بدون إشعار المستخدم.** إذا فشلت المحاولة (بطاقة منتهية)، لا توجد خطة إشعار أو retry. | 🟢 منخفض | إرسال إشعار (FCM) قبل 3 أيام من التجديد. إذا فشل التجديد، إرسال إشعار فوري + إعادة المحاولة بعد 3 أيام (max 3 retries). Downgrade إلى Free بعد فشل كل المحاولات. |
| **EP-03** | **🟢 `POST /api/v1/subscriptions/upgrade` يمنع الترقية لنفس الباقة أو أقل.** جيد، لكن هل يمنع الترقية من Premium إلى Pro (downgrade)؟ | 🟢 استفسار | تأكيد المنطق: upgrade = إلى أعلى فقط. cancel → ثم subscribe للباقة الأقل. |

---

## 5. قائمة التحقق النهائية

### 5.1 ✅ معتمد
- [x] 3 خطوات CMI واضحة (init → webhook → activate)
- [x] Idempotency عبر transactionId
- [x] Audit log لكل خطوة دفع
- [x] تخزين IP + UserAgent في Payment
- [x] Subscription management (subscribe, cancel, upgrade)
- [x] منع الترقية لنفس الباقة أو أقل
- [x] Cron للتجديد التلقائي
- [x] Audit log للاشتراكات

### 5.2 ❌ يحتاج معالجة فورية — قبل Sprint 8
- [ ] HMAC verification على webhook (#WH-01)
- [ ] IP Whitelist للـ CMI webhook (#WH-02)
- [ ] Sanitize Payment.metadata — إزالة PAN/card data (#PCI-01)
- [ ] JwtAuthGuard على payments/status/:id (#PCI-02)

### 5.3 ⚠️ يحتاج جدولة (Sprint 8 أو Sprint 9)
- [ ] Idempotency expiry (Redis TTL 24h) (#ID-01)
- [ ] transactionId format validation (UUID v4) (#ID-02)
- [ ] Rate Limiting على payment init (#EP-01)
- [ ] Auto-renewal notification قبل 3 أيام (#EP-02)
- [ ] Data Retention policy (#PCI-03)
- [ ] جدول ASV scan ربع سنوي (#PCI-04)
- [ ] Idempotency check مبكر (409 Conflict) (#ID-03)

---

## 6. خطة المعالجة (Remediation Plan)

### عاجل — 3 أيام (قبل Sprint 8)

| P | المهمة | الملفات المتوقعة | المدة |
|---|--------|-----------------|-------|
| P0 | HMAC Verification | `webhook` handler + crypto.createHmac | 1 يوم |
| P0 | IP Whitelist Middleware | `IpWhitelistGuard` + env CMIIPs | 0.5 يوم |
| P1 | Sanitize CMI response قبل save | `payments.service.ts` | 0.5 يوم |
| P1 | Auth على payment status | `payments.controller.ts` + Guard | 0.5 يوم |

### المدى القصير (Sprint 8-9)

| P | المهمة | المدة |
|---|--------|-------|
| P2 | Idempotency Redis TTL | 1 يوم |
| P2 | Rate Limiting payment init | 0.5 يوم |
| P2 | Auto-renewal notification flow | 1.5 يوم |
| P3 | Data Retention + Archiving | 1 يوم |
| P3 | PCI-DSS SAQ documentation | 2 أيام |

---

## 7. PCI-DSS SAQ A (Self-Assessment Questionnaire)

لأن Elmokef يستخدم CMI (بوابة دفع خارجية) ولا يخزن بيانات البطاقة، **SAQ A** هو المناسب:

| المتطلب | الإجراء | المسؤول | الموعد |
|---------|---------|---------|--------|
| 9.3 — فحص ربع سنوي | الاشتراك في ASV (مثل Trustwave) | DevOps | ربع سنوي |
| 10.2 — Audit trails | التأكد من تسجيل جميع أحداث الدفع في audit_logs | Backend | قائم |
| 10.5 — Secure audit logs | حماية audit_logs من التعديل (append-only) | Database | Sprint 9 |
| 11.1 — Wireless scan | غير مطلوب (لا شبكة داخلية) | — | — |
| 12.1 — Security policy | توثيق PCI-DSS policy | فيصل | Sprint 9 |

---

## 8. الخلاصة

**التقييم العام:** التنفيذ الأساسي مقبول (Idempotency, Audit logs, IP tracking). لكن **غياب HMAC Verification (#WH-01)** هو ثغرة حرجة: أي شخص يمكنه استدعاء webhook endpoint وتفعيل اشتراكات Premium بدون دفع. هذا يعرض المنصة لخسارة مالية فورية.

**التوصية:** منع الانتقال لـ Sprint 8 حتى معالجة P0-P1 (تقدير 3 أيام).

يجب أيضاً تعبئة **PCI-DSS SAQ A** قبل الإطلاق التجاري (تقدير يومين عمل).

---

— فيصل المطيري | Security Specialist  
`/signed/fsal-mutairi-2026-06-17-sprint7-pci-dss/`
