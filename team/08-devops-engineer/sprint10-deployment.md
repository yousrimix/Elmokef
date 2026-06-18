# 📋 تقرير Sprint 10 — Beta Launch Readiness
## DevOps Engineer — ياسر القحطاني
**التاريخ:** 18 يونيو 2026  
**الحالة:** 📝 قيد التحليل — التوصيات النهائية

---

## 1. 🏗️ Overview — نظرة عامة على الموقف الحالي

### 1.1 ما هو جاهز ✅

| المكون | الحالة | ملاحظات |
|--------|--------|---------|
| **Docker Compose Production** | ✅ جاهز | `docker-compose.prod.yml` — يشمل PostGIS, Redis, ClamAV, Backend, Nginx, Certbot |
| **Nginx API Config** | ✅ جاهز | api.elmokef.ma — SSL, HSTS, Rate Limiting, CMI Webhook IP Restriction, WebSocket |
| **Nginx Admin Config** | ✅ جاهز | admin.elmokef.ma — SPA مع Cache للصور، Proxy API |
| **SSL Setup Script** | ✅ جاهز | Let's Encrypt + Certbot — تجديد تلقائي كل 12 ساعة |
| **Admin Deploy Script** | ✅ جاهز | `deploy-admin.ps1` — Build → Copy → Reload Nginx |
| **CMI Sandbox Setup** | ✅ جاهز | اتصال Sandbox + Secrets generation + Webhook configuration |
| **Dockerfile Admin** | ✅ جاهز | Multistage build: Node 22 Build → Nginx 1.27 Run |

### 1.2 ما هو مفقود أو ناقص ⚠️

| المكون | الحالة | الخطة |
|--------|--------|-------|
| **GitHub Actions CI/CD** | ❌ غير موجود | لا يوجد `.github/workflows/` — كل النشر حاليًا يدوي (PowerShell scripts) |
| **Staging Environment** | ❌ غير موجود | لا توجد بيئة Staging منفصلة — Sprint 9 يتطلبها |
| **Monitoring Stack** | ❌ غير موجود | لا Prometheus، Grafana، Loki، Alerting — مطلوب لـ Sprint 10 |
| **Backup Strategy** | ❌ غير موثق | لا يوجد سكريبت للـ Backup/Restore — مطلوب RTO < 4 ساعات |
| **Production .env & Secrets** | ⚠️ غير مكتمل | ملف `cmi-sandbox.env.example` موجود لكن بدون production vars |
| **Firebase/HMS/APNs Config** | ⚠️ قيد الإعداد | مطلوب لنظام الإشعارات (Sprint 8) |
| **Load Testing** | ❌ لم يبدأ | مطلوب مع Sprint 9 (k6 — 1000 user) |
| **CI/CD Pipeline** | ❌ لا يوجد | Build + Test + Deploy pipeline غير موجود |

---

## 2. 🐳 تحليل Docker Compose Production

### 2.1 الخدمات الحالية

| الخدمة | الصورة | الموارد | الحالة |
|--------|--------|---------|--------|
| **PostgreSQL + PostGIS** | `postgis/postgis:16-3.4` | 2G RAM, 1 CPU | ✅ جيد — 127.0.0.1 فقط |
| **Redis** | `redis:7-alpine` | 512M RAM, 0.5 CPU | ✅ جيد — Append Only + Password |
| **ClamAV** | `clamav/clamav:latest` | 2G RAM, 1 CPU | ⚠️ `latest` — يفضل تحديد إصدارة محددة |
| **Backend (NestJS)** | `ghcr.io/elmokef-ma/backend:${TAG}` | 1G RAM, 1 CPU | ✅ جيد — Secrets عبر Docker Secrets |
| **Nginx** | `nginx:1.27-alpine` | 256M RAM, 0.25 CPU | ✅ جيد |
| **Certbot** | `certbot/certbot:latest` | - | ⚠️ `latest` — يفضل pinning |

