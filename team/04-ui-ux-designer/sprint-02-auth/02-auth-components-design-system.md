# Sprint 2 — مكونات Auth في Design System
**إعداد:** ليلى السعد — UI/UX Designer  
**التسليم إلى:** خالد العمري (Flutter Developer)

---

## 1. TextInput

### الهيكل البصري

```
┌─────────────────────────────┐
│  البريد الإلكتروني         │  ← تسمية الحقل (Label), 14px, #6B7280
│ ┌─────────────────────────┐ │
│ │ 📧                      │ │  ← أيقونة يمين (اختياري)
│ │  user@email.com         │ │  ← نص الإدخال, 16px, #1A1A1A
│ │                         │ │
│ └─────────────────────────┘ │  ← إطار 1.5px, زوايا 10px
│  [رسالة مساعدة/خطأ]        │  ← Caption, 12px
└─────────────────────────────┘
```

### حالات TextInput

```
حالة: عادي (Normal)
┌─────────────────────────────────┐
│  رقم الهاتف                     │
│ ┌─────────────────────────────┐ │
│ │ +212 | 6XX XX XX XX        │ │  ← إطار: #D1D5DB
│ └─────────────────────────────┘ │
└─────────────────────────────────┘

حالة: تركيز (Focus)
┌─────────────────────────────────┐
│  رقم الهاتف                     │
│ ┌─────────────────────────────┐ │
│ │ +212 | 6XX XX XX XX        │ │  ← إطار: #0D9488 (2px)
│ └─────────────────────────────┘ │  ← ظل خارجي: rgba(13,148,136,0.15)
└─────────────────────────────────┘

حالة: خطأ (Error)
┌─────────────────────────────────┐
│  رقم الهاتف                     │
│ ┌─────────────────────────────┐ │
│ │ +212 | XXXXXX              │ │  ← إطار: #EF4444 (2px)
│ └─────────────────────────────┘ │
│ ⚠️ رقم الهاتف غير صحيح        │  ← نص خطأ: #EF4444, 12px
└─────────────────────────────────┘

حالة: نجاح (Success)
┌─────────────────────────────────┐
│  رقم الهاتف                     │
│ ┌─────────────────────────────┐ │
│ │ +212 | 6XX XX XX XX     ✅ │ │  ← إطار: #10B981 (2px)
│ └─────────────────────────────┘ │  ← أيقونة ✅ يمين
└─────────────────────────────────┘

حالة: معطل (Disabled)
┌─────────────────────────────────┐
│  رقم الهاتف                     │
│ ┌─────────────────────────────┐ │
│ │ +212 | 6XX XX XX XX        │ │  ← خلفية: #F3F4F6
│ └─────────────────────────────┘ │  ← نص: #9CA3AF
└─────────────────────────────────┘
```

### مواصفات Flutter

```dart
// lib/core/widgets/app_text_field.dart
class AppTextField extends StatefulWidget {
  final String? label;                    // التسمية
  final String? hint;                     // نص توجيهي
  final String? prefixText;               // نص قبل الإدخال (مثل "+212")
  final IconData? prefixIcon;             // أيقونة يمين (مثل Icons.email)
  final TextInputType keyboardType;       // نوع لوحة المفاتيح
  final bool isPassword;                  // كلمة مرور؟
  final bool hasError;                    // حالة خطأ
  final String? errorText;                // نص الخطأ
  final bool hasSuccess;                  // حالة نجاح
  final TextEditingController? controller;
  final String? Function(String?)? validator;  // للـ Form
}

// خصائص ثابتة:
// - الارتفاع: 52px
// - زوايا: 10px (BorderRadius.circular(10))
// - Padding داخلي: 16px أفقي، 14px عمودي
// - Border: InputBorder.none (نستخدم Container مع BoxDecoration)
// - FontSize: 16px
```

---

## 2. PrimaryButton + SecondaryButton

### الهيكل البصري

```
Primary Button (ممتلئ):
┌──────────────────────────────────────┐
│  سجّل برقم هاتفك                     │  ← ارتفاع 56px, خلفية #0D9488
└──────────────────────────────────────┘  ← نص أبيض, 18px, Medium 500
                                            زوايا 12px

Secondary Button (إطار):
┌──────────────────────────────────────┐
│  📧 سجّل بحساب Google                │  ← ارتفاع 56px, إطار #0D9488 2px
└──────────────────────────────────────┘  ← نص #0D9488, 16px, Medium 500
                                            زوايا 12px, أيقونة 24px

Text Button:
سجّل الدخول  ← نص #0D9488, 16px, Medium 500
```

