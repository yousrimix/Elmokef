# Sprint 10 — خطة الاختبار: الإطلاق التجريبي (Beta Launch) + Unit Tests

**المعدّة:** رقيب — QA Agent  
**التاريخ:** 18 يونيو 2026  
**النطاق:** اختبارات الوحدة ⏐ اختبارات التكامل ⏐ إصلاح Bugs Sprint 9 ⏐ جاهزية Beta Launch

---

## ملخص Sprint 10

| البند | القيمة |
|-------|--------|
| **المدة** | 15 يوماً (18 يونيو – 2 يوليو 2026) |
| **الهدف** | تجهيز التطبيق للإطلاق التجريبي المغلق (Closed Beta) |
| **أولوية قصوى** | إصلاح S9-001 (CMI WebView + iPhone 14 Pro keyboard AR) |
| **السباقات السابقة** | Sprint 9: 18/18 US ✅ · 49/50 RTL ✅ · k6 p95 < 500ms ✅ |

---

## 1. Unit Tests — Flutter (الطبقة الأولى)

### الهدف
- رفع التغطية الاختبارية من **0%** إلى ≥ **45%** (حسب Flutter)
- اختبار الـProviders, Repositories, Use Cases, Screens

### 1.1 المصادر المطلوب اختبارها

| الفئة | الملف | Test File | أولوية | عدد الحالات |
|-------|-------|-----------|--------|-------------|
| **Auth Providers** | `lib/features/auth/presentation/providers/` | `test/features/auth/providers/auth_provider_test.dart` | 🔴 حرجة | 8 |
| **Auth Use Cases** | `lib/features/auth/domain/usecases/` | `test/features/auth/usecases/` | 🔴 حرجة | 4 |
| **Home Data** | `lib/features/home/data/repositories/` | `test/features/home/repositories/home_repo_test.dart` | 🟡 عالية | 5 |
| **Home Providers** | `lib/features/home/presentation/providers/` | `test/features/home/providers/home_provider_test.dart` | 🟡 عالية | 4 |
| **Artisan Screens** | `lib/features/artisan/presentation/screens/` | `test/features/artisan/screens/` | 🟢 متوسطة | 6 |
| **Client Screens** | `lib/features/client/presentation/screens/` | `test/features/client/screens/` | 🟢 متوسطة | 3 |
| **Notifications** | `lib/features/notifications/` | `test/features/notifications/` | 🟢 متوسطة | 3 |
| **Core Utils** | `lib/core/utils/` | `test/core/utils/` | 🟢 متوسطة | 3 |

### 1.2 أولويات الكتابة

#### 🔴 دفعة 1 — Auth (أيام 1-2)
```
test/features/auth/
├── providers/auth_provider_test.dart        (8 TCs)
└── usecases/
    ├── login_usecase_test.dart               (2 TCs)
    ├── register_usecase_test.dart            (2 TCs)
    └── send_otp_usecase_test.dart            (2 TCs)
```

#### 🟡 دفعة 2 — Home (أيام 3-4)
```
test/features/home/
├── repositories/home_repository_test.dart   (5 TCs)
└── providers/home_provider_test.dart        (4 TCs)
```

#### 🟢 دفعة 3 — Screens (أيام 5-7)
```
test/features/artisan/screens/
├── artisan_list_screen_test.dart            (3 TCs)
├── artisan_profile_screen_test.dart         (2 TCs)
└── subscriptions_screen_test.dart           (2 TCs)
test/features/client/screens/
├── search_screen_test.dart                  (2 TCs)
└── reviews_screen_test.dart                 (1 TC)
test/features/notifications/
└── notification_service_test.dart           (3 TCs)
test/core/utils/
├── validators_test.dart                     (2 TCs)
└── formatters_test.dart                     (1 TC)
```

### 1.3 إجمالي Flutter Unit Tests

| الدفعة | عدد TCs | الأيام |
|--------|---------|--------|
| دفعة 1 — Auth | 14 | 2 |
| دفعة 2 — Home | 9 | 2 |
| دفعة 3 — Screens | 14 | 3 |
| **الإجمالي** | **37 TC** | **7 أيام** |

---

## 2. Unit Tests — Backend (NestJS)

### الهدف
- رفع التغطية الاختبارية من **0%** إلى ≥ **50%**
- تغطية الـ Services, Controllers, Guards

### 2.1 المصادر المطلوب اختبارها

