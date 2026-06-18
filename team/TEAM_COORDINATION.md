# 🧠 TEAM COORDINATION — الفريق المركزي

**تم الإنشاء:** 2026-06-18  
**المشرف:** خالد (AI Coordinator)  
**المشروع:** الموقف (El Mokef) — ربط الحرفيين وأصحاب الخدمات بالعملاء

---

## 🏗️ هيكل الفريق

| الوكيل | المعرف | الدور |
|--------|--------|-------|
| 🧠 **خالد** | `@coordinator` | توزيع المهام، المتابعة، التنسيق |
| 📱 **Flutter Dev** | `@flutter-agent` | تطوير الواجهات المحمولة |
| 🖥️ **Backend Dev** | `@backend-agent` | APIs + Prisma + NestJS |
| 🧪 **QA** | `@qa-agent` | اختبارات + تقارير أخطاء |
| 🐳 **DevOps** | `@devops-agent` | CI/CD + Docker + نشر |
| ⚛️ **React Admin** | `@react-agent` | لوحة الإدارة (Admin Panel) |

---

## 📋 خطة العمل المباشرة

### المرحلة الأولى: التقييم والتثبيت
- كل وكيل يقرأ الوضع الحالي في مجاله
- يحدد الـ gaps
- يقدم تقرير Sprint 10 Readiness

### المرحلة الثانية: التطوير
- Flutter: إكمال الوحدات المتبقية
- Backend: إنهاء APIs + تحسين الأداء
- QA: اختبارات شاملة
- DevOps: تجهيز البيئة الإنتاجية
- React Admin: تطوير لوحة الإدارة

### المرحلة الثالثة: الإطلاق
- Integration Testing
- Deployment
- Monitoring

---

## 📥 نظام Inbox/Outbox

كل وكيل عنده:
- `inbox.md` — المهام المستلمة
- `outbox.md` — التسليمات المنجزة
- `status.md` — تقرير الحالة

يقوم الوكيل بقراءة Inbox، تنفيذ المهمة، وكتابة الـ Outbox عند الانتهاء.

---

## ✅ معايير الجودة

1. `dart analyze` — 0 errors, 0 warnings (Flutter)
2. `nest build` — Compiled successfully (Backend)
3. All tests pass
4. Code review قبل الـ Merge