### حالات الأزرار

```
Primary Button:
┌──────────────────────────┐    ┌──────────────────────────┐
│     Normal (#0D9488)     │    │     Hover (#0F766E)      │
└──────────────────────────┘    └──────────────────────────┘

┌──────────────────────────┐    ┌──────────────────────────┐
│     Pressed (scale 0.97) │    │   Disabled (#D1D5DB)    │
└──────────────────────────┘    └──────────────────────────┘
                                    نص #9CA3AF
```

### مواصفات Flutter

```dart
// Primary Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,          // #0D9488
    disabledBackgroundColor: Color(0xFFD1D5DB),
    foregroundColor: Colors.white,
    disabledForegroundColor: Color(0xFF9CA3AF),
    minimumSize: Size(double.infinity, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
  ),
  onPressed: enabled ? () {} : null,
  child: Text(buttonText),
)

// Secondary Button
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: AppColors.primary, width: 2),
    foregroundColor: AppColors.primary,
    minimumSize: Size(double.infinity, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  ),
  onPressed: () {},
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 24),
      SizedBox(width: 8),
      Text(buttonText),
    ],
  ),
)
```

---

## 3. OTPInput (6 خانات)

### الهيكل البصري

```
┌──────────────────────────────────────┐
│  أدخل رمز التأكيد                    │  ← تسمية
│  تم إرسال الرمز إلى +212 6XX XX XX  │  ← Body, #6B7280
│                                      │
│  [1] [2] [3] [4] [5] [6]            │  ← 6 مربعات, 48×56px
│  ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐          │     إطار #D1D5DB
│  │1│ │2│ │3│ │ │ │ │ │ │          │     زوايا 10px
│  └─┘ └─┘ └─┘ └─┘ └─┘ └─┘          │     لا TextCursor
│                                      │
│  [إعادة إرسال الرمز بعد 30 ثانية]   │  ← Caption, #6B7280
│  [تغيير الرقم] ← Link                │
│                                      │
│  ┌──────────────────────────────┐   │
│  │  تأكيد                        │   │  ← Primary Button
│  └──────────────────────────────┘   │  (معطل حتى تكتمل 6 أرقام)
└──────────────────────────────────────┘
```

### حالات OTPInput

```
حالة: رقم مدخل
  ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐
  │1│ │2│ │3│ │4│ │ │ │ │    ← الرقم الرابع ممتلئ
  └─┘ └─┘ └─┘ └─┘ └─┘ └─┘    ← الخامس فاضي مع cursor

حالة: خطأ
  ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐
  │1│ │2│ │3│ │4│ │5│ │6│
  └─┘ └─┘ └─┘ └─┘ └─┘ └─┘    ← إطار #EF4444, اهتزاز (shake)
  
حالة: نجاح
  ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐
  │1│ │2│ │3│ │4│ │5│ │6│
  └─┘ └─┘ └─┘ └─┘ └─┘ └─┘    ← إطار #10B981, fade → انتقال
```

### مواصفات Flutter

```dart
// lib/core/widgets/otp_input.dart
class OtpInput extends StatefulWidget {
  final int length;                     // 6
  final Function(String)? onCompleted;  // استدعاء عند اكتمال 6 أرقام
  final bool hasError;                  // حالة خطأ
  final bool isSubmitting;              // حالة إرسال (عرض CircularProgress)
  
  // سلوك:
  // - كل خانة: TextFormField مع maxLength=1, textAlign=center
  // - عند الإدخال: انتقل تلقائياً للحقل التالي (FocusScope)
  // - عند الحذف: ارجع للحقل السابق
  // - Paste من الحافظة: وزّع الأرقام على الـ 6 خانات
  // - الـ keyboard type: TextInputType.number
}

// أبعاد:
// - عرض الخانة: 48px (أو (ScreenWidth - 48px padding - 5*8px gap) / 6
// - ارتفاع الخانة: 56px
// - المسافة بين الخانات: 8px
```

---

## 4. PasswordInput مع إظهار/إخفاء

### الهيكل البصري