### 2.2 ملاحظات أمنية

| الملاحظة | المستوى | التوصية |
|----------|---------|---------|
| ClamAV `latest` | 🟡 Medium | Pin to: `clamav/clamav:1.4.1` |
| Certbot `latest` | 🟡 Medium | Pin to: `certbot/certbot:v3.0.1` |
| استخدام Docker Secrets | 🟢 Good | JWT, DB Password, CMI Keys كلها عبر Secrets |
| Redis Password مكشوف في compose | 🟡 Medium | استخدام Docker Secret بدل env var |
| **لا يوجد Healthcheck لـ Certbot** | 🟡 Medium | أضف healthcheck بسيط |
| **لا يوجد Log Rotation لـ Postgres/Redis** | 🟡 Medium | أضف logging config مشابه للـ Backend |

---

## 3. 🌐 تحليل Nginx

### 3.1 النقاط القوية

- ✅ **HSTS** مفعل مع `max-age=31536000; includeSubDomains; preload`
- ✅ **Rate Limiting** — 100 req/min للـ API العامة، 60 req/min للـ Admin API
- ✅ **CMI Webhook IP Restriction** — سماح فقط بعناوين CMI في المغرب
- ✅ **WebSocket Proxy** — مهلة 86400 ثانية (24 ساعة)
- ✅ **تمنيع الملفات المخفية** — deny all
- ✅ **Let's Encrypt مع Certbot**

### 3.2 نقاط الضعف

| المشكلة | الخطورة | التوصية |
|---------|---------|---------|
| **لا يوجد CSP Header** | 🟠 High | إضافة Content-Security-Policy |
| **لا يوجد `server_tokens off;` في http block** | 🟡 Medium | إخفاء إصدار Nginx |
| **لا يوجد Connection: close للطلبات غير الآمنة** | 🟢 Low | تحسين أمني بسيط |
| **لا يوجد rate limiting للـ WebSocket** | 🟡 Medium | WebSocket قد يكون هدفًا لـ DDoS |
| **لا يوجد location للـ Deny خارج الـ IP restriction العام** | 🟡 Medium | حماية إضافية للـ Well-Known |

### 3.3 توصيات CSP
```
add_header Content-Security-Policy "
    default-src 'self';
    script-src 'self' https://app.elmokef.ma;
    style-src 'self' 'unsafe-inline';
    img-src 'self' data: https://*.tile.openstreetmap.org;
    connect-src 'self' https://api.elmokef.ma wss://api.elmokef.ma;
    frame-ancestors 'none';
    base-uri 'self';
" always;
```

---

## 4. 🔄 تحليل CI/CD Pipeline

### 4.1 الوضع الحالي

| العنصر | الحالة | التفاصيل |
|--------|--------|----------|
| GitHub Actions | ❌ غير موجود | لا يوجد `.github/workflows/` |
| Docker Registry | ✅ موجود | ghcr.io/elmokef-ma/backend — لكن لا CI يبني ويدفع |
| Deploy Automation | ⚠️ جزئي | سكريبتات PowerShell موجودة لكن يدوية 100% |
| Testing in CI | ❌ غير موجود | لا اختبارات في الـ Pipeline |

### 4.2 سكريبتات النشر الحالية

| السكريبت | الوظيفة | النوع |
|----------|---------|-------|
| `deploy-admin.ps1` | بناء Admin → نسخ → Reload Nginx | يدوي |
| `setup-cmi-sandbox.ps1` | إعداد CMI Sandbox (secrets + اتصال) | يدوي |
| `setup-ssl.ps1` | إصدار شهادة SSL + تحقق DNS | يدوي |

### 4.3 CI/CD Pipeline المقترحة (GitHub Actions)

