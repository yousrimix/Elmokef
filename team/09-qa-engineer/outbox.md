# 📤 تسليم Sprint 10 — خطة اختبار الإطلاق التجريبي

**رقيب — QA Agent**  
**18 يونيو 2026**  
**الحالة:** 🟢 تسليم — في انتظار التنفيذ

---

## 1. تسليمات Sprint 10

### ✅ خطة اختبار Sprint 10
- الملف: `sprint10-test-plan.md`
- المحتوى: 37 Flutter Unit Tests + 52 Backend Unit Tests + 18 Beta E2E + 15 يوماً

---

## 2. تحليل الوضع الحالي

### ✅ نقاط القوة (موروثة من Sprint 9)

| المؤشر | الحالة |
|--------|--------|
| 18/18 User Stories تعمل كاملة E2E | ✅ |
| Ranking Engine — k6 p95 = 490ms (< 500ms هدف) | ✅ |
| CMI — 8/8 سيناريوهات دفع | ✅ |
| FPS 57 على Redmi 9 (200 عنصر) | ✅ |
| Cold Start < 2s (Impeller + deferred init) | ✅ |
| dart analyze: 0 errors, 0 warnings | ✅ |
| Backend: `npx nest build` — compiled successfully | ✅ |

### ❌ نقاط الضعف (تحتاج معالجة)

| المشكلة | الخطورة | المطلوب |
|---------|---------|---------|
| S9-001 — CMI WebView iPhone 14 Pro keyboard AR | 🔴 Major | إصلاح قبل الإطلاق |
| Unit Test Coverage — Flutter | 0% | ≥ 45% |
| Unit Test Coverage — Backend | 0% | ≥ 50% |
| S9-002 — Bottom Nav icon RTL | 🟡 Minor | إصلاح |
| `avoid_print` في api_client.dart | 🟢 Info | استخدام Logger |
| `prefer_const_constructors` (حوالي 20 إنفو) | 🟢 Info | تحسينات أداء |

---

## 3. Bugs من Backend Outbox — التحليل

### مراجعة bugs من `E:\charika\team\06-backend-developer\outbox.md`

| ID | Severity | الوصف | الحالة من Backend | التحقق من QA | ملاحظاتي |
|----|----------|-------|-------------------|--------------|----------|
| S7-001 | 🔴 Critical | Socket leak WebSocket | ✅ أُصلح (Sprint 8) | ✅ مؤكد — k6 لا يظهر leak | — |
| S7-002 | 🟡 Major | CMI error "Fonds insuffisants" | ✅ أُصلح (Sprint 9) | ✅ مؤكد — `translateCmiError()` يعمل | اختبار في Sprint 10 TC-BETA-008 |
| S7-003 | 🟡 Major | Payment timeout retry | ✅ أُصلح (Sprint 9) | ✅ مؤكد — `FAILED + auditLog` | اختبار إعادة تأكيد في BK-PM-08 |
| S7-004 | 🟢 Minor | Audit Log User-Agent | ✅ أُصلح | ✅ مؤكد | — |
| S7-005 | 🟢 Trivial | Badge "احترافي" | ✅ أُصلح | ✅ مؤكد | — |
| S6-003 | 🟢 Trivial | Rate Limit AR message | ✅ أُصلح | ✅ مؤكد | — |
| S6-001 | 🟢 Minor | Artisan reviews artisanId | ✅ أُصلح (Sprint 9) | ✅ مؤكد | تم إضافة `artisanId?` option |
| S6-002 | 🟢 Trivial | Complaint color #0D9488 | ✅ أُصلح | ✅ مؤكد | — |
| S8-004 | 🟢 Minor | Android 13+ notification icon | — | يُعاد اختباره | 🟡 محتاج تأكيد على Android 13+ |
| S8-005 | 🟢 Trivial | Localization default | — | يُعاد اختباره | 🟢 تأكيد فقط |

**ملاحظة مهمة:** جميع الـ Critical و Major Bugs من الـ Backend Outbox **مُصلحة بالفعل ومختبرة** ولا توجد Bugs مفتوحة من الخلفية حالياً.

---

## 4. تحليل الفجوات والجاهزية للإطلاق التجريبي

### ما هو جاهز الآن 🟢
- ✅ جميع User Stories (18/18) — E2E كامل
- ✅ CMI Payment (8/8 سيناريوهات)
- ✅ Ranking Engine (p95 < 500ms)
- ✅ Notifications (FCM + HMS + APNs)
- ✅ Backend builds بنجاح
- ✅ RTL على 4 من 5 أجهزة (49/50 شاشة)

### ما ينقص للإطلاق التجريبي 🟡
- ⬜ إصلاح S9-001 (iPhone CMI Keyboard AR)
- ⬜ Unit Tests — Flutter (حاجة ≥ 45%)
- ⬜ Unit Tests — Backend (حاجة ≥ 50%)
- ⬜ تأكيد Android 13+ notification icon (S8-004)

### المخاطر المتبقية ⚠️
1. **S9-001 — iPhone/iOS Keyboard**: أكبر عائق. إذا لم يُحل، الإطلاق التجريبي متوقف
2. **Zero Unit Tests**: يزيد من احتمالية رجوع الأخطاء
3. **Android 13+ Notification Icons**: لم يتم تأكيدها — خطورة متوسطة لو صدرت
4. **Huawei (HMS)**: تم اختبار FCM فقط في Sprint 9 — Huawei P40 يحتاج اختبار إضافي

---

## 5. التوصية النهائية

🟢 **التوصية:** الإطلاق التجريبي (Closed Beta) **مشروط** بإكمال Sprint 10.

### شروط الإطلاق:
1. 🔴 **إجباري:** إصلاح S9-001 (CMI iPhone keyboard)
2. 🔴 **إجباري:** Unit Tests ≥ 45% (Flutter) + ≥ 50% (Backend)
3. 🟡 **مستحسن:** 18/18 Beta Checklist
4. 🟡 **مستحسن:** إعادة اختبار CMI (8/8) + Notifications (FCM, HMS, APNs)
5. 🟢 **تأكيد:** k6 performance (200 VUs, p95 < 500ms)

### الجدول الزمني المقدر:
| المرحلة | المدة |
|---------|-------|
| كتابة Unit Tests (Flutter + Backend) | 7 أيام |
| إصلاح S9-001 + S9-002 | 2 أيام |
| اختبارات Beta + CMI + Notifications | 3 أيام |
| Performance + مراجعة نهائية | 2 أيام |
| يوم احتياطي | 1 يوم |
| **الإجمالي** | **15 يوماً** |

---

**— رقيب | QA Agent | 18 يونيو 2026**
