# Sprint 2 — تسليم Auth Flow لمطوري Flutter
**إعداد:** ليلى السعد — UI/UX Designer  
**التسليم إلى:** خالد العمري (Flutter Developer)  
**المرجع:** Roadmap Sprint 2 — Auth Module

---

## 1. تدفق Auth الكامل

```
[فتح التطبيق]
      │
      ▼
[Check: هل أكمل Onboarding؟]
      │                   
      ├── لا → [Onboarding (4 شاشات)]
      │               │
      │               ▼
      └── نعم → [شاشة اختيار الدور]
                      │
                      ▼
         ┌──────────────────────┐
         │  أنا عميل  |  أنا حرفي │
         └──────────────────────┘
                      │
                      ▼
        ┌───────────────────────────┐
        │  شاشة التسجيل/الدخول     │
        │                          │
        │  [رقم الهاتف أو البريد]  │
        │  [كلمة المرور (اختياري)] │
        │  [📧 Google] [فيسبوك]   │
        └───────────────────────────┘
                      │
          ┌───────────┴───────────┐
          │                       │
          ▼                       ▼
   [OTP عبر SMS]           [OAuth Callback]
          │                       │
          └───────────┬───────────┘
                      │
                      ▼
           ┌─────────────────────┐
           │  تسجيل ناجح 🎉      │
           │                     │
           │  → Client: الرئيسية  │
           │  → Artisan: Dashboard│
           │  → Admin: لوحة التحكم│
           └─────────────────────┘
```

---

## 2. شاشات Auth بالتفصيل

### شاشة AU-01: اختيار الدور (Role Selection)

```
┌──────────────────────────────────┐
│                                  │
│       [Logo Elmokef]            │  ← 120×40px
│                                  │
│   "اختر كيف تريد الاستخدام"     │  ← H3, 20px, #1A1A1A
│                                  │
│  ┌────────────────────────────┐  │
│  │                            │  │
│  │   🙋 أبحث عن حرفي          │  │  ← Card مع أيقونة 48px
│  │   (أنا عميل)               │  │  ← H3: "أبحث عن حرفي"
│  │                            │  │  ← Body: "أنا عميل"
│  │   "ابحث عن حرفي قريب،     │  │  ← Description: 14px, #6B7280
│  │    شوف التقييمات، وتواصل   │  │
│  │    مباشرة"                 │  │  ← ارتفاع 180px
│  └────────────────────────────┘  │  ← Card خلفية #FFFFFF
│                                  │  ← ظل 0 2px 8px rgba(0,0,0,0.08)
│  ┌────────────────────────────┐  │  ← زوايا 12px
│  │                            │  │
│  │   🛠️ أقدم خدماتي          │  │
│  │   (أنا حرفي)               │  │
│  │                            │  │
│  │   "سجّل كحرفي وابدأ في     │  │
│  │    استقبال طلبات من        │  │
│  │    الزبائن القريبين"       │  │
│  └────────────────────────────┘  │
│                                  │
│  ──────────────────────────      │
│  أنا مشرف — دخول لوحة الإدارة   │  ← Caption, #6B7280
│                                  │
└──────────────────────────────────┘
```

**السلوك:**
- اختيار "عميل" → يخزّن الـ role ويذهب لشاشة التسجيل
- "أنا مشرف" → شاشة دخول المشرف (Admin Login)

---

### شاشة AU-02: تسجيل العميل (Register — Client)

