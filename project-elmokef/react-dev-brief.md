# مهمة: Admin Panel — Elmokef (الميقف)

**منصة تربط العملاء بالحرفيين في المغرب**
**المدة:** 10 أيام (28 سبتمبر – 9 أكتوبر 2026)
**التقنية:** React + Vite + TypeScript + MUI (Material UI)
**الميزانية:** $800–$1,500
**الموقع:** عن بُعد (يفضّل المغرب للتوقيت)

---

## عن المشروع

Elmokef تطبيق وساطة بين العملاء والحرفيين في المغرب. العميل يختار الخدمة، والتطبيق يعرض أفضل الحرفيين القريبين. الـ Admin Panel هو لوحة تحكم ويب للإدارة.

## المتطلبات التقنية

### Stack
- **React 18+** مع Vite
- **TypeScript** (إلزامي — لا JavaScript خالص)
- **MUI (Material UI) v6+** مع دعم RTL كامل
- **React Router v6+** (راوتر)
- **Axios** للـ API calls (مع interceptor لـ JWT)
- **Recharts** أو Chart.js للإحصائيات

### RTL (Right-to-Left)
- MUI RTL عبر `ThemeProvider` + `createTheme(direction: 'rtl')`
- كل النصوص بالعربية (باستثناء الأرقام باللاتيني)
- الأيقونات تتجه مع النص
- التنسيقات: `stylis-plugin-rtl`

### API Integration
- Base URL: `https://api.elmokef.ma/api/v1`
- Auth: JWT في Header (`Authorization: Bearer <token>`)
- Admin فقط يمكنه الدخول (guard في الـ backend)
- كل صفحة فيها: **Loading state** + **Empty state** + **Error state**

---

## الصفحات المطلوبة (8)

### 1. 🔐 Login
- نموذج: إيميل + كلمة سر
- زر "تسجيل الدخول"
- حفظ JWT في localStorage
- توجيه تلقائي إلى Dashboard

### 2. 📊 Dashboard (الصفحة الرئيسية بعد الدخول)
- 4 بطاقات إحصائيات: **المستخدمون** | **الحرفيون** | **الاشتراكات النشطة** | **الإيرادات الشهرية**
- بيانات وهمية (mock) للعرض، تُستبدل بـ API حقيقي
- رسم بياني (Chart) للمستخدمين الجدد آخر 7 أيام
- آخر 5 شكايات معلّقة

### 3. 👥 Users Management
- جدول: الاسم، الهاتف، البريد، الدور (عميل/حرفي/ادمن)، تاريخ التسجيل، الحالة
- فلترة: حسب الدور + البحث بالاسم
- Pagination (10 لكل صفحة)
- نقر على صف → تفاصيل المستخدم

### 4. 🔧 Artisans Management
- جدول: الاسم، المهنة، التقييم، حالة التوثيق، الاشتراك، تاريخ التسجيل
- فلترة: حسب حالة التوثيق (معلّق/مقبول/مرفوض) + الاشتراك + البحث
- زر "توثيق" و "رفض" مع سبب الرفض
- نقر → ملف الحرفي الكامل (خدماته، صوره، تقييماته)

### 5. 📂 Categories & Services
- قائمة الفئات مع إضافة/تعديل/حذف
- كل فئة → قائمة خدماتها
- Modal لإضافة/تعديل (اسم، وصف، أيقونة)

### 6. 💳 Subscriptions
- جدول: الحرفي، الباقة (Free/Pro/Premium)، الحالة (Active/Cancelled/Expired)، تاريخ البدء، تاريخ الانتهاء
- فلترة: حسب الباقة + الحالة
- إمكانية تعديل الباقة يدوياً

### 7. ⚠️ Complaints
- جدول: العميل، الحرفي، السبب، الحالة (Open/In Progress/Resolved/Rejected)، التاريخ
- نقر → تفاصيل الشكوى
- أزرار: "قيد المعالجة" / "حلّت" / "مرفوضة"

### 8. ⭐ Reviews Moderation
- جدول: المقيّم، الحرفي، التقييم (1-5 نجوم)، النص، الحالة (Pending/Approved/Rejected)
- أزرار: قبول / رفض مع سبب

---

## Design System

### Colors
```
Primary:   #0D9488  (Teal/أخضر)
Accent:    #F59E0B  (Amber/ذهبي)
Danger:    #EF4444  (Red/أحمر)
Success:   #10B981  (Green)
Warning:   #F59E0B  (Yellow)
Info:      #3B82F6  (Blue)
Star:      #FBBF24  (Gold للتقييمات)
```