```
┌──────────────────────────────────────┐
│  كلمة المرور                          │
│ ┌──────────────────────────────────┐ │
│ │ •••••••••••               👁️    │ │  ← أيقونة العين يمين
│ └──────────────────────────────────┘ │  ← إطار #D1D5DB
│  "كلمة المرور يجب أن تكون 8 أحرف + "│  ← رسالة مساعدة, #6B7280
└──────────────────────────────────────┘

عند الضغط على العين:
┌──────────────────────────────────────┐
│  كلمة المرور                          │
│ ┌──────────────────────────────────┐ │
│ │ MyP@ssw0rd                 👁️‍🗨️ │ │  ← أيقونة العين مشطوبة
│ └──────────────────────────────────┘ │  ← النص يظهر عادي
└──────────────────────────────────────┘
```

### متطلبات كلمة المرور (Validation)

```
□ 8 أحرف على الأقل      □ حرف كبير (A-Z)
□ رقم (0-9)             □ رمز خاص (@, #, $, !, etc)

┌──────────────────────────────────────┐
│ ✅ 8 أحرف على الأقل                  │  ← أخضر إذا تحقق
│ ✅ حرف كبير (A-Z)                    │
│ ❌ رقم (0-9)                         │  ← أحمر إذا لم يتحقق
│ ❌ رمز خاص                           │
└──────────────────────────────────────┘
```

### مواصفات Flutter

```dart
// PasswordInput extends AppTextField مع isPassword=true
class PasswordInput extends StatefulWidget {
  final TextEditingController? controller;
  final bool hasError;
  final String? errorText;
  final bool showValidation;  // إظهار متطلبات كلمة المرور
}

// السلوك:
// - obscureText: true (افتراضي)
// - suffixIcon: Icons.visibility / Icons.visibility_off
// - عند النقر على الأيقونة: toggle obscureText
// - Animasyon: Crossfade بين النقط والنص
```

---

## 5. مكونات Auth الإضافية

### 5.1 Auth Divider

```
  ──────── أو ─────────
  
  Row: [Divider] - "أو" - [Divider]
  Divider: Container(height: 1, color: #E5E7EB)
  نص "أو": 14px, #6B7280, padding أفقي 16px
```

### 5.2 Social Auth Button

```
┌──────────────────────────────────────┐
│  📧 سجّل بحساب Google               │  ← أيقونة 24px في اليسار
└──────────────────────────────────────┘  ← Secondary Button style

┌──────────────────────────────────────┐
│  سجّل بحساب Facebook                 │  ← أيقونة 24px في اليسار
└──────────────────────────────────────┘  ← لون Facebook #1877F2 (اختياري)
```

### 5.3 Phone Prefix

```
┌──────────────────────────────────────┐
│  رقم الهاتف                           │
│ ┌──────────────────────────────────┐ │
│ │ 🇲🇦 +212 | 6XX XX XX XX        │ │  ← علم المغرب + "+212"
│ └──────────────────────────────────┘ │  → افتراضي. اختياري: Dropdown
└──────────────────────────────────────┘  لاختيار كود دولة آخر
```

### 5.4 Link (Text Button)

```
سجّل الدخول        ← TextButton, 16px, Medium 500, #0D9488
ليس لديك حساب؟  سجّل    ← Text + Link
```

---

## 6. Summary — قائمة الـ Widgets لـ Flutter

| Widget | الملف المقترح | الحالات (Variants) |
|--------|--------------|-------------------|
| `AppTextField` | `core/widgets/app_text_field.dart` | normal, focus, error, success, disabled |
| `PrimaryButton` | `core/widgets/primary_button.dart` | normal, hover, pressed, disabled, loading |
| `SecondaryButton` | `core/widgets/secondary_button.dart` | normal, hover, pressed, disabled |
| `TextButton` | `core/widgets/app_text_button.dart` | normal, hover, disabled |
| `OtpInput` | `core/widgets/otp_input.dart` | normal, error, success, submitting |
| `PasswordInput` | `core/widgets/password_input.dart` | normal, focus, error, success |
| `AuthDivider` | `core/widgets/auth_divider.dart` | — |
| `SocialAuthButton` | `core/widgets/social_auth_button.dart` | google, facebook |
| `PhoneWithPrefix` | `core/widgets/phone_input.dart` | normal, focus, error, success |

---

— ليلى السعد | UI/UX Designer