```
┌──────────────────────────────────┐
│  ←                          [دخول]│  ← زر رجوع + زر "دخول"
│                                  │
│  إنشاء حساب                     │  ← H2, 24px
│  سجّل برقم هاتفك للبدء          │  ← Body, #6B7280
│                                  │
│  ┌── Phone Input ──────────────┐ │
│  │ 🇲🇦 +212 | 6XX XX XX XX    │ │  ← AppTextField, keyboardType=phone
│  └─────────────────────────────┘ │
│                                  │
│  ┌──────────────────────────┐   │
│  │  إرسال رمز التأكيد      │   │  ← PrimaryButton (معطل إذا الرقم < 10)
│  └──────────────────────────┘   │
│                                  │
│  ──── أو ────                    │  ← AuthDivider
│                                  │
│  ┌──────────────────────────┐   │
│  │  📧 سجّل بحساب Google    │   │  ← SocialAuthButton
│  └──────────────────────────┘   │
│                                  │
│  ┌──────────────────────────┐   │
│  │  سجّل بحساب Facebook     │   │  ← SocialAuthButton
│  └──────────────────────────┘   │
│                                  │
│  بتسجيلك، أنت توافق على         │  ← Caption, 12px, #9CA3AF
│  [الشروط] و [الخصوصية]          │  ← Links: #0D9488
│                                  │
└──────────────────────────────────┘
```

---

### شاشة AU-03: إدخال OTP (رمز التأكيد)

```
┌──────────────────────────────────┐
│  ←                                │  ← زر رجوع
│                                  │
│  أدخل رمز التأكيد                │  ← H2
│                                  │
│  تم إرسال رمز مكون من 6 أرقام    │
│  إلى +212 6XX XX XX XX           │  ← Body, #6B7280
│                                  │
│  [1] [2] [3] [4] [5] [6]        │  ← OtpInput (6 خانات)
│                                  │
│  لم يصلك الرمز؟                 │
│  إعادة الإرسال بعد 30 ثانية     │  ← Caption, #6B7280
│  [تغيير الرقم]                   │  ← Link, #0D9488
│                                  │
│  ┌──────────────────────────┐   │
│  │  تأكيد                    │   │  ← PrimaryButton (معطل حتى 6 أرقام)
│  └──────────────────────────┘   │
│                                  │
└──────────────────────────────────┘
```

**الحالات:**
- **عادي:** 6 خانات فارغة، زر معطل
- **إدخال:** خانة تلو الأخرى، cursor ينتقل تلقائياً
- **ممتلئ (6 أرقام):** زر "تأكيد" مفعّل
- **خطأ:** إطار أحمر + اهتزاز + "الرمز غير صحيح"
- **نجاح:** إطار أخضر + Fade → شاشة إكمال التسجيل
- **انتهاء الوقت:** "إعادة الإرسال" يُفعّل بعد 30 ثانية

---

### شاشة AU-04: إكمال البيانات (بعد OTP — للعميل)

```
┌──────────────────────────────────┐
│  مرحباً بك 👋                   │  ← H2
│                                  │
│  أكمل بياناتك للبدء              │  ← Body, #6B7280
│                                  │
│  ┌────────────────────────────┐  │
│  │  الاسم الكامل               │  │  ← TextInput
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │  البريد الإلكتروني         │  │  ← TextInput (اختياري)
│  │  (اختياري)                 │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │  المدينة                    │  │  ← Dropdown (اختياري)
│  │  اختر مدينتك ▼             │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌──────────────────────────┐   │
│  │  تأكيد وبدء الاستخدام    │   │  ← PrimaryButton
│  └──────────────────────────┘   │
│                                  │
│  "تقدر تغير البيانات لاحقاً"   │  ← Caption, #9CA3AF
│                                  │
└──────────────────────────────────┘
```

---

### شاشة AU-05: تسجيل الدخول (Login — للعميل)

```
┌──────────────────────────────────┐
│  ←                                │
│                                  │
│  تسجيل الدخول                    │  ← H2
│                                  │
│  ┌────────────────────────────┐  │
│  │  رقم الهاتف                 │  │  ← PhoneInput
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │  كلمة المرور          👁️  │  │  ← PasswordInput
│  └────────────────────────────┘  │  (للرجوع — optional)
│                                  │
│  نسيت كلمة المرور؟              │  ← Link
│                                  │
│  ┌──────────────────────────┐   │
│  │  دخول                     │   │  ← PrimaryButton
│  └──────────────────────────┘   │
│                                  │
│  ──── أو ────                    │
│                                  │
│  ┌──────────────────────────┐   │
│  │  📧 الدخول بحساب Google  │   │
│  └──────────────────────────┘   │
│                                  │
│  ليس لديك حساب؟  إنشاء حساب    │  ← Link
│                                  │
└──────────────────────────────────┘
```

