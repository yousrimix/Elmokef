# 5.7 — Prototype تفاعلي: خريطة التدفق (User Flow)
**إعداد:** ليلى السعد — UI/UX Designer  
**أداة التصميم:** Figma (موصى به) — هذا الملف يوثق التدفق والتفاعلات

---

## 1. تدفق العميل — السيناريو الرئيسي

```
[شاشة الترحيب HC-01]
        │
        ▼
[تسجيل برقم الهاتف]
        │
        ▼
[إدخال OTP → تأكيد]
        │
        ▼
[الشاشة الرئيسية — فئات HC-02]
        │
        ├── ← اختيار فئة "سباكة"
        │          │
        │          ▼
        │   [طلب الموقع 🟢 (يُطلب الآن)]
        │          │
        │          ▼
        │   [قائمة الحرفيين HC-03]
        │          │
        │          ├── ← نقر على حرفي
        │          │          │
        │          │          ▼
        │          │   [ملف الحرفي HC-04]
        │          │          │
        │          │          ├── ← نقر "اتصال" → [شاشة الاتصال]
        │          │          │          │
        │          │          │          ▼
        │          │          │   [فتح تطبيق الهاتف/واتساب]
        │          │          │          │
        │          │          │          ▼
        │          │          │   [بعد 24 ساعة ← إشعار تقييم]
        │          │          │          │
        │          │          │          ▼
        │          │          │   [شاشة التقييم HC-05]
        │          │          │
        │          │          └── ← نقر ❤️ → [إضافة للمفضلة]
        │          │
        │          └── ← نقر 🗺️ → [عرض الخريطة]
        │
        ├── ← نقر 🔍 → [شاشة البحث]
        │
        ├── ← نقر ❤️ → [المفضلة]
        │
        └── ← نقر 👤 → [حسابي HC-06]
```

### التفاعلات المحددة (Figma Prototype)

| من | إلى | المحفّز (Trigger) | Animasyon |
|----|-----|-------------------|-----------|
| HC-01 → OTP | إدخال رقم | نقر "سجّل" | Fade In + Slide Up |
| OTP → HC-02 | تأكيد OTP | نقر "تأكيد" | Fade + Slide |
| HC-02 → HC-03 | اختيار فئة | نقر على فئة | Slide Left (push) |
| HC-03 → HC-04 | اختيار حرفي | نقر على بطاقة | Slide Left + Hero (صورة) |
| HC-03 ← HC-04 | رجوع | نقر على ← | Slide Right |
| HC-04 → اتصال | نقر اتصال | نقر زر CTA | Bottom Sheet Slide Up |
| HC-05 → نجاح | إرسال التقييم | نقر "إرسال" | Fade → Success State |
| Bottom Nav | تبديل التبويب | نقر أيقونة | Fade (cross-dissolve) |

---

## 2. تدفق الحرفي — السيناريو الرئيسي

```
[شاشة ترحيب الحرفي HA-00]
        │
        ▼
[Wizard خطوة 1 — البيانات الأساسية]
        │
        ▼ ← نقر "التالي"
[Wizard خطوة 2 — الخدمات والأسعار]
        │
        ▼ ← نقر "التالي"
[Wizard خطوة 3 — الصور والوثائق]
        │
        ▼ ← نقر "التالي"
[Wizard خطوة 4 — اختيار الباقة]
        │
        ▼ ← نقر "تأكيد"
[Dashboard الحرفي HA-01]
        │
        ├── 📋 → [طلباتي HA-02]
        │          │
        │          └── ← نقر "اتصال" → [فتح واتساب/هاتف]
        │
        ├── ⭐ → [تقييماتي HA-03]
        │
        └── 👤 → [حسابي HA-04]
                   │
                   └── ← [الاشتراكات HA-05]
```

---

## 3. تدفق المشرف

```
[تسجيل دخول المشرف AD-01]
        │
        ▼
[MFA (رمز تأكيد)]
        │
        ▼
[لوحة التحكم AD-02]
        │
        ├── ← [إدارة الحرفيين AD-03]
        │          │
        │          └── ← نقر على حرفي → [تفاصيل + توثيق AD-04]
        │                       │
        │                       └── [قبول / رفض] → تحديث الحالة
        │
        ├── ← [الشكايات AD-05]
        │          │
        │          └── [حل / رفض]
        │
        └── ← [الإحصائيات AD-06]
```

---

## 4. ملاحظات للـ Prototype في Figma

### إعدادات الجهاز
- **Client App:** iPhone 14 Pro (390×844) أو Android Large (412×915)
- **Artisan App:** نفس أبعاد Client (لكن بمحتوى مختلف)
- **Admin Panel:** Desktop 1440×900 مع خيار Tablet 768×1024

### المكونات المشتركة (Components)
أنشئ هذه المكونات الرئيسية في Figma كـ Components:
1. `🔲 Button/Primary` — مع حالات normal, hover, pressed, disabled
2. `🔲 Button/Secondary` — مع جميع الحالات
3. `🔲 Card/Artisan` — بطاقة الحرفي القابلة لإعادة الاستخدام
4. `🔲 Card/Review` — بطاقة التقييم
5. `🔲 Input/TextField` — مع حالات normal, focus, error, filled
6. `🔲 BottomNav/Client` — التبويب السفلي للعميل
7. `🔲 BottomNav/Artisan` — التبويب السفلي للحرفي
8. `🔲 Avatar` — صورة شخصية (56px, 64px, 80px, 120px)
9. `🔲 Star/Rating` — مكون التقييم (قابل للتفاعل)
10. `🔲 Badge/Verified` — شارة التوثيق
11. `🔲 Badge/Subscription` — شارة الباقة (مجاني/احترافي/مميز)
12. `🔲 EmptyState` — مع إمكانية تغيير النص والصورة
13. `🔲 Loading/Shimmer` — تأثير التحميل

### الـ Auto Layout
- استخدم Auto Layout في كل الشاشات
- Padding موحّد: 24px أفقياً، 16px عمودياً بين العناصر
- Gap بين البطاقات: 12px

### الـ Variants
- أزرار: `State=normal/hover/pressed/disabled` + `Type=primary/secondary/text`
- بطاقات: `Type=client/artisan` + `State=default/selected`
- Inputs: `State=normal/focus/error/disabled` + `HasIcon=true/false`

---

## 5. قائمة شاشات Figma (Figma Pages)

| الصفحة (Page) | الشاشات |
|--------------|---------|
| 🟢 Client App | HC-01 Onboarding, HC-02 Home, HC-03 List, HC-04 Profile, HC-05 Review, HC-06 Account, HC-07 Favorites, HC-08 Search |
| 🟠 Artisan App | HA-00 Welcome, HA-01 Dashboard, HA-02 Requests, HA-03 Reviews, HA-04 Account, HA-05 Subscriptions + Wizard Steps 1-4 |
| 🔵 Admin Panel | AD-01 Login, AD-02 Dashboard, AD-03 Artisans, AD-04 Verification, AD-05 Complaints, AD-06 Analytics |
| 🔲 Design System | Colors, Typography, Icons, Buttons, Inputs, Cards, Components |
| 📋 Flow Diagrams | Client Flow, Artisan Flow, Admin Flow |

---

— ليلى السعد | UI/UX Designer
