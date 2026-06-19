# تقرير ربط Flutter بالـ Backend

**التاريخ:** 2026-06-18  
**المشروع:** Elmokef (الميقف)  
**الفريق:** Integration  

## 1. API URL والإعدادات

**الملف:** `lib/core/constants/api_constants.dart`

- ✅ الـ Base URL محدد كمتغير ثابت: `static const String baseUrl = '...'`
- ✅ جميع الـ Endpoints معرفة
- ✅ التوقيت: 30 ثانية
- ✅ Cache Duration: 5 دقائق

**ملاحظة:** الـ URL الحالي يستعمل Cloudflare Tunnel. يجب التأكد من أنه شغال أو تغييره لـ production URL عند النشر.

---

## 2. ApiClient و Dio

**الملف:** `lib/core/network/api_client.dart`

- ✅ Dio مهيأ مع `BaseOptions` (baseUrl, timeout, headers)
- ✅ Interceptors: Auth (Bearer token من localStorage/web أو secure storage), Logging, Error
- ✅ Token محفوظ فـ `window.localStorage` للـ Web وفـ `FlutterSecureStorage` للموبايل
- ✅ الطرق: get, post, put, delete, patch

---

## 3. تحليل الـ Models مقابل الـ Backend الحقيقي

### 3.1 UserModel ✅

**الملف:** `lib/features/auth/data/models/user_model.dart`

| الحقل | الـ Backend | الـ Model | الحالة |
|-------|-------------|-----------|--------|
| id | `"id"` | `json['id'] as String` | ✅ |
| name | `"name"` | `json['name'] as String` | ✅ |
| phone | `"phone"` | `json['phone'] as String` | ✅ |
| email | `"email"` | `json['email'] as String?` | ✅ |
| role | `"role"` | `json['role'] as String` | ✅ |
| image | `"image"` | `json['image'] as String?` | ✅ |
| isVerified | `isVerified` / `is_verified` | كلاهما معالجين | ✅ |

**ملاحظة:** `toJson()` يرسل `is_verified` (snake_case). الـ Backend يقبل `isVerified` (camelCase). هذا **اختلاف محتمل** إذا الـ Backend لا يقبل `is_verified`.

### 3.2 CategoryModel ✅

**الملف:** `lib/features/home/data/models/category_model.dart`

| الحقل | الـ Backend (camelCase) | الـ Model (يدعم الاتنين) | الحالة |
|-------|------------------------|------------------------|--------|
| id | `"id"` | `json['id'] as String` | ✅ |
| nameAr | `"nameAr"` | `json['nameAr']`/`json['name_ar']` | ✅ |
| nameFr | `"nameFr"` | `json['nameFr']`/`json['name_fr']` | ✅ |
| parentId | `"parentId"` | `json['parentId']`/`json['parent_id']` | ✅ |
| orderIndex | `"orderIndex"` | `json['orderIndex']`/`json['order_index']` | ✅ |
| children | `"children"` | `json['children']` | ✅ |
| icon | `"icon"` | `json['icon'] as String?` | ✅ |
| artisanCount | غير موجود فـ Response | `_count.artisanServices` → 0 | ⚠️ دائمًا 0 |

**ملاحظة:** الـ Backend **لا يرسل** `artisanCount` أو `_count` ولا `artisan_count`. إذا الـ UI محتاج عدد الحرفيين فـ كل خدمة، الـ Backend يحتاج لإضافة هذا الحقل.

**الحقول الإضافية فالـ Backend (غير مستعملة فالـ Model):**
- `isActive: true`
- `createdAt`: ISO timestamp
- `updatedAt`: ISO timestamp

### 3.3 ArtisanModel ⚠️ (تم التصحيح)

**الملف:** `lib/features/home/data/models/category_model.dart`

#### الاختلافات المصححة:

| الحقل | الـ Backend | الـ Model قبل التصحيح | بعد التصحيح |
|-------|-------------|----------------------|-------------|
| rankingScore | `"rankingScore"` | `rank_score`/`rankScore` فقط | ✅ أضفنا `rankingScore` |
| name | `user.name` | `user?['name']` مع fallback `flatName` | ✅ صحيح |
| bio | `"bio"` | `json['bio']` | ✅ |
| coverImage | `"coverImage"` | `coverImage`/`cover_image` | ✅ |
| ratingAvg | `"ratingAvg"` | `rating_avg`/`ratingAvg` | ✅ |
| totalRatings | `"totalRatings"` | `total_ratings`/`totalRatings` | ✅ |
| totalOrders | `"totalOrders"` | غير مستعمل مباشرة | ✅ |
| responseTimeAvg | `"responseTimeAvg"` | `response_time_avg`/`responseTimeAvg` | ✅ |
| latitude/longitude | غير موجود | له fallback 0 | ⚠️ |
| distanceKm | غير موجود | له fallback 0 | ⚠️ |

**التصحيح المطبق:** `rankingScore` أصبح يُقرأ من `rankingScore` أولاً، ثم `rank_score`، ثم `rankScore`.

#### Profile vs List Response:

- **القائمة** (`/artisans?service_id=...`): ترجع `{ data: [artisan1, artisan2, ...], nextCursor, hasMore }`
  - تحتوي على: `id`, `user`, `bio`, `coverImage`, `ratingAvg`, `totalRatings`, `totalOrders`, `responseTimeAvg`, `rankingScore`, `services`, `_count: { reviews }`
- **الملف الشخصي** (`/artisans/:id`): ترجع الـ Dto مباشرة بدون `data` wrapper
  - تحتوي على: `id`, `user`, `bio`, `coverImage`, `ratingAvg`, `totalRatings`, `totalOrders`, `responseTimeAvg`, `services`, `portfolio`, `reviews`
  - **لا تحتوي** على `rankingScore`

**الـ DataSources** تتعامل مع كلا الحالتين ✅

### 3.4 ArtisanServiceModel ✅

| الحقل | الـ Backend | الـ Model | الحالة |
|-------|-------------|-----------|--------|
| id | `"id"` | `json['id'] as String` | ✅ |
| price | `"price"` | `(json['price'] as num).toDouble()` | ✅ |
| service.id | `service.id` | `service?['id'] as String? ?? ''` | ✅ |
| service.nameAr | `service.nameAr` | `service?['name_ar']`/ `service?['nameAr']` | ✅ |
| service.nameFr | `service.nameFr` | `service?['name_fr']`/ `service?['nameFr']` | ✅ |

### 3.5 PortfolioModel ✅

| الحقل | الـ Backend | الـ Model | الحالة |
|-------|-------------|-----------|--------|
| id | `"id"` | `json['id'] as String` | ✅ |
| imageUrl | `"imageUrl"` | `json['image_url']`/`json['imageUrl']`/`json['url']` | ✅ |
| thumbnailUrl | `"thumbnailUrl"` | `json['thumbnail_url']`/`json['thumbnailUrl']` | ✅ |
| description | `"description"` | `json['description'] as String?` | ✅ |

**ملاحظة:** Portfolio ظاهر فـ Response مال الـ Profile (`/artisans/:id`) وأيضًا فـ Endpoint منفصل (`/artisans/:id/portfolio`). الحالتين شغالات.

### 3.6 NotificationModel ✅

| الحقل | الـ Backend | الـ Model | الحالة |
|-------|-------------|-----------|--------|
| id | `"id"` | `json['id'] as String` | ✅ |
| title | `"title"` | `json['title'] as String` | ✅ |
| body | `"body"` | `json['body'] as String` | ✅ |
| data | `"data"` | `json['data'] as Map?` | ✅ |
| isRead | `"is_read"` | `json['is_read'] as bool? ?? false` | ✅ |
| createdAt | `"created_at"` | `DateTime.parse(...)` | ✅ |

---

## 4. DataSources

### 4.1 ServicesRemoteDataSource ✅