---

### شاشة AU-06: تسجيل الحرفي (Artisan Register — Simplified)

```
┌──────────────────────────────────┐
│  ←                                │
│                                  │
│  "انضم كحرفي وابدأ في استقبال   │  ← H2
│   الطلبات من الزبائن القريبين"  │
│                                  │
│  ───── الخطوة 1 من 2 ─────      │  ← Progress: ● ○
│                                  │
│  ┌────────────────────────────┐  │
│  │  الاسم الكامل               │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │  رقم الهاتف                 │  │
│  │  🇲🇦 +212 | 6XX XX XX XX  │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │  المدينة                    │  │
│  │  اختر مدينتك ▼             │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌──────────────────────────┐   │
│  │  التالي — رمز التأكيد   │   │  ← PrimaryButton
│  └──────────────────────────┘   │
│                                  │
└──────────────────────────────────┘

→ بعد OTP → الخطوة 2: المهنة والخدمات (نفس Wizard سابقاً)
```

---

### شاشة AU-07: Admin Login

```
┌──────────────────────────────────────┐
│                                        │
│           [Logo Elmokef]              │
│              Admin                     │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │  البريد الإلكتروني               │  │
│  │  ┌────────────────────────────┐  │  │
│  │  │ admin@elmokef.ma          │  │  │
│  │  └────────────────────────────┘  │  │
│  │                                  │  │
│  │  كلمة المرور                     │  │
│  │  ┌────────────────────────────┐  │  │
│  │  │ •••••••••••          👁️   │  │  │
│  │  └────────────────────────────┘  │  │
│  │                                  │  │
│  │  ┌────────────────────────────┐  │  │
│  │  │  تسجيل الدخول              │  │  │
│  │  └────────────────────────────┘  │  │
│  └──────────────────────────────────┘  │
│                                        │
│  🔒 اتصال آمن — للمشرفين فقط           │
│                                        │
└──────────────────────────────────────┘

بعد تسجيل الدخول:
→ شاشة MFA (إدخال رمز 6 أرقام مرسل للبريد)
→ → لوحة التحكم (Admin Dashboard)
```

---

## 3. الـ Route Map لتطبيق Flutter

```dart
// lib/core/router/app_router.dart — باستخدام GoRouter

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => SplashScreen()),
    
    // Onboarding
    GoRoute(path: '/onboarding', builder: (_, __) => OnboardingScreen()),
    
    // Role Selection
    GoRoute(path: '/role-selection', builder: (_, __) => RoleSelectionScreen()),
    
    // Auth - Client
    GoRoute(path: '/auth/client/register', builder: (_, __) => ClientRegisterScreen()),
    GoRoute(path: '/auth/client/otp', builder: (_, state) => OtpScreen(phone: state.extra as String)),
    GoRoute(path: '/auth/client/complete-profile', builder: (_, __) => CompleteProfileScreen()),
    GoRoute(path: '/auth/client/login', builder: (_, __) => ClientLoginScreen()),
    
    // Auth - Artisan
    GoRoute(path: '/auth/artisan/register', builder: (_, __) => ArtisanRegisterScreen()),
    GoRoute(path: '/auth/artisan/otp', builder: (_, state) => OtpScreen(phone: state.extra as String)),
    GoRoute(path: '/auth/artisan/wizard-step2', builder: (_, __) => ArtisanWizardStep2()),
    
    // Auth - Admin
    GoRoute(path: '/admin/login', builder: (_, __) => AdminLoginScreen()),
    GoRoute(path: '/admin/mfa', builder: (_, __) => AdminMfaScreen()),
    
    // Main App (after auth — protected routes)
    GoRoute(path: '/home', builder: (_, __) => ClientHomeScreen()),
    GoRoute(path: '/artisan/dashboard', builder: (_, __) => ArtisanDashboardScreen()),
    GoRoute(path: '/admin/dashboard', builder: (_, __) => AdminDashboardScreen()),
  ],
);

// Redirect Rule:
// - إذا isOnboardingCompleted == false → /onboarding
// - إذا isLoggedIn == false → /role-selection
// - إذا role == client ∧ isLoggedIn → /home
// - إذا role == artisan ∧ isLoggedIn → /artisan/dashboard
// - إذا role == admin ∧ isLoggedIn → /admin/dashboard
```

