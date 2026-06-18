# Sprint 6 — Handoff كامل
**إعداد:** ليلى السعد — UI/UX Designer
**التسليم إلى:** خالد العمري (Flutter) + محمد العلي (Backend)

---

## 1. التسليمات

```
📁 sprint-06-reviews/
│
├── 01-review-rating-screen.md     ← شاشة التقييم (RV-01)
│                                    تعديل تقييم (RV-02)
│                                    منع مكرر + Star RTL Component
│                                    Push Notification design
│
├── 02-display-reviews.md          ← عرض التقييمات (RV-03, RV-04)
│                                    Empty State (RV-05)
│                                    API + Summary Distribution
│
├── 03-complaint-form-edge-cases.md ← نموذج شكوى (CP-01→CP-03)
│                                     إعادة تقييم
│                                     حظر مكرر
│                                     RTL Stars
│                                     Push + In-App Toast
│
└── 04-handoff.md (this)           ← تسليم المطورين
```

---

## 2. ملخص API Endpoints (لـ محمد)

| # | الطريقة | الـ Endpoint | الاستخدام | الأولوية |
|---|---------|-------------|-----------|---------|
| 1 | POST | `/api/v1/reviews` | إنشاء تقييم | Must |
| 2 | PUT | `/api/v1/reviews/:id` | تعديل تقييم (7 أيام) | Must |
| 3 | DELETE | `/api/v1/reviews/:id` | حذف تقييم (7 أيام) | Must |
| 4 | GET | `/api/v1/reviews/check` | منع مكرر + صلاحية التعديل | Must |
| 5 | GET | `/api/v1/artisans/:id/reviews` | قائمة تقييمات مع summary | Must |
| 6 | POST | `/api/v1/reviews/:id/reply` | رد الحرفي | Should |
| 7 | POST | `/api/v1/reports` | تقديم شكوى | Must |

---

## 3. مكونات Flutter (لـ خالد)

| المكون | الوصف | الحالات |
|--------|-------|---------|
| `StarRating` | 5 نجوم قابلة للنقر/عرض | empty, filled, half, hover, pressed, RTL |
| `ReviewCard` | بطاقة تقييم في القائمة | with reply, without reply |
| `ReviewSummary` | ملخص التقييم (avg + distribution) | has data, empty |
| `EmptyReviews` | حالة لا توجد تقييمات | default, filtered |
| `ComplaintForm` | نموذج شكوى مع dropdown + image | default, error, submitting |
| `ComplaintSuccess` | تأكيد تقديم الشكوى | success, fail |
| `DuplicateReviewDialog` | منع تقييم مكرر | can_edit, cannot_edit |
| `ReviewToast` | In-app notification | — |

---

## 4. الـ Assets

| الملف | الوصف | الصيغة |
|-------|-------|--------|
| `star_empty.svg` | نجمة فارغة | SVG 48×48 |
| `star_filled.svg` | نجمة مملوءة | SVG 48×48 |
| `star_half.svg` | نصف نجمة | SVG 48×48 |
| `review_empty.svg` | Illustration لا تقييمات | SVG 240×240 |
| `complaint_success.svg` | تأكيد شكوى | SVG 240×240 |
| `complaint_fail.svg` | فشل شكوى | SVG 240×240 |
| `duplicate_warning.svg` | تحذير مكرر | SVG 240×240 |

---

## 5. الـ StarRating Component (مفصّل لخالد)

```dart
// lib/core/widgets/star_rating.dart
class StarRating extends StatefulWidget {
  final double rating;          // 0.0 – 5.0
  final int maxRating;          // 5
  final double size;            // 48 (كبير) / 32 (صغير)
  final bool interactive;       // true → قابل للنقر
  final ValueChanged<double>? onChanged;
  final MainAxisAlignment alignment; // center افتراضي

  // Internal state:
  // - _displayRating: double (لـ hover)
  // - _isHovering: bool
}

// Layout:
// Row(
//   mainAxisAlignment: widget.alignment,
//   children: List.generate(5, (index) {
//     return GestureDetector(
//       onTap: widget.interactive ? () => _onTap(index + 1.0) : null,
//       child: _buildStar(index),
//     );
//   }),
// )

// Star logic:
// - full: rating >= index + 1
// - half: rating >= index + 0.5
// - empty: rating < index + 0.5

// Animasyon (interactive):
// - نقر: AnimatedScale (1.0 → 1.3 → 1.0), 300ms spring
// - hover: تغيير لون النجمة مؤقتاً
```

---

## 6. قائمة التحقق النهائية

- [x] شاشة تقييم 5 نجوم + TextArea + زر إرسال
- [x] حالة نجاح ✅ مع رسالة شكر
- [x] حالة فشل ❌ مع إعادة المحاولة + حفظ محلي
- [x] تعديل تقييم (خلال 7 أيام)
- [x] حذف تقييم مع Confirm Dialog
- [x] منع تقييم مكرر (Duplicate Prevention)
- [x] Push Notification trigger (24h, 48h, 72h)
- [x] In-App Toast
- [x] عرض التقييمات في ملف الحرفي (Summary + Cards)
- [x] صفحة كل التقييمات (مع فلتر)
- [x] Empty State — لا تقييمات
- [x] Empty State — فلتر بدون نتائج
- [x] رد الحرفي على التقييم
- [x] نموذج شكوى (Dropdown, TextArea, Image)
- [x] تأكيد + فشل الشكوى
- [x] حفظ الشكوى كمسودة إذا فشل الإرسال
- [x] Star Rating RTL متوافق
- [x] API Endpoints محددة

---

— ليلى السعد | UI/UX Designer