| الفئة | الملف / المجلد | Test File | أولوية | عدد الحالات |
|-------|----------------|-----------|--------|-------------|
| **Auth Service** | `src/modules/auth/` | `test/unit/auth.service.spec.ts` | 🔴 حرجة | 8 |
| **Auth Controller** | `src/modules/auth/` | `test/unit/auth.controller.spec.ts` | 🔴 حرجة | 5 |
| **Payments Service** | `src/modules/payments/` | `test/unit/payments.service.spec.ts` | 🔴 حرجة | 10 |
| **Payments Controller** | `src/modules/payments/` | `test/unit/payments.controller.spec.ts` | 🔴 حرجة | 4 |
| **Ranking Service** | `src/modules/ranking/` | `test/unit/ranking.service.spec.ts` | 🟡 عالية | 6 |
| **Artisans Service** | `src/modules/artisans/` | `test/unit/artisans.service.spec.ts` | 🟡 عالية | 5 |
| **Reviews Service** | `src/modules/reviews/` | `test/unit/reviews.service.spec.ts` | 🟢 متوسطة | 4 |
| **Subscriptions Service** | `src/modules/subscriptions/` | `test/unit/subscriptions.service.spec.ts` | 🟢 متوسطة | 5 |
| **JWT Guard** | `src/modules/auth/guards/` | `test/unit/jwt-auth.guard.spec.ts` | 🟢 متوسطة | 3 |
| **Throttler Guard** | `src/common/guards/` | `test/unit/throttler.guard.spec.ts` | 🟢 متوسطة | 2 |

### 2.2 سيناريوهات Payments Service (10 حالات — حرجة)

| TC-ID | السيناريو | المتوقع |
|-------|----------|---------|
| BK-PM-01 | `initPayment()` — بطاقة صحيحة ← كود نجاح CMI | return `{ redirectUrl, paymentId }` |
| BK-PM-02 | `initPayment()` — بطاقة مرفوضة ← خطأ | throw `PaymentException` مع رسالة عربية |
| BK-PM-03 | `handleWebhook()` — دفع ناجح | تحديث subscription إلى active |
| BK-PM-04 | `handleWebhook()` — Replay (idempotent) | return `200` بدون تغيير |
| BK-PM-05 | `handleWebhook()` — فشل | تحديث payment إلى failed |
| BK-PM-06 | `translateCmiError()` — `"Fonds insuffisants"` | `"رصيد غير كافٍ في الحساب"` |
| BK-PM-07 | `translateCmiError()` — رمز غير معروف | `"فشلت عملية الدفع"` |
| BK-PM-08 | `initPayment()` — اشتراك منتهي + Timeout | تعيين `FAILED + auditLog: payment.cancelled_retry` |
| BK-PM-09 | `initPayment()` — محاولة مكررة | `{ previousCancelled: true }` |
| BK-PM-10 | `initPayment()` — WebView CMI على iPhone | يحتوي `Accept-Language: ar` في headers |

### 2.3 إجمالي Backend Unit Tests

| الدفعة | عدد TCs | الأيام |
|--------|---------|--------|
| Auth (Service + Controller) | 13 | 2 |
| Payments (Service + Controller) | 14 | 2 |
| Ranking + Artisans | 11 | 2 |
| Reviews + Subscriptions + Guards | 14 | 2 |
| **الإجمالي** | **52 TC** | **8 أيام** |

---

## 3. إصلاح Bugs Sprint 9

### S9-001 🔴 Major — CMI WebView iPhone 14 Pro Keyboard AR

| الحقل | القيمة |
|-------|--------|
| **الوصف** | WebView CMI لا يظهر لوحة مفاتيح عربية في حقل رقم البطاقة — يفتح EN فقط |
| **الجهاز** | iPhone 14 Pro · iOS 17 · Safari WebView |
| **السبب المحتمل** | CMI WebView لا يستقبل `Accept-Language: ar` أو إعدادات لوحة المفاتيح لا تنتقل للـ WebView |
| **الحل المقترح 1** | إضافة `Accept-Language: ar` إلى HTTP headers للـ WebView request (backend) |
| **الحل المقترح 2** | استخدام `WKWebViewConfiguration` مع `setCustomUserAgent` يحتوي `ar` كأول لغة |
| **حالة الاختبار** | TC-BETA-001 |
| **أولوية** | 🔴 لا إطلاق بدونه |