---

## 4. الـ State Management لـ Auth

```dart
// lib/features/auth/providers/auth_provider.dart

// ⚡ Riverpod Provider للتحكم بحالة المصادقة

@riverpod
class AuthNotifier extends _$AuthNotifier {
  // الحالة:
  // AuthState {
  //   bool isAuthenticated;      // هل المستخدم مسجل دخول؟
  //   UserRole? role;            // client | artisan | admin
  //   User? user;                // بيانات المستخدم
  //   bool isLoading;            // حالة التحميل
  //   String? error;             // رسالة الخطأ
  // }
  
  // Méthodes:
  Future<void> registerWithPhone(String phone) async { ... }
  Future<void> verifyOtp(String code) async { ... }
  Future<void> loginWithPhone(String phone, String password) async { ... }
  Future<void> loginWithGoogle() async { ... }
  Future<void> loginWithFacebook() async { ... }
  Future<void> logout() async { ... }
  Future<void> resendOtp() async { ... }
}
```

---

## 5. الأسئلة المفتوحة للتطوير

| السؤال | الإجابة المقترحة |
|--------|----------------|
| هل الـ OAuth (Google/Facebook) يكون داخل WebView أم native؟ | Native (The Google Sign-In SDK + Facebook SDK) |
| OTP عبر SMS — هل نستخدم Firebase Auth Phone أم Twilio؟ | Firebase Auth Phone (أسهل تكامل مع Flutter) |
| حفظ الجلسة — هل نستخدم SharedPreferences أم flutter_secure_storage؟ | `flutter_secure_storage` (لأنها تخزّن JWT) |
| دعم الـ OTP في الـ Admin؟ | MFA عبر البريد الإلكتروني (وليس SMS) |
| هل نستخدم Firebase Auth كاملة (تسجيل + دخول + OAuth) أم NestJS API + Firebase للأشتراك الاجتماعي فقط؟ | NestJS API للمصادقة المحلية (هاتف) + Firebase Auth لتسجيل الدخول الاجتماعي فقط |

---

## 6. فحص جودة الشاشات (Checklist قبل التسليم)

- [x] جميع حالات TextInput: عادي، تركيز، خطأ، نجاح، معطل
- [x] OTP: إدخال تلقائي، Paste، حذف، cursor ينتقل
- [x] Password: إظهار/إخفاء مع أيقونة متغيرة
- [x] الأزرار: Normal, Hover, Pressed, Disabled, Loading
- [x] Onboarding: تخطي، إكمال، عدم العودة بعد الإكمال
- [x] Auth Divider: يظهر مع خيارات OAuth
- [x] روابط الشروط والخصوصية
- [x] توجيه آلي حسب الدور (Client → Home، Artisan → Dashboard، Admin → Admin Panel)
- [x] رسائل الخطأ بالعربية (الدارجة)
- [x] حفظ الجلسة (لا حاجة لتسجيل الدخول كل مرة)
- [x] تسجيل الخروج: مسح الجلسة + العودة لشاشة اختيار الدور

---

— ليلى السعد | UI/UX Designer

> **تسليم لخالد:** هذا الملف الكامل + مكونات Auth في `core/widgets/` + Assets SVG في `assets/auth/`
> **ملاحظة:** التصميم النهائي في Figma. هذا الملف يوثق كل التفاصيل اللازمة للتنفيذ في Flutter.
