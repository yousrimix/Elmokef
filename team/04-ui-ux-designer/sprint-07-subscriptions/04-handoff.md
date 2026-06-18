# Sprint 7 — Handoff كامل
**إعداد:** ليلى السعد — UI/UX Designer
**التسليم إلى:** محمد العلي (Backend — CMI Integration) + خالد العمري (Flutter)

---

## 1. التسليمات

```
📁 sprint-07-subscriptions/
│
├── 01-plan-comparison.md      ← SB-01: 3 بطاقات مقارنة
│                                Free / Pro / Premium
│                                عرض المقارنة الكامل (جدول)
│                                بطاقة الباقة الحالية (Badge)
│                                Layout عمودي للموبايل
│                                API endpoints + JSON schema
│
├── 02-payment-states.md       ← SB-02: نجاح الدفع ✅
│                                SB-03: فشل الدفع ❌ (6 أخطاء)
│                                SB-04: إلغاء الاشتراك (3 خطوات)
│                                SB-05: مهلة الدفع (Banner معلق)
│                                تدفق الدفع الكامل + Webhook
│
├── 03-subscription-settings.md ← SS-01: إعدادات الاشتراك
│                                  SS-02: سجل المدفوعات
│                                  SS-03: مشترك مجاني
│                                  SS-04: اشتراك منتهٍ
│                                  Push Notifications × 4
│
└── 04-handoff.md (this)       ← تسليم المطورين
```

---

## 2. ملخص الشاشات

| الرمز | الشاشة | الأولوية |
|-------|--------|---------|
| SB-01 | مقارنة الباقات (3 أعمدة / عمودي موبايل) | Must |
| SB-02 | نجاح الدفع ✅ | Must |
| SB-03 | فشل الدفع ❌ (6 أنواع أخطاء) | Must |
| SB-04 | إلغاء الاشتراك (تأكيد + سبب + تأكيد نهائي) | Must |
| SB-05 | مهلة دفع معلقة (Banner) | Should |
| SS-01 | إعدادات الاشتراك + سجل المدفوعات | Must |
| SS-02 | سجل المدفوعات (مع فلاتر) | Should |
| SS-03 | مشترك مجاني (دعوة للترقية) | Must |
| SS-04 | اشتراك منتهٍ (مع تجديد) | Must |

---

## 3. API Endpoints (لمحمد)

| # | الطريقة | الـ Endpoint | الأولوية |
|---|---------|-------------|---------|
| 1 | GET | `/api/v1/plans` | Must |
| 2 | GET | `/api/v1/subscriptions/current` | Must |
| 3 | POST | `/api/v1/subscriptions/subscribe` | Must |
| 4 | POST | `/api/v1/subscriptions/cancel` | Must |
| 5 | POST | `/api/v1/subscriptions/upgrade` | Must |
| 6 | POST | `/api/v1/subscriptions/auto-renew` | Must |
| 7 | POST | `/api/v1/subscriptions/retry-payment` | Should |
| 8 | GET | `/api/v1/payments/history` | Must |
| 9 | GET | `/api/v1/payments/invoice/:id` | Should |
| 10 | POST | `/api/v1/payments/cmi-webhook` | Must |

---

## 4. مكونات Flutter (لخالد)

| المكون | الوصف | الحالات |
|--------|-------|---------|
| `PlanCard` | بطاقة باقة (اسم + سعر + مميزات + زر) | default, current, recommended |
| `PlanComparison` | 3 بطاقات في صف (responsive → عمودي) | — |
| `FeatureItem` | صف ميزة (✅ / ❌ + نص) | — |
| `PaymentSuccess` | شاشة نجاح ✅ | — |
| `PaymentFailure` | شاشة فشل ❌ | 6 أنواع أخطاء |
| `CancelSubscriptionDialog` | حوار تأكيد الإلغاء | — |
| `CancelReasonSheet` | Bottom Sheet سبب الإلغاء | — |
| `SubscriptionSettings` | إعدادات الاشتراك | active, free, expired |
| `InvoiceCard` | بطاقة فاتورة في السجل | paid, pending |
| `PaymentBanner` | Banner دفع معلق | — |
| `SubscriptionBadge` | Badge "حالي" / "نشط" / "منتهٍ" | active, expired, free |

---

## 5. Assets

| الملف | الوصف | الصيغة |
|-------|-------|--------|
| `payment_success.svg` | أيقون نجاح 120×120 | SVG |
| `payment_failure.svg` | أيقون فشل 120×120 | SVG |
| `cancel_confirm.svg` | أيقون إلغاء 120×120 | SVG |
| `free_plan.svg` | أيقون باقة مجانية 64×64 | SVG |
| `pro_plan.svg` | أيقون باقة Pro 64×64 | SVG |
| `premium_plan.svg` | أيقون باقة Premium 64×64 | SVG |
| `crown.svg` | تاج (باقة حالية) 64×64 | SVG |

---

## 6. تصميم WebView الدفع

```
┌──────────────────────────────────┐
│  دفع CMI • باقة Pro • 99 DH     │  ← Native AppBar
│  ← إلغاء                         │  ← إلغاء = عودة للفشل
│                                   │
│  ┌──────────────────────────────┐ │
│  │                              │ │
│  │    WebView (CMI)            │ │  ← تملأ الشاشة
│  │                              │ │
│  │  رقم البطاقة: ████████      │ │
│  │  تاريخ: ██/██               │ │
│  │  CVV: ███                    │ │
│  │                              │ │
│  │  [دفع 99 DH]                │ │
│  │                              │ │
│  └──────────────────────────────┘ │
│                                   │
│  🔒 الدفع آمن via CMI            │  ← 11px, #6B7280
│  يقبل: CIH, BMCE, Attijariwafa   │
└──────────────────────────────────┘
```

### Webhook → Flutter Communication

```
CMI WebView
    │
    ├── نجاح → POST webhook → Server → WebSocket/SSE → Flutter → SB-02
    │
    └── فشل → POST webhook → Server → WebSocket/SSE → Flutter → SB-03
    │
    └── إلغاء (مستخدم أغلق) → Native → Flutter → SB-03
```

---

## 7. قائمة التحقق النهائية

- [x] شاشة مقارنة 3 باقات (Free / Pro / Premium)
- [x] بطاقة مميزة لـ Pro (Badge "أكثر طلباً" + إطار مذهب + ظل)
- [x] جدول المقارنة الكامل
- [x] تمييز الباقة الحالية (Badge "حالي")
- [x] Layout عمودي للموبايل
- [x] شاشة نجاح الدفع ✅
- [x] شاشة فشل الدفع ❌ (6 رسائل خطأ)
- [x] شاشة إلغاء الاشتراك (3 خطوات: تأكيد → سبب → تأكيد نهائي)
- [x] Banner دفع معلق
- [x] إعدادات الاشتراك (نشط / مجاني / منتهٍ)
- [x] سجل المدفوعات
- [x] Push Notifications (4 أنواع)
- [x] WebView CMI تصميم
- [x] Webhook → WebSocket → Flutter
- [x] API Endpoints كاملة + JSON schemas (10 endpoints)

---

— ليلى السعد | UI/UX Designer