### Typography
- **العربية:** Noto Naskh Arabic (Google Font)
- **الأرقام والفرنسي:** Poppins (Google Font)
- الأحجام: `h1: 32px` | `h2: 24px` | `h3: 18px` | `body: 14px` | `caption: 12px`

### Spacing
`4, 8, 12, 16, 20, 24, 32, 40, 48` (px)

### Components Style
- **Buttons:** MUI Button مع `borderRadius: 8px`
- **Cards:** MUI Card مع `borderRadius: 12px` + ظل خفيف
- **Tables:** MUI Table مع `striped rows` + `hover`
- **Inputs:** MUI TextField مع `outlined` + `fullWidth`
- **Modals:** MUI Dialog مع زر إغلاق

---

## الهيكل المتوقع

```
src/
├── api/
│   ├── axios.ts          # Axios instance + interceptors
│   └── endpoints/        # ملف لكل موديول
│       ├── auth.ts
│       ├── users.ts
│       ├── artisans.ts
│       ├── categories.ts
│       ├── subscriptions.ts
│       ├── complaints.ts
│       └── reviews.ts
├── components/
│   ├── layout/           # Sidebar + Header + Main
│   ├── guards/           # AdminRoute, LoginRoute
│   └── shared/           # Table, Modal, Charts
├── pages/
│   ├── Login/
│   ├── Dashboard/
│   ├── Users/
│   ├── Artisans/
│   ├── Categories/
│   ├── Subscriptions/
│   ├── Complaints/
│   └── Reviews/
├── theme/
│   ├── rtl.ts            # RTL setup
│   └── theme.ts          # MUI theme
├── types/                # TypeScript interfaces
├── utils/                # Helpers
└── App.tsx
```

---

## التصاميم

التصاميم جاهزة من مصمّمتنا (ليلى السعد):
- `admin-panel-screens.md` — يحتوي على 8 شاشات مع وصف دقيق
- `design-system.md` — نظام الألوان والمكونات

سأُرسل لك الملفين عندما تبدأ.

---

## API التوثيق

**Auth:**
```
POST /api/v1/auth/login
  Body: { email, password }
  Response: { accessToken, refreshToken, user }
```

**Users:**
```
GET    /api/v1/admin/users?page=1&limit=10&role=&search=
GET    /api/v1/admin/users/:id
```

**Artisans:**
```
GET    /api/v1/admin/artisans?page=1&limit=10&verification=&subscription=&search=
PATCH  /api/v1/admin/artisans/:id/verify
  Body: { status: "APPROVED" | "REJECTED", reason?: string }
GET    /api/v1/admin/artisans/:id  // ملف كامل
```

**Categories:**
```
GET    /api/v1/categories
POST   /api/v1/admin/categories
PUT    /api/v1/admin/categories/:id
DELETE /api/v1/admin/categories/:id
```

**Subscriptions:**
```
GET    /api/v1/admin/subscriptions?page=1&limit=10&plan=&status=
PATCH  /api/v1/admin/subscriptions/:id
  Body: { plan: "PRO" | "PREMIUM", status: "ACTIVE" | "CANCELLED" }
```

**Complaints:**
```
GET    /api/v1/admin/complaints?page=1&limit=10&status=
PATCH  /api/v1/admin/complaints/:id
  Body: { status: "IN_PROGRESS" | "RESOLVED" | "REJECTED" }
```

**Reviews:**
```
GET    /api/v1/admin/reviews?page=1&limit=10&status=
PATCH  /api/v1/admin/reviews/:id
  Body: { status: "APPROVED" | "REJECTED", reason?: string }
```

**Notifications:**
```
POST   /api/v1/admin/notifications/send
  Body: { userIds: string[], title: string, body: string, type: string }
```

---

## معايير القبول

1. ✅ RTL كامل — جميع الصفحات
2. ✅ كل صفحة فيها: Loading / Empty / Error states
3. ✅ JWT محفوظ في localStorage + Interceptor
4. ✅ Admin Guard — منع الوصول بدون صلاحية
5. ✅ Responsive — تعمل على موبايل و tablet
6. ✅ `npm run build` بدون أخطاء
7. ✅ كود نظيف + TypeScript + Comments بالعربي أو الإنجليزي

---

## كيف تتقدم؟

أرسل:
1. GitHub profile
2. 2-3 مشاريع سابقة (يفضّل Admin Panels مع RTL)
3. سعرك لهذه المهمة (10 أيام)

نتائج البحث الأولية أظهرت مطوّرين مغاربة متاحين (مثل Lahsen Imdlass, Yassir Chihab, Abdelhaq Nouhi).

---

## للتواصل

عند القبول، سأُضيفك في محادثة مع الرئيس التنفيذي لمتابعة التفاصيل والتسليمات اليومية.