#### TC-BETA-001: التحقق من إصلاح S9-001

| الحقل | القيمة |
|-------|--------|
| **الخطوات** | 1. iPhone 14 Pro · iOS 17 2. تسجيل حرفي ← اختيار باقة Premium 3. فتح WebView CMI 4. النقر على حقل رقم البطاقة |
| **المتوقع** | لوحة المفاتيح العربية تظهر تلقائياً (أو على الأقل في الخيارات) |
| **التكرار** | 5 محاولات متتالية — نجاح في 4/5 على الأقل |

### S9-002 🟡 Minor — Bottom Nav Icon RTL (iPhone 11)

| الحقل | القيمة |
|-------|--------|
| **الوصف** | أيقونة 🔍 في Bottom Nav تنزاح 2px في RTL |
| **الحل** | ضبط `MainAxisAlignment.center` في BottomNav أو `padding` من اليسار |
| **حالة الاختبار** | TC-BETA-002 |

### S9-003 🟢 Trivial — Duplicate Text Empty State

| الحقل | القيمة |
|-------|--------|
| **الوصف** | "لا يوجد حرفيين حرفيين" (مكررة) |
| **الحل** | تعديل الـ i18n string في `intl_ar.arb` |
| **ملاحظة** | تم إصلاحه في Sprint 9 — تأكيد فقط |

---

## 4. اختبارات الإطلاق التجريبي (Beta Launch)

### 4.1 قائمة التحقق النهائية (Checklist)

| ID | الاختبار | النتيجة |
|----|---------|---------|
| **TC-BETA-001** | ✅ S9-001 — iPhone CMI Arabic keyboard | ⬜ |
| **TC-BETA-002** | ✅ S9-002 — Bottom Nav RTL fix | ⬜ |
| **TC-BETA-003** | ✅ S9-003 — Duplicate text (مؤكد) | ⬜ |
| **TC-BETA-004** | E2E — رحلة العميل الكاملة (US-01 إلى US-10) | ⬜ |
| **TC-BETA-005** | E2E — رحلة الحرفي الكاملة (US-12 إلى US-18) | ⬜ |
| **TC-BETA-006** | E2E — Admin Flow (US-22, US-25) | ⬜ |
| **TC-BETA-007** | Ranking Engine — 10 مطابقات في المدن الكبرى | ⬜ |
| **TC-BETA-008** | CMI — 8 سيناريوهات دفع (إعادة تأكيد) | ⬜ |
| **TC-BETA-009** | Notifications — FCM + HMS + APNs (6 سيناريوهات) | ⬜ |
| **TC-BETA-010** | تسجيل حرفي — رفع وثائق + توثيق Admin | ⬜ |
| **TC-BETA-011** | GPS — تحديث الموقع بدقة ±50m | ⬜ |
| **TC-BETA-012** | RTL — 10 شاشات رئيسية على 5 أجهزة | ⬜ |
| **TC-BETA-013** | Performance — k6 200 VUs (إعادة تأكيد) | ⬜ |
| **TC-BETA-014** | Offline — لا انهيار عند فقدان الاتصال | ⬜ |
| **TC-BETA-015** | Deep Links — الإشعارات تفتح الشاشة الصحيحة | ⬜ |
| **TC-BETA-016** | Rate Limit — 60 طلب/دقيقة يحمي API | ⬜ |
| **TC-BETA-017** | Edge Case — بحث بدون نتائج | ⬜ |
| **TC-BETA-018** | Edge Case — حرفي بدون خدمات | ⬜ |

### 4.2 ملف اختبار الأداء (k6)

