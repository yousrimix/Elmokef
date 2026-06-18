# Sprint 9 — QA & Performance
**رنا السعيد — QA Engineer**
**12 – 23 أكتوبر 2026**

## المهام

### 1. اختبار 18 User Story كاملة
- قابلية الاستخدام، كل سيناريو من بدايته لنهايته
- تقرير لكل قصة (✅/❌)

### 2. اختبار RTL
- كل شاشة بالعربية والفرنسية
- محاذاة، نصوص مقطوعة، أزرار خارج الشاشة

### 3. اختبار أجهزة (5 أجهزة)
- Redmi 9 (Android low-end)
- Samsung A32 (Android mid)
- Pixel 6a (Android stock)
- iPhone 11 (iOS mid)
- iPhone 14 (iOS flagship)

### 4. اختبار الإشعارات
- FCM + HMS + APNs
- 3 حالات تطبيق × 4 أنواع

### 5. اختبار أداء (k6)
- 1000 مستخدم وهمي متزامن
- API Latency < 500ms (p95)

### 6. اختبار دفع CMI
- 6 سيناريوهات فشل (بطاقة مرفوضة، Timeout، 3D Secure، إلغاء، Replay، خطأ شبكة)

## تسليم
- `sprint9-test-report.md`
- `outbox.md`
