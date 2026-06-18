# خطة بناء Elmokef — الخطوات التفصيلية

---

## المرحلة 1: تحليل Business Analyst — سارة الخالد
| الخطوة | الوصف | المخرج |
|--------|-------|--------|
| 1.1 | مقابلة العميل لاستيضاح التفاصيل | قائمة أسئلة مجابة |
| 1.2 | تحليل السوق والمنافسين | تقرير تنافسي |
| 1.3 | تحديد User Personas (عميل + حرفي) | شخصيات مستخدمين |
| 1.4 | كتابة User Stories لكل Feature | Product Backlog |
| 1.5 | رسم Business Flow Diagram | مخطط تدفق الأعمال |
| 1.6 | تحديد المتطلبات الوظيفية (Functional) | FRD Document |
| 1.7 | تحديد المتطلبات غير الوظيفية (Non-Functional) | NFR Document |
| 1.8 | تقدير الجهد الأولي (Effort Estimation) | تقرير تقديري |

## المرحلة 2: النقاش الداخلي — كل الفريق
| الخطوة | الوصف | المخرج |
|--------|-------|--------|
| 2.1 | عرض تحليل BA على الفريق | Meeting Notes |
| 2.2 | كل عضو يطرح مخاوفه وملاحظاته | آراء مسجلة |
| 2.3 | مناقشة الاختلافات وطرح حلول | قرارات النقاش |
| 2.4 | الخروج بتوصيات موحدة | Recommendations |

## المرحلة 3: البنية التقنية — د. أحمد النجار
| الخطوة | الوصف | المخرج |
|--------|-------|--------|
| 3.1 | اختيار Tech Stack النهائي | Tech Stack Document |
| 3.2 | تصميم System Architecture | Component Diagram |
| 3.3 | تصميم Data Flow | Data Flow Diagram |
| 3.4 | تحديد APIs الرئيسية | API List |
| 3.5 | Scalability Strategy | تقرير قابلية التوسع |
| 3.6 | اختيار خريطة (Google Maps vs OSM) | تقرير مقارنة خرائط |
| 3.7 | خطة الأمان الأولية | Security Blueprint |

## المرحلة 4: خطة التنفيذ — عمر الحسيني
| الخطوة | الوصف | المخرج |
|--------|-------|--------|
| 4.1 | تقسيم المشروع إلى Sprints | Sprint Plan |
| 4.2 | تحديد MVP والميزات المؤجلة | Prioritized Backlog |
| 4.3 | وضع Timeline واقعي | Gantt Chart |
| 4.4 | توزيع الموارد البشرية | Resource Allocation |
| 4.5 | تحديد KPIs للمشروع | KPI Dashboard |
| 4.6 | خطة إدارة المخاطر | Risk Register |

## المرحلة 5: تصميم النظام — ليلى السعد
| الخطوة | الوصف | المخرج |
|--------|-------|--------|
| 5.1 | بحث المستخدم (User Research) | Research Report |
| 5.2 | User Journey Maps | Journey Maps |
| 5.3 | Wireframes (منخفضة الدقة) | Low-fi Wireframes |
| 5.4 | Wireframes (عالية الدقة) | Hi-fi Wireframes |
| 5.5 | تصميم الـ Design System | Colors, Typography, Icons |
| 5.6 | تصميم جميع الشاشات الرئيسية | Screens (Figma) |
| 5.7 | Prototype تفاعلي | Clickable Prototype |
| 5.8 | تسليم ملف التصميم للمطورين | Handoff Package |

## المرحلة 6: التطوير — خالد + محمد + نور
### 6.1 إعداد المشروع
| الخطوة | الوصف | المسؤول |
|--------|-------|---------|
| 6.1.1 | إنشاء Flutter project مع Clean Architecture | خالد |
| 6.1.2 | إنشاء NestJS project مع modular structure | محمد |
| 6.1.3 | إنشاء Database Schema وتشغيل PostgreSQL | نور |
| 6.1.4 | ربط repository GitHub وإدارة الفروع | خالد + محمد |

### 6.2 المصادقة والتسجيل (Authentication)
| 6.2.1 | واجهة تسجيل/تسجيل دخول (OTP) | خالد |
| 6.2.2 | API المصادقة (JWT + OTP) | محمد |
| 6.2.3 | جدول Users + ملف شخصي | نور |
| 6.2.4 | رفع وثائق الهوية (Image upload) | خالد + محمد |

### 6.3 اختيار الخدمة والموقع
| 6.3.1 | شاشة اختيار الخدمة (Categories) | خالد |
| 6.3.2 | شاشة تحديد الموقع (Map Integration) | خالد |
| 6.3.3 | API الخدمات والفئات | محمد |
| 6.3.4 | API الموقع الجغرافي والمسافات | محمد |
| 6.3.5 | جدول Services + Categories | نور |