| الدالة | الـ Endpoint | تتعامل مع Response؟ |
|--------|-------------|---------------------|
| `getCategories()` | `GET /services` | ✅ قائمة مباشرة |
| `searchServices()` | `GET /services?q=&category_id=&cursor=&limit=` | ✅ |
| `searchArtisans()` | `GET /artisans?service_id=&lat=&lng=&cursor=&limit=` | ✅ |
| `getSuggestedArtisans()` | `GET /artisans` | ✅ `List`/`{data: [...]}` |
| `getArtisanProfile()` | `GET /artisans/:id` | ✅ |
| `getArtisanReviews()` | `GET /artisans/:id/reviews` | ✅ |
| `getArtisanPortfolio()` | `GET /artisans/:id/portfolio` | ✅ |

### 4.2 AuthRemoteDataSource ✅

| الدالة | الـ Endpoint | ملاحظة |
|--------|-------------|--------|
| `login()` | `POST /auth/login` | يرسل `phone` أو `email` + `password` |
| `register()` | `POST /auth/register` | يرسل `name`, `phone`, `password`, اختيارياً `email` |
| `registerArtisan()` | `POST /auth/register/artisan` | نفس شكل register |
| `getProfile()` | `GET /auth/profile` | يحتاج Bearer token |
| `logout()` | `POST /auth/logout` | - |

### 4.3 ArtisanRemoteDataSource ✅

| الدالة | الـ Endpoint | ملاحظة |
|--------|-------------|--------|
| `getStats()` | `GET /artisans/:id/stats` | ⚠️ الـ Backend يرجع 404 — **الـ Endpoint غير موجود** |
| `getRequests()` | `GET /artisans/:id/requests` | ⚠️ **لم يتم اختباره** |
| `updateProfile()` | `PUT /artisans/:id/profile` | يرسل `bio`, `cover_image` |
| `addService()` | `POST /artisans/:id/services` | يرسل `service_id`, `price` |
| `updateService()` | `PUT /artisans/:id/services/:service_id` | يرسل `price` |
| `removeService()` | `DELETE /artisans/:id/services/:service_id` | - |
| `getPlans()` | `GET /subscriptions/plans` | ⚠️ **لم يتم اختباره** |
| `subscribe()` | `POST /subscriptions/subscribe` | ⚠️ **لم يتم اختباره** |
| `cancelSubscription()` | `POST /subscriptions/cancel` | ⚠️ **لم يتم اختباره** |
| `upgradeSubscription()` | `POST /subscriptions/upgrade` | ⚠️ **لم يتم اختباره** |
| `getMySubscription()` | `GET /subscriptions/my` | ⚠️ **لم يتم اختباره** |
| `uploadImage()` | `POST /upload` | ⚠️ **لم يتم اختباره** |
| `addPortfolio()` | `POST /artisans/:id/portfolio` | ⚠️ **لم يتم اختباره** |
| `removePortfolio()` | `DELETE /artisans/:id/portfolio/:media_id` | ⚠️ **لم يتم اختباره** |
| `getMyPortfolio()` | `GET /artisans/:id/portfolio` | ⚠️ **لم يتم اختباره** |

### 4.4 ClientRemoteDataSource ✅

| الدالة | الـ Endpoint | ملاحظة |
|--------|-------------|--------|
| `submitReview()` | `POST /reviews` | يرسل `client_id`, `artisan_id`, `service_id`, `rating`, `comment` |
| `submitComplaint()` | `POST /complaints` | ⚠️ **لم يتم اختباره** |
| `getFavorites()` | `GET /favorites` | ⚠️ يحتاج Bearer token |

### 4.5 NotificationRemoteDataSource ✅

| الدالة | الـ Endpoint | ملاحظة |
|--------|-------------|--------|
| `getNotifications()` | `GET /notifications` | ⚠️ يحتاج Bearer token |
| `markAsRead()` | `PATCH /notifications/:id/read` | ⚠️ يحتاج Bearer token |
| `registerDevice()` | `POST /notifications/register-device` | يرسل `fcmToken`, `platform` |
| `unregisterDevice()` | `DELETE /notifications/unregister-device` | ⚠️ يحتاج Bearer token |

