# 📤 DevOps CI/CD — Outbox

**المشروع:** الموقف (El Mokef)  
**المسؤول:** DevOps Engineer  
**التاريخ:** 18 يونيو 2026  
**الحالة:** ✅ تم — جاهز للتطبيق

---

## 📦 الملفات المُنتجة

### 1. CI/CD Pipeline (GitHub Actions)

| الملف | الوصف | الحالة |
|-------|-------|--------|
| `.github/workflows/backend-ci.yml` | Build + Lint + Unit/E2E Tests + Coverage | ✅ جاهز |
| `.github/workflows/flutter-ci.yml` | Analyze + Tests + Debug/Release APK/AAB | ✅ جاهز |
| `.github/workflows/deploy.yml` | Docker Build → Push → SSH Deploy + Admin Deploy + Health Check | ✅ جاهز |

### 2. Dockerfile

| الملف | الوصف | الحالة |
|-------|-------|--------|
| `infra/docker/Dockerfile.backend` | Multistage: Node 22 Build → Distroless Run | ✅ أنشئ حديثاً |

### 3. Backup Strategy

| الملف | الوصف | الحالة |
|-------|-------|--------|
| `infra/scripts/backup.ps1` | pg_dump + Uploads archive → B2 + Retention + Telegram Alerting | ✅ جاهز |

💡 **ملاحظة:** أنشأت `Dockerfile.backend` لأنه لم يكن موجوداً (كان فقط `Dockerfile.admin`).

---

## 🚀 نشر GitHub Actions

### الخطوات الفورية

```bash
# 1. إنشاء أول Commit
cd E:\charika
git init
git add -A
git commit -m "Initial commit: full project structure + CI/CD"

# 2. ربط المستودع البعيد
git remote add origin https://github.com/elmokef-ma/elmokef.git
git branch -M main
git push -u origin main

# 3. إضافة GitHub Secrets للمستودع
```

### GitHub Secrets المطلوبة

| Secret Name | الوصف | إلزامي؟ |
|-------------|-------|---------|
| `GHCR_PAT` | GitHub PAT مع صلاحية `write:packages` لدفع الصور إلى ghcr.io | ✅ نعم |
| `DEPLOY_SSH_KEY` | مفتاح SSH الخاص للمستخدم `deploy@` على الخادم | ✅ نعم |
| `DEPLOY_HOST` | IP أو Hostname لخادم الإنتاج | ✅ نعم |
| `DEPLOY_USER` | اسم المستخدم SSH (مثلاً `deploy`) | ✅ نعم |
| `DB_PASSWORD` | كلمة مرور PostgreSQL (base64) | ✅ نعم |
| `JWT_SECRET` | مفتاح توقيع JWT (base64) | ✅ نعم |
| `JWT_REFRESH_SECRET` | مفتاح توقيع Refresh JWT (base64) | ✅ نعم |
| `CMI_STORE_KEY` | مفتاح متجر CMI (base64) | ✅ نعم |
| `CMI_MERCHANT_ID` | معرف التاجر CMI (base64) | ✅ نعم |
| `DOCUMENTS_ENCRYPTION_KEY` | مفتاح تشفير المستندات (base64) | ✅ نعم |
| `REDIS_PASSWORD` | كلمة مرور Redis | لل prod |
| `ANDROID_KEYSTORE_PATH` | مسار Keystore أندرويد | للـ Flutter release |
| `ANDROID_KEYSTORE_PASSWORD` | كلمة مرور Keystore | للـ Flutter release |
| `ANDROID_KEY_ALIAS` | Alias المفتاح | للـ Flutter release |
| `ANDROID_KEY_PASSWORD` | كلمة مرور المفتاح | للـ Flutter release |
| `SLACK_WEBHOOK` | Webhook Slack للإشعارات الفاشلة | اختياري |
| `B2_APPLICATION_KEY_ID` | مفتاح Backblaze B2 | للـ Backup |
| `B2_APPLICATION_KEY` | مفتاح التطبيق B2 | للـ Backup |
| `TELEGRAM_BOT_TOKEN` | توكن بوت تيليغرام | للـ Backup |
| `TELEGRAM_CHAT_ID` | معرف شات تيليغرام | للـ Backup |

---

## 📋 تفاصيل CI/CD Pipeline

### Pipeline 1: Backend CI (`backend-ci.yml`)

```
تسلسل التشغيل:
  push/PR → backend/** → main/develop

Jobs:
  ┌─────────────────────┐
  │ lint                │ ← Prettier check + ESLint + Prisma Generate
  └────────┬────────────┘
           ▼
  ┌─────────────────────┐
  │ test                │ ← Jest unit tests + Coverage (PostgreSQL + Redis services)
  └────────┬────────────┘
           ▼
  ┌─────────────────────┐
  │ build               │ ← NestJS build (dry-run — no image push)
  └────────┬────────────┘
           ▼
  ┌─────────────────────┐
  │ e2e                 │ ← فقط على main push — E2E tests
  └─────────────────────┘
```