```javascript
// load-test-sprint10.js — تشغيل: k6 run --vus 200 --duration 5m load-test-sprint10.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const rankingTrend = new Trend('ranking_duration');

export const options = {
  stages: [
    { duration: '1m', target: 50 },
    { duration: '2m', target: 200 },
    { duration: '2m', target: 200 },
  ],
  thresholds: {
    errors: ['rate<0.01'],
    http_req_duration: ['p(95)<500'],
  },
};

const BASE_URL = 'https://api.elmokef.ma/api/v1';
const SERVICES = ['plumber', 'electrician', 'painter', 'carpenter'];
const LATS = [33.5731, 34.0209, 33.8825, 33.9716];
const LNGS = [-7.5898, -6.8416, -5.0035, -6.8498];

export default function () {
  const service = SERVICES[Math.floor(Math.random() * SERVICES.length)];
  const lat = LATS[Math.floor(Math.random() * LATS.length)];
  const lng = LNGS[Math.floor(Math.random() * LNGS.length)];

  // Ranking API
  const r1 = http.get(
    `${BASE_URL}/ranking?service=${service}&lat=${lat}&lng=${lng}&limit=20`
  );
  check(r1, { 'ranking success': (r) => r.status === 200 });
  rankingTrend.add(r1.timings.duration);
  errorRate.add(r1.status !== 200);

  // First artisan detail
  if (r1.status === 200 && r1.json().data?.length > 0) {
    const artisanId = r1.json().data[0].id;
    const r2 = http.get(`${BASE_URL}/artisans/${artisanId}`);
    check(r2, { 'artisan detail': (r) => r.status === 200 });
  }

  sleep(1);
}
```

### 4.3 متطلبات الأجهزة للاختبار النهائي

| الجهاز | OS | الذاكرة | الاختبارات |
|--------|----|---------|-----------|
| Redmi 9 | Android 11 | 3GB | All + FPS benchmark |
| Samsung A32 | Android 13 | 4GB | All + Notifications Background |
| Pixel 6a | Android 14 | 6GB | All + Killed State |
| Huawei P40 | EMUI (بدون Google) | 6GB | HMS Push فقط |
| iPhone 11 | iOS 15 | 4GB | All + APNs |
| **iPhone 14 Pro** | **iOS 17** | **6GB** | **S9-001 + All** 🔴 |

---

## 5. خريطة الطريق — 15 يوماً

| اليوم | المهمة | المخرجات |
|------|--------|----------|
| **1-2** | Unit Tests — Auth (Flutter + Backend) | 14 Flutter + 13 Backend |
| **3-4** | Unit Tests — Home (Flutter) + Ranking/Payments (Backend) | 9 Flutter + 25 Backend |
| **5-7** | Unit Tests — Screens (Flutter) + باقي Backend | 14 Flutter + 14 Backend |
| **8-9** | إصلاح S9-001 (iPhone keyboard) + S9-002 | Fix merged + tested |
| **10-11** | اختبارات Beta — E2E كامل (TC-BETA-004 إلى -012) | ✅ 9 TCs |
| **12-13** | اختبار CMI (إعادة تأكيد) + Notifications (FCM + HMS + APNs) | ✅ 2 TCs |
| **14** | Performance (k6) + RTL matrix | ✅ 2 TCs |
| **15** | مراجعة نهائية + تقرير outbox.md | تقرير ✅ |

### إجمالي الجهد

| المجال | TCs | الأيام |
|--------|-----|--------|
| Flutter Unit Tests | 37 | 7 |
| Backend Unit Tests | 52 | 8 |
| إصلاح Bugs | 2 (S9-001, S9-002) | 2 |
| Beta E2E + Performance | 18 | 5 |
| **المجموع** | **107+** | **15 يوماً** |

---

## 6. حكم الإطلاق التجريبي (Beta Launch Criteria)

### شروط المرور 🟢

| الشرط | المعيار | الحالة |
|-------|---------|--------|
| S9-001 (CMI iPhone keyboard) | ✅ مُصلح ومختبر | ⬜ |
| Unit Tests Coverage — Flutter | ≥ 45% (30+ من 67) | ⬜ |
| Unit Tests Coverage — Backend | ≥ 50% (26+ من 52) | ⬜ |
| E2E Beta Checklist | 18/18 ✅ | ⬜ |
| RTL Matrix (5 أجهزة × 10 شاشات) | 50/50 ✅ | ⬜ |
| k6 Performance (200 VUs) | p95 < 500ms, 99.5% نجاح | ⬜ |
| CMI (8 سيناريوهات) | 8/8 ✅ | ⬜ |
| Bugs Critical+Major | 0 | ⬜ |

### شروط الرفض 🔴
- واحد أو أكثر من الشروط أعلاه غير مستوفى

---

## 7. تقارير Bugs — قالب

```
**ID:** S10-###
**Severity:** Critical / Major / Minor / Trivial
**الجهاز:** [الجهاز + OS]
**الميزة:**
**الخطوات:**
**الواقع:**
**المتوقع:**
**المرفقات:** Screenshot / Log
```

---

**— رقيب | QA Agent | 18 يونيو 2026**