#### Pipeline 1: Backend CI
```yaml
# .github/workflows/backend-ci.yml
on:
  push:
    branches: [main, develop]
    paths: ['backend/**']

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - npm ci
      - npm run lint
      - npm run test:cov
      - npm run build

  docker:
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - docker build . -t ghcr.io/elmokef-ma/backend:${{ github.sha }}
      - docker push ghcr.io/elmokef-ma/backend:${{ github.sha }}
      - docker tag ... :latest
      - docker push ... :latest
```

#### Pipeline 2: Backend Deploy
```yaml
# .github/workflows/backend-deploy.yml
on:
  workflow_run:
    workflows: ["Backend CI"]
    types: [completed]
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - ssh deploy@server "cd /app && docker compose pull backend && docker compose up -d backend"
```

#### Pipeline 3: Admin Panel Deploy
```yaml
# .github/workflows/admin-deploy.yml
on:
  push:
    branches: [main]
    paths: ['elmokef-admin/**']

jobs:
  build-deploy:
    steps:
      - npm ci && npm run build
      - scp -r dist/ deploy@server:/var/www/admin.elmokef.ma
      - ssh deploy@server "docker exec elmokef-nginx-prod nginx -s reload"
```

---

## 5. 🚀 خطة Beta Launch — Sprint 10

### 5.1 المهام قبل الإطلاق

#### الأسبوع 1 (26 أكتوبر — 30 أكتوبر) — تهيئة البنية التحتية