**المدة المتوقعة:** ~5-8 دقائق

| الخطوة | الوقت التقريبي |
|--------|---------------|
| npm ci | ~60s |
| Prisma Generate | ~15s |
| Prettier check | ~10s |
| ESLint | ~20s |
| Unit Tests (~300 tests) | ~90s |
| NestJS Build | ~60s |
| E2E Tests | ~120s |

---

### Pipeline 2: Flutter CI (`flutter-ci.yml`)

```
تسلسل التشغيل:
  push/PR → almawqef/** → main/develop

Jobs:
  ┌─────────────────────┐
  │ analyze             │ ← flutter analyze
  └────────┬────────────┘
           ▼
  ┌─────────────────────┐
  │ test                │ ← flutter test --coverage
  └────────┬────────────┘
           ▼
  ┌─────────────────────┐
  │ build-apk           │ ← flutter build apk --debug (كل الـ pushes)
  └────────┬────────────┘
           ▼
  ┌─────────────────────┐
  │ build-release       │ ← فقط main push — release APK + AAB
  └─────────────────────┘
```

**المدة المتوقعة:** ~10-15 دقائق

---

### Pipeline 3: Deploy (`deploy.yml`)

```
تسلسل التشغيل:
  push main → backend/** | infra/docker/** | deploy.yml

Jobs:
  ┌───────────────────────┐
  │ build-and-push        │ ← Docker Buildx + Push to ghcr.io
  └───────────┬───────────┘
              ▼
  ┌───────────────────────┐
  │ deploy                │ ← SSH → docker compose pull + up -d backend
  └───────────┬───────────┘
              ▼
  ┌───────────────────────┐
  │ deploy-admin          │ ← (اختياري) إذا تغير elmokef-admin/
  └───────────┬───────────┘
              ▼
  ┌───────────────────────┐
  │ health-check          │ ← curl https://api.elmokef.ma/health + admin
  └───────────────────────┘
```

**روابط:** Docker Image → `ghcr.io/elmokef-ma/backend:latest` و `ghcr.io/elmokef-ma/backend:{sha}`

---

## 💾 تفاصيل Backup Strategy

### أنواع النسخ

| النوع | التوقيت | عدد النسخ المحتفظ بها | التنسيق |
|-------|---------|----------------------|---------|
| **Daily** | كل يوم (ما عدا الأحد والـ 1 من الشهر) | آخر 7 نسخ | pg_dump custom format (gz) |
| **Weekly** | كل يوم أحد | آخر 4 نسخ | pg_dump custom format (gz) |
| **Monthly** | أول يوم من الشهر | آخر 3 نسخ | pg_dump custom format (gz) + Uploads archive |

### مكونات النسخة

1. **قاعدة البيانات:** pg_dump (compressed custom format — يدعم parallel restore)
2. **ملفات الرفع:** `uploads/` directory (tar.gz)
3. **بيانات وصفية:** JSON مع معلومات النسخة والحجم والتوقيت

### إعداد cron job (Linux)

```bash
# /etc/cron.d/elmokef-backup

# Daily backup — 02:00 (حتى الأحد)
0 2 * * 1-6 deploy /opt/elmokef/scripts/backup.ps1 -Type daily 2>&1 | logger -t elmokef-backup

# Weekly backup — 03:00 كل أحد
0 3 * * 7 deploy /opt/elmokef/scripts/backup.ps1 -Type weekly 2>&1 | logger -t elmokef-backup

# Monthly backup — 04:00 أول يوم من الشهر
0 4 1 * * deploy /opt/elmokef/scripts/backup.ps1 -Type monthly 2>&1 | logger -t elmokef-backup

# Test restore (automated) — 05:00 كل أحد (بيئة Staging)
0 5 * * 7 deploy /opt/elmokef/scripts/restore-test.ps1 2>&1 | logger -t elmokef-restore-test
```

💡 **ملاحظة:** إذا كان الخادم Windows، استخدم Task Scheduler بدلاً من cron.

### استرجاع (Restore)

```bash
# 1. تحميل آخر نسخة من B2
aws s3 cp s3://elmokef-backups/database/elmokef-db-daily-YYYY-MM-DD-HHmmss.sql.gz /tmp/restore/ \
  --endpoint-url https://s3.eu-central-003.backblazeb2.com

# 2. فك الضغط
gunzip /tmp/restore/elmokef-db-*.sql.gz

# 3. استرجاع إلى قاعدة بيانات جديدة
pg_restore -U elmokef_user -d elmokef_restore --no-owner --no-privileges --verbose \
  /tmp/restore/elmokef-db-*.sql

# 4. التحقق
psql -U elmokef_user -d elmokef_restore -c "SELECT count(*) FROM users;"
```