---

## 5. مشاكل معروفة

### 🔴 حاسمة
1. **Endpoint `/artisans/:id/stats` غير موجود فالـ Backend** — يرجع 404. لازم الـ Endpoint يتزاد فالـ Backend controller.

### 🟡 متوسطة
2. **`rankingScore` كيتواجد فقط فـ List وليس Profile.**  
   - القائمة: `rankingScore` حاضر ✅  
   - الملف الشخصي: غائب ⚠️ — إذا محتاجين الـ Score فالـ Profile، خاص الـ Backend يضيفو.
3. **`artisanCount` فـ CategoryModel دائمًا 0** — الـ Backend ما كيأمنش عدد الحرفيين لكل خدمة. إذا الـ UI محتاج الرقم، خاص الـ Backend يضيف `_count.artisanServices` فالـ Services endpoint.
4. **`toJson()` فـ UserModel كاتبعث `is_verified` (snake_case) والـ Backend كيتوقع `isVerified` (camelCase).**  
   - الضرر محدود لأن `toJson()` مستعملة فالـ Auth (register/login) — وهاذ الـ Endpoints ما كاتبعتش `isVerified` عادة. لكن إذا الـ Model تبعتها فـ Profile update، خاص تصلح.

### 🟢 طفيفة
5. **`limit` query parameter**: الـ Backend NestJS validation صارم فالـ Type (يحتاج number مش string). Dio كيبعت query parameters كـ strings. إذا الـ Backend ما عندوش `@Type(() => Number)`، خاص يزيدها أو نغير طريقة إرسال limit.
6. **بعض الـ Endpoints محتاجين Bearer token** وما تمش اختبارهم: `/favorites`, `/notifications`, `/subscriptions/*`
7. **Cloudflare Tunnel URL** — مؤقت. خاص يتغير لـ Production URL.

---

## 6. الخلاصة

| المجال | الحالة |
|--------|--------|
| API Constants | ✅ جاهز |
| ApiClient | ✅ جاهز |
| UserModel ↔ Backend | ✅ متطابق (بعد معالجة camelCase/snake_case) |
| CategoryModel ↔ Backend | ✅ متطابق (مع دعم الاتجاهين) |
| ArtisanModel ↔ Backend | ✅ **مصحح** (تمت إضافة `rankingScore`) |
| ArtisanServiceModel ↔ Backend | ✅ متطابق |
| PortfolioModel ↔ Backend | ✅ متطابق |
| NotificationModel ↔ Backend | ✅ متطابق |
| Auth DataSources | ✅ جاهز (بيحتاج اختبار مع Token) |
| Services DataSources | ✅ جاهز |
| Artisan DataSources | ⚠️ `getStats()` يرجع 404 |
| Client DataSources | ✅ جاهز |
| Notification DataSources | ✅ جاهز |

### التعديلات المطبقة:
1. ✅ **إضافة `rankingScore`** لـ ArtisanModel.fromJson (فال priority: `rankingScore` → `rank_score` → `rankScore`)

### الإجراءات المطلوبة من Backend:
1. إضافة Endpoint `/artisans/:id/stats`
2. إضافة `rankingScore` فـ Profile Dto (ArtisanPublicDto)
3. إضافة `_count.artisanServices` فـ Services response
4. إضافة `@Type(() => Number)` فـ Query params لـ `limit`
5. تغيير `is_verified` → `isVerified` فـ User response models (إذا keep snake_case، نخلي UserModel.toJson يبعث `isVerified` بدل `is_verified`)

### الإجراءات المطلوبة من Flutter:
1. ✅ تم: إضافة `rankingScore` لـ ArtisanModel
2. تغيير `UserModel.toJson()` ليبعت `isVerified` (camelCase) بدل `is_verified` (إذا الـ Backend كيتوقع camelCase فـ الطلبات)
3. اختبار الـ Endpoints المحتاجين `Bearer token` بعد اكتمال الـ Auth flow