| # | المهمة | الأولوية | الوقت المقدر | التبعية |
|---|--------|----------|-------------|---------|
| 1 | 🖥️ **شراء خادم Hetzner** (CX32 أو AX102) مع Ubuntu 24.04 | 🔴 حرجة | يوم | لا شيء |
| 2 | 🛡️ **تثبيت Docker + Docker Compose** على الخادم | 🔴 حرجة | 2 ساعات | #1 |
| 3 | 🔗 **إعداد Domain DNS** (api.elmokef.ma, admin.elmokef.ma, app.elmokef.ma) | 🔴 حرجة | يوم | #1 |
| 4 | 🌐 **إصدار شهادات SSL** (Let's Encrypt) للمجالات الثلاثة | 🔴 حرجة | 4 ساعات | #3 |
| 5 | 🔐 **إعداد Secrets الإنتاجية** (JWT, DB Password, CMI Production Keys) | 🔴 حرجة | 2 ساعات | #2 |
| 6 | 🐳 **تشغيل Docker Compose Production** (PostGIS + Redis + ClamAV + Backend + Nginx + Certbot) | 🔴 حرجة | 4 ساعات | #4, #5 |
| 7 | 🔄 **إعداد GitHub Actions CI/CD** (Backend CI → Docker Build → Deploy) | 🔴 حرجة | يوم | #2 |
| 8 | 💾 **إعداد Backup Strategy** (pg_dump + Backblaze B2 + cron) | 🟡 عالية | 4 ساعات | #6 |
| 9 | 📦 **إعداد Staging Environment** (Docker Compose منفصل أو نفس الخادم بمنفذ مختلف) | 🟡 عالية | 4 ساعات | #2 |

#### الأسبوع 2 (2 نوفمبر — 6 نوفمبر) — المراقبة + الإطلاق

| # | المهمة | الأولوية | الوقت المقدر | التبعية |
|---|--------|----------|-------------|---------|
| 10 | 📊 **إعداد Monitoring Stack** (Prometheus + Grafana + Loki + cAdvisor) | 🔴 حرجة | يوم | #6 |
| 11 | 🔔 **إعداد Alerting** (Telegram Bot + Email للتنبيهات الحرجة) | 🔴 حرجة | 4 ساعات | #10 |
| 12 | 🔍 **إعداد Uptime Monitoring** (Uptime Kuma أو Checkly) | 🔴 حرجة | 2 ساعات | #6 |
| 13 | 🏋️ **اختبار تحميل** (k6 — 1000 مستخدم وهمي على الـ API) | 🔴 حرجة | يوم | #6 |
| 14 | 🧪 **اختبار استرجاع النسخ الاحتياطي** (RTO < 4 ساعات) | 🔴 حرجة | 4 ساعات | #8 |
| 15 | 📱 **نشر Flutter Beta** عبر Firebase App Distribution + TestFlight | 🟡 عالية | 4 ساعات | #2 |
| 16 | ⚡ **تفعيل Cloudflare** (DNS, CDN, DDoS Protection, WAF) | 🟡 عالية | 4 ساعات | #3 |
| 17 | ☁️ **إعداد Backblaze B2** لتخزين الصور والملفات | 🟡 عالية | 2 ساعات | #6 |
| 18 | 🔄 **اختبار الإشعارات** (FCM + HMS + APNs) في الإنتاج | 🟡 عالية | 4 ساعات | #6 |
| 19 | 📝 **إنشاء Runbook** (خطوات استرجاع الحالات الطارئة) | 🟡 عالية | 4 ساعات | #8, #10 |
| 20 | ✅ **Final Go/No-Go** — اختبار شامل (Smoke Test) | 🔴 حرجة | 2 ساعات | #1–19 |

### 5.2 Go/No-Go Checklist

قبل الإطلاق، تأكد من:

- [ ] ✅ **كل الخدمات شغالة**: `docker compose ps` — كل containers UP
- [ ] ✅ **SSL سليم**: `https://api.elmokef.ma/health` — 200 OK + شهادة صالحة
- [ ] ✅ **Database**: PostgreSQL قابلة للاتصال + بيانات أولية موجودة
- [ ] ✅ **Redis**: ping → PONG
- [ ] ✅ **CMI Sandbox**: اتصال + Webhook يشتغل
- [ ] ✅ **Backup**: اختبار استرجاع ناجح
- [ ] ✅ **Monitoring**: Grafana تعرض Métriques
- [ ] ✅ **Alerting**: Telegram Bot أرسل رسالة اختبار
- [ ] ✅ **CI/CD**: Pull + Deploy يشتغل
- [ ] ✅ **Load Test**: 1000 concurrent users → Error Rate < 1%
- [ ] ✅ **DNS**: api / admin / app → IP الصحيح
- [ ] ✅ **Cloudflare**: Proxied ✅ + WAF شغال
- [ ] ✅ **Flutter Beta**: رابط Firebase App Distribution + TestFlight مشترك

---

## 6. 💰 تكاليف البنية التحتية (تقدير شهري)

| الخدمة | الاستخدام | التكلفة (€/شهر) |
|--------|-----------|-----------------|
| **Hetzner CX32** (4 vCPU, 8GB RAM, 160GB NVMe) | خادم الإنتاج | ~€15 |
| **Hetzner AX102** (8 vCPU, 32GB RAM, 2×512GB NVMe) | خادم الإنتاج + Staging | ~€35 |
| **Cloudflare Pro** | CDN + WAF + DDoS | ~€20 |
| **Backblaze B2** | تخزين صور + Backups (~50GB) | ~€1 |
| **Google Firebase** | FCM + Performance + Crashlytics | مجاني (Spark) |
| **GitHub Actions** | CI/CD (2000 min/month) | مجاني |
| **Let's Encrypt** | SSL Certificates | مجاني |
| **Uptime Kuma** | Monitoring (self-hosted) | مجاني |
| **Prometheus + Grafana** | Monitoring (self-hosted) | مجاني |
| **الإجمالي** | | **~€36–€56/شهر** |

---

## 7. 🗺️ خريطة الطريق DevOps (Sprints 1–10)

```
Sprint 1 (22 Jun – 3 Jul)       ← نحن هنا
  ├── إعداد Docker Compose للمطور
  ├── GitHub Actions (Backend CI)
  └── Dockerfile (Backend)

Sprint 2–6 (6 Jul – 11 Sep)
  ├── تطوير مستمر (CI يبني ويختبر)
  └── Docker Build لكل Push

Sprint 7 (14 Sep – 25 Sep)
  ├── CMI Integration — إعداد Secrets + Webhook
  ├── Docker Compose Production
  └── SSL Setup

Sprint 8 (28 Sep – 9 Oct)
  ├── Admin Panel Dockerfile
  ├── Nginx Config (api + admin)
  └── Admin Deploy Script

Sprint 9 (12 Oct – 23 Oct)      ← الـ Gate
  ├── Staging Environment
  ├── Backup + Restore Test
  ├── Load Testing (k6)
  └── HMS Integration

Sprint 10 (26 Oct – 6 Nov)      ← Beta Launch 🚀
  ├── Production Server Setup
  ├── Monitoring Stack
  ├── Alerting
  ├── Cloudflare + CDN
  ├── Flutter Beta Distribution
  └── Final Go/No-Go
```

---

## 8. ⚠️ المخاطر والتوصيات

### المخاطر الحرجة

| # | الخطر | التأثير | التخفيف |
|---|-------|---------|---------|
| 🔴 | **لا CI/CD حالياً** — النشر اليدوي يزيد وقت الإصلاح | خطأ بشري، وقت توقف طويل | بناء CI/CD فوراً — #1 Priority |
| 🔴 | **لا Staging** — اختبار مباشر على Production | كوارث محتملة | إعداد Staging في Sprint 9 |
| 🔴 | **لا Backup Restore Tested** | فقدان بيانات | اختبار استرجاع في Sprint 9 |
| 🟡 | **ClamAV + Certbot على `latest`** | تغيير مفاجئ في الصورة | Pin الإصدارات |
| 🟡 | **Redis Password في compose** | تسرب | نقل إلى Docker Secret |
| 🟡 | **لا CSP Headers** | XSS محتمل | إضافة CSP في Sprint 10 |

### التوصيات النهائية

1. **أولوية قصوى:** بناء GitHub Actions CI/CD قبل أي شيء آخر
2. **أولوية عالية:** إعداد Staging Environment في أقرب وقت
3. **أولوية عالية:** اختبار استرجاع النسخ الاحتياطي (RTO < 4h)
4. **تحسين أمني:** إضافة CSP + إخفاء إصدار Nginx
5. **تحسين أمني:** نقل Redis Password إلى Docker Secret
6. **نشر:** شراء Hetzner مبكرًا لتجنب التأخير

---

## 9. ✅ الخلاصة

| البند | الحالة |
|-------|--------|
| **جاهزية البنية التحتية الإنتاجية** | ⚠️ 65% — تحتاج CI/CD + Monitoring |
| **جاهزية الـ Deployment Scripts** | ✅ 80% — PowerShell scripts تحتاج التطوير |
| **جاهزية الـ Docker Compose** | ✅ 85% — إصلاحات أمنية بسيطة |
| **جاهزية الـ Nginx** | ✅ 90% — يحتاج CSP |
| **جاهزية الـ SSL** | ✅ 100% — Let's Encrypt + Auto-renewal |
| **جاهزية الـ CMI Integration** | ✅ 90% — Sandbox جاهز، Production يحتاج مفاتيح |
| **جاهزية الـ Monitoring** | ❌ 0% — غير موجود، يحتاج بناء |
| **جاهزية الـ CI/CD** | ❌ 0% — غير موجود، يحتاج بناء |
| **جاهزية الـ Backup** | ❌ 0% — غير موجود، يحتاج بناء |
| **جاهزية الإطلاق (Sprint 10)** | **⚠️ 35% — عمل كبير مطلوب** |

### الخطوات الفورية (اليوم)

1. إنشاء `E:\charika\infra\.github\workflows\backend-ci.yml`
2. إعداد GitHub Secrets للمشروع
3. بناء Docker Image ورفعه إلى ghcr.io يدويًا (كبداية)
4. شراء خادم Hetzner CX32 للتجارب

---

*تم إعداد التقرير بواسطة ياسر القحطاني — DevOps Engineer*
*تاريخ: 18 يونيو 2026*