### 6.4 خوارزمية الترتيب والحرفيين
| 6.4.1 | شاشة عرض الحرفيين (Sorted List) | خالد |
| 6.4.2 | Profile الحرفي (تفاصيل + تقييمات) | خالد |
| 6.4.3 | خوارزمية الترتيب (weights engine) | محمد |
| 6.4.4 | API البحث والتصفية (Filter) | محمد |
| 6.4.5 | Indexing وتحسين استعلامات الترتيب | نور |

### 6.5 الاتصال والمفضلة
| 6.5.1 | شاشة الاتصال بالحرفي (Call/Chat) | خالد |
| 6.5.2 | شاشة المفضلة (Favorites) | خالد |
| 6.5.3 | API الاتصال والرسائل | محمد |
| 6.5.4 | API المفضلة | محمد |
| 6.5.5 | جدول Favorites + Messages | نور |

### 6.6 التقييم والمراجعات
| 6.6.1 | شاشة إضافة تقييم + تعليق | خالد |
| 6.6.2 | API التقييمات | محمد |
| 6.6.3 | جدول Reviews + Triggers | نور |

### 6.7 نظام الاشتراكات
| 6.7.1 | شاشة الاشتراكات والخطط | خالد |
| 6.7.2 | API الدفع والاشتراكات | محمد |
| 6.7.3 | جدول Subscriptions + Payments | نور |

### 6.8 لوحة الإدارة (Admin Panel)
| 6.8.1 | لوحة إدارة المستخدمين | خالد |
| 6.8.2 | لوحة إدارة الحرفيين + مراجعة وثائق | خالد |
| 6.8.3 | لوحة إدارة الاشتراكات | خالد |
| 6.8.4 | لوحة الشكايات والإحصائيات | خالد |
| 6.8.5 | API لوحة الإدارة (Admin APIs) | محمد |

### 6.9 الإشعارات
| 6.9.1 | Push Notifications (Firebase) | خالد |
| 6.9.2 | Notification Service (Backend) | محمد |

## المرحلة 7: البنية التحتية — ياسر القحطاني
| الخطوة | الوصف | المخرج |
|--------|-------|--------|
| 7.1 | إعداد GitHub repository | Repository |
| 7.2 | CI/CD pipeline (GitHub Actions) | Pipeline |
| 7.3 | Dockerize التطبيق (Backend) | Dockerfile |
| 7.4 | إعداد خادم (VPS / Cloud) | Server |
| 7.5 | إعداد Domain + SSL | Secure HTTPS |
| 7.6 | إعداد بيئات (Dev / Staging / Prod) | Environments |
| 7.7 | Monitoring + Logging | Alerts Dashboard |

## المرحلة 8: الاختبار — رنا السعيد
| الخطوة | الوصف | المخرج |
|--------|-------|--------|
| 8.1 | كتابة Test Plan شامل | Test Plan Document |
| 8.2 | Test Cases للتسجيل والدخول | Test Cases |
| 8.3 | Test Cases للبحث والترتيب | Test Cases |
| 8.4 | Test Cases للاتصال والمفضلة | Test Cases |
| 8.5 | Test Cases للتقييمات والاشتراكات | Test Cases |
| 8.6 | Test Cases للوحة الإدارة | Test Cases |
| 8.7 | اختبارات الأداء (Load Testing) | Performance Report |
| 8.8 | اختبارات التوافق (Cross-platform) | Compatibility Report |
| 8.9 | تقرير الجودة النهائي | QA Report + Bugs |

## المرحلة 9: الأمان — فيصل المطيري
| الخطوة | الوصف | المخرج |
|--------|-------|--------|
| 9.1 | مراجعة OWASP Top 10 | OWASP Checklist |
| 9.2 | اختبار API Security | API Security Report |
| 9.3 | مراجعة Authentication & Authorization | Auth Review |
| 9.4 | اختبار اختراق (Penetration Test) | Pen Test Report |
| 9.5 | مراجعة تخزين البيانات والتشفير | Data Security Report |
| 9.6 | تقرير أمني + توصيات | Final Security Report |

## المرحلة 10: الإطلاق التسويقي — هدى المنصور
| الخطوة | الوصف | المخرج |
|--------|-------|--------|
| 10.1 | إعداد Profile App Store + Google Play | Store Assets |
| 10.2 | ASO (Keywords, Description, Screenshots) | ASO Package |
| 10.3 | خطة إعلانات (Meta / Google Ads) | Ads Plan |
| 10.4 | خطة تسويق مؤثر في المغرب | Influencer List |
| 10.5 | خطة محتوى (Social Media) | Content Calendar |
| 10.6 | خطة الإطلاق (Pre-launch / Launch / Post) | Launch Strategy |
| 10.7 | مؤشرات النجاح (KPIs) | KPI Targets |

---

**تم). الفريق ينتظر. متى تطلب بدء المرحلة الأولى؟**
