# 📥 DevOps Engineer — INBOX
## ياسر القحطاني — DevOps Engineer
**آخر تحديث:** 18 يونيو 2026
**الحالة:** 🟢 نشط

---

## 🏆 Sprint 1 — Infrastructure & Foundation (22 Jun – 3 Jul 2026)
*هدف Sprint 1: إعداد البنية التحتية الأساسية للمشروع*

### 🔴 مستوى حرج (P0) — يجب البدء فوراً

- [ ] **P0 — GitHub Actions CI/CD Pipeline**
  - بناء `backend-ci.yml` — Lint → Test → Build → Docker Push
  - بناء `backend-deploy.yml` — Deploy على الخادم عند Push إلى main
  - بناء `admin-deploy.yml` — Build Admin → Deploy → Nginx Reload
  - إضافة `deploy.yml` للنشر الآلي
  - رفعته إلى Github repo

- [ ] **P0 — Docker Compose للبيئة المحلية**
  - موجود: `E:\charika\backend\docker-compose.yml`
  - التأكد من أنه يشتغل مع PostGIS 16 و Redis و ClamAV
  - إضافة Healthchecks أينما نقصت

- [ ] **P0 — Dockerfile للإنتاج**
  - `E:\charika\infra\docker\Dockerfile.admin` موجود ✅
  - نحتاج `Dockerfile.backend` — Multistage: Build (Node 22) → Run (Distroless)
  - رفع الصور إلى ghcr.io/elmokef-ma/

### 🟡 مستوى عالي (P1)

- [ ] **P1 — إعداد ESLint + Prettier + Husky في الـ CI**
  - `npm run lint` → Fail CI إذا كان فيه Errors
  - `npm run format:check` → Fail CI إذا مش مفورمات