### RTO (Recovery Time Objective) المتوقع

| السيناريو | RTO المتوقع | الخطة |
|-----------|-------------|-------|
| فشل قاعدة البيانات | < 30 دقيقة | pg_restore من آخر Daily Backup |
| فشل الخادم بالكامل | < 4 ساعات | شراء Hetzner جديد → Docker setup → restore |
| حذف بيانات عن طريق الخطأ | < 1 ساعة | Point-in-time recovery + latest backup |
| فشل الـ Disk | < 2 ساعات | استرجاع من B2 إلى خادم جديد |

---

## 📋 متطلبات الخادم (Production)

```
المتطلبات الأساسية:
├── Ubuntu 24.04 LTS
├── Docker 26+ & Docker Compose v2
├── Python 3 (لـ AWS CLI)
├── PowerShell 7+ (لـ backup.ps1)
├── AWS CLI v2 (لرفع النسخ إلى B2)
└── 50GB+ مساحة حرة /var/lib/docker/

المنافذ المفتوحة:
├── 22 (SSH — مقيد بـ key فقط)
├── 80 (HTTP → Nginx → 301 to HTTPS)
├── 443 (HTTPS → Nginx)
├── 5432 (PostgreSQL — 127.0.0.1 فقط)
├── 6379 (Redis — 127.0.0.1 فقط)
└── 3310 (ClamAV — 127.0.0.1 فقط)

أوامر التهيئة الأولية:
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose-v2 python3-pip
pip3 install awscli
sudo systemctl enable docker
sudo docker compose version
```

---

## 🔥 خطة العمل الفورية (للـ DevOps)

```
اليوم 1 — CI/CD Infrastructure
├── إنشاء GitHub Repository + Push
├── إضافة GitHub Secrets
├── اختبار backend-ci.yml — Pull Request
├── إضافة Dockerfile.backend إلى infra/
└── اختبار deploy.yml — push إلى main

اليوم 2 — Production Setup
├── شراء/تجهيز Hetzner خادم
├── تثبيت Docker + Docker Compose
├── إعداد Nginx + SSL
├── تشغيل Docker Compose Production
└── اختبار health endpoint

اليوم 3 — Backup + Monitoring
├── تثبيت AWS CLI على الخادم
├── إعداد B2 Bucket + Keys
├── جدولة backup.ps1 عبر cron
├── اختبار استرجاع النسخة
└── إعداد Telegram Bot للتنبيهات
```

---

## 🧪 كيف تختبر الـ Pipeline محلياً

```bash
# اختبار Backend CI (بدون Docker)
cd E:\charika\backend
npm ci
npx prisma generate
npm run lint
npm test
npm run build

# اختبار Flutter CI
cd E:\charika\almawqef
flutter pub get
flutter analyze
flutter test
flutter build apk --debug

# اختبار Backup يدوي
cd E:\charika\infra\scripts
# (شغّل على الخادم حيث Docker Compose شغال)
.\backup.ps1 -Type daily -DatabaseName elmokef
```

---

## 🔐 Security Notes

1. **GitHub Secrets:** لا تضع المفاتيح في `app.env` أو في أي ملف يتعقبه Git
2. **Docker Secrets:** كل المفاتيح الحساسة (JWT, DB Password, CMI Keys) تُمر عبر Docker Secrets، ليس env vars
3. **SSH Keys:** استخدم مفتاح SSH منفصل لكل خادم (ليس مفتاحك الشخصي)
4. **B2 Keys:** مفاتيح Backblaze B2 مخزنة في GitHub Secrets أو env vars على الخادم
5. **Encryption at rest:** قاعدة البيانات مشفرة على القرص (PostgreSQL TDE اختياري)
6. **Backup encryption:** النسخ الاحتياطي على B2 مشفر (Server-Side Encryption)

---

## ✅ CheckList — قبل المغادرة

- [ ] ✅ `backend-ci.yml` — Lint → Test → Build → E2E
- [ ] ✅ `flutter-ci.yml` — Analyze → Test → Build APK
- [ ] ✅ `deploy.yml` — Docker Build → Push → SSH Deploy
- [ ] ✅ `Dockerfile.backend` — Multistage Build (Node 22 → Distroless)
- [ ] ✅ `backup.ps1` — PG Dump → B2 → Retention → Telegram Alert
- [ ] ✅ هذه `outbox.md` — توثيق كامل لكل شيء
- [ ] ⬜ إضافة GitHub Secrets
- [ ] ⬜ رفع `.github/workflows/` إلى GitHub
- [ ] ⬜ تشغيل أول Pipeline ومراقبة النتيجة
- [ ] ⬜ إعداد cron لـ backup.ps1 على الخادم

---

*تم الإعداد بواسطة DevOps Builder — 18 يونيو 2026*
*El Mokef — Connecting Artisans. Building Trust.* 🇲🇦