- [ ] **P1 — Secrets Management**
  - إنشاء secrets directory: `E:\charika\infra\docker\secrets\`
  - إعداد Docker Secrets لـ: JWT, DB Password, CMI Keys
  - إعداد GitHub Secrets للـ CI/CD

- [ ] **P1 — Nginx Configuration للإنتاج**
  - موجود: `admin.elmokef.ma.conf` ✅
  - موجود: `api.elmokef.ma.conf` ✅
  - إضافة CSP Headers للتطبيقين
  - إضافة HSTS preload

---

## 📋 Sprint 7 — Subscription & Payments (14 Sep – 25 Sep 2026)

### 🔴 مستوى حرج (P0)

- [ ] **P0 — CMI Payment Integration في الإنتاج**
  - إعداد CMI Production URL (pay.cmi.co.ma) في Nginx
  - Webhook IP Restriction للمحول الإنتاجي لـ CMI
  - اختبار Webhook End-to-End
  - تحديث `setup-cmi-sandbox.ps1` ليدعم الإنتاج

### 🟡 مستوى عالي (P1)

- [ ] **P1 — Docker Compose Production**
  - موجود: `E:\charika\infra\docker\docker-compose.prod.yml`
  - إضافة logging driver لجميع الخدمات (json-file, max-size 10m, max-file 3)
  - إضافة healthchecks للخدمات الناقصة (Certbot)
  - Pin ClamAV و Certbot إلى إصدارات محددة (ليس latest)

- [ ] **P1 — SSL Let's Encrypt**
  - موجود: `E:\charika\infra\scripts\setup-ssl.ps1`
  - إصدار شهادات SSL لـ api.elmokef.ma + admin.elmokef.ma + app.elmokef.ma
  - التأكد من Certbot Auto-Renewal

---

## 📋 Sprint 8 — Admin Panel & Notifications (28 Sep – 9 Oct 2026)

### 🔴 مستوى حرج (P0)

- [ ] **P0 — نشر Admin Panel**
  - استخدام `deploy-admin.ps1` — أول نشر يدوي
  - إعداد Nginx لـ admin.elmokef.ma
  - CI/CD للنشر التلقائي (كل Push إلى main)

### 🟡 مستوى عالي (P1)

- [ ] **P1 — Firebase Cloud Messaging**
  - إعداد FCM Server Key
  - إعداد HMS (Huawei Mobile Services)
  - إعداد APNs (Apple Push Notification service)

- [ ] **P1 — Subdomain DNS**
  - api.elmokef.ma → A Record
  - admin.elmokef.ma → A Record
  - app.elmokef.ma → A Record

---

## 📋 Sprint 9 — QA & Performance (12 Oct – 23 Oct 2026)

### 🔴 مستوى حرج (P0)

- [ ] **P0 — Staging Environment**
  - إعداد بيئة Staging (نفس Docker Compose Production لكن بمنفذ مختلف)
  - اسمها: `docker-compose.staging.yml` أو استخدام نفس compose مع `.env.staging`
  - قاعدة بيانات Staging منفصلة
  - SSL Let's Encrypt لـ staging subdomain

- [ ] **P0 — Backup Strategy**
  - إعداد pg_dump التلقائي يوميًا
  - رفع النسخ إلى Backblaze B2
  - اختبار استرجاع (RTO < 4 ساعات)

### 🟡 مستوى عالي (P1)

- [ ] **P1 — HMS Integration (Huawei)**
  - موجود في Inbox القديم (Sprint 9): إعداد agconnect-services.json
  - بناء APK مع HMS
  - اختبار الإشعارات على Huawei

- [ ] **P1 — Load Testing**
  - إعداد k6 scripts (1000 مستخدم وهمي)
  - اختبار API Latency (< 500ms)
  - اختبار Ranking Engine مع 500+ حرفي

---

## 📋 Sprint 10 — Beta Launch & Monitoring (26 Oct – 6 Nov 2026)

### 🔴 مستوى حرج (P0)

- [ ] **P0 — Production Server Setup**
  - شراء Hetzner CX32 أو AX102 مع Ubuntu 24.04
  - تثبيت Docker + Docker Compose
  - إعداد UFW + Fail2Ban

- [ ] **P0 — Monitoring Stack**
  - Prometheus (جمع metrics من Docker + Nginx + Node)
  - Grafana (Dashboard: CPU, RAM, Disk, API Latency, Error Rate, 4xx, 5xx)
  - Loki (مركزية logs الخدمات)
  - cAdvisor (مراقبة حاويات Docker)
  - Node Exporter (مراقبة الخادم)

- [ ] **P0 — Alerting**
  - Telegram Bot للتنبيهات الحرجة
  - تنبيهات: Down Service, High CPU/RAM, High Error Rate, SSL Expiry
  - Email Alerts (للأمور غير الحرجة)

- [ ] **P0 — Cloudflare Setup**
  - تفعيل CDN للملفات الثابتة
  - تفعيل WAF (OWASP Core Rule Set)
  - تفعيل DDoS Protection
  - SSL/TLS: Full (Strict)

- [ ] **P0 — Flutter Beta Distribution**
  - إعداد Firebase App Distribution (Android)
  - إعداد TestFlight (iOS)
  - إعداد CodePush/Shorebird للتحديثات السريعة

### 🟡 مستوى عالي (P1)

- [ ] **P1 — Backblaze B2 Storage**
  - إعداد S3-compatible bucket للصور والملفات
  - تكامل مع Nginx CDN
  - إعداد Expiration Policy للصور القديمة

- [ ] **P1 — Runbook**
  - توثيق: خطوات استرجاع Backup
  - توثيق: خطوات Rollback (Nginx, Backend, Admin)
  - توثيق: خطوات إعادة تشغيل الخدمات
  - توثيق: قائمة الـ Credentials ومكانها الآمن

- [ ] **P1 — Uptime Monitoring**
  - إعداد Uptime Kuma (self-hosted)
  - مراقبة: api.elmokef.ma, admin.elmokef.ma, app.elmokef.ma
  - مراقبة: SSL Expiry (30 يوم قبل الانتهاء)

- [ ] **P1 — Go/No-Go Checklist**
  - إعداد قائمة الفحص النهائي قبل الإطلاق
  - Smoke Test لكل خدمة

---

## 📝 مهام متكررة (Ongoing)

- [ ] **مراقبة GitHub Actions** — التأكد من أن الـ Pipelines تشتغل بدون مشاكل
- [ ] **مراجعة Docker Images** — تحديث الصور شهريًا (Security Patches)  
- [ ] **مراجعة Nginx Logs** — البحث عن هجمات أو أخطاء
- [ ] **اختبار SSL Expiry** — شهريًا
- [ ] **تحديث Secrets** — تغيير JWT Secrets شهريًا

---

## 🎯 الأولويات (مباشرة)

| الأولوية | المهمة | Sprint | الوقت المقدر |
|----------|--------|--------|-------------|
| 🥇 | GitHub Actions CI/CD (Backend CI) | Sprint 1 | ~8 ساعات |
| 🥇 | GitHub Actions CI/CD (Deploy Pipeline) | Sprint 1 | ~4 ساعات |
| 🥇 | Dockerfile.backend (Multistage Build) | Sprint 1 | ~2 ساعات |
| 🥈 | Docker Compose Production (إصلاحات وتحسينات) | Sprint 7 | ~4 ساعات |
| 🥈 | SSL Setup لجميع Subdomains | Sprint 7 | ~2 ساعات |
| 🥉 | Staging Environment | Sprint 9 | ~4 ساعات |
| 🥉 | Backup Script + Restore Test | Sprint 9 | ~4 ساعات |

---

## ✅ تسليمات سابقة (Sprint 9)

- [x] اختبار استرجاع النسخ الاحتياطي — ⏳ لم ينجز بعد (سيتم في Sprint 9)
- [x] بيئة Staging — ⏳ لم تنجز بعد (سيتم في Sprint 9)
- [x] HMS Integration (Huawei) — ⏳ لم تنجز بعد (سيتم في Sprint 9)

---

*آخر تحديث: 18 يونيو 2026 — ياسر القحطاني*
