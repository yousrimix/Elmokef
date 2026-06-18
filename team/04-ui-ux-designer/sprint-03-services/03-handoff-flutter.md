# Sprint 3 — تسليم المطورين (Handoff)
**إعداد:** ليلى السعد — UI/UX Designer  
**التسليم إلى:** خالد العمري (Flutter) + محمد العلي (Backend)

---

## 1. التسليمات

| الملف | المحتوى |
|-------|---------|
| `01-categories-and-services.md` | شاشات الفئات الهرمية، عرض الخدمات، الفلترة، الخريطة |
| `02-search-experience.md` | شاشات البحث مع الاقتراحات، التاريخ، النتائج |
| هذا الملف (`03-handoff-flutter.md`) | التكامل، API endpoints، State Management |

---

## 2. الـ API Endpoints Summary (لـ محمد)

| # | الطريقة | الـ Endpoint | البيانات | يستخدم في |
|---|---------|-------------|---------|-----------|
| 1 | GET | `/api/v1/categories` | `{id, name_ar, name_fr, icon, image, parent_id, artisan_count, subcategories[]}` | CA-01, CA-04 |
| 2 | GET | `/api/v1/categories/:id` | نفس + full subcategories | CA-02 |
| 3 | GET | `/api/v1/categories/:id/artisans?lat=&lng=&sort=&filters=` | قائمة حرفيين مصفاة | CA-03 |
| 4 | GET | `/api/v1/services/suggest?q=text` | `{suggestions: string[]}` | SE-01 اقتراحات |
| 5 | GET | `/api/v1/artisans/search?q=text&limit=N` | `{data: ArtisanSummary[], total: int, suggestions: string[]}` | SE-01 نتائج سريعة |
| 6 | GET | `/api/v1/artisans/search?q=text&page=&sort=&filters=` | Full paginated results | SE-02 |

### تنسيق ArtisanSummary
```json
{
  "id": "uuid",
  "name": "يوسف العلوي",
  "photo": "https://cdn.elmokef.ma/artisans/photo_123_thumb.webp",
  "profession": "سباك محترف",
  "rating": 4.8,
  "review_count": 32,
  "price_min": 150,
  "price_max": 300,
  "distance_km": 2.3,
  "is_verified": true,
  "subscription_tier": "premium",
  "city": "الدار البيضاء",
  "response_time_minutes": 5
}
```

---

## 3. State Management في Flutter

```dart
// lib/features/services/providers/categories_provider.dart
@riverpod
class CategoriesNotifier extends _$CategoriesNotifier {
  // الحالة: AsyncValue<List<Category>>
  // Méthodes:
  Future<void> fetchCategories() async { ... }
  Future<List<Category>> fetchSubcategories(int parentId) async { ... }
}

// lib/features/services/providers/artisan_list_provider.dart
@riverpod
class ArtisanListNotifier extends _$ArtisanListNotifier {
  // الحالة: AsyncValue<List<ArtisanSummary>>
  // Parameters: categoryId, subcategoryId, lat, lng, sort, filters
  
  Future<void> fetchArtisans({
    int? categoryId,
    int? subcategoryId,
    double? lat,
    double? lng,
    String sort = 'distance',
    FilterState? filters,
    String? cursor,
  }) async { ... }
  
  Future<void> loadMore() async { ... }  // Cursor-based pagination
}

// lib/features/search/providers/search_provider.dart
@riverpod
class SearchNotifier extends _$SearchNotifier {
  // الحالة:
  // - query: String
  // - suggestions: AsyncValue<List<String>>
  // - quickResults: AsyncValue<List<ArtisanSummary>>
  // - searchHistory: List<String> (local)
  // - isSearching: bool
  
  void onQueryChanged(String query) { ... }  // مع Debounce 300ms
  Future<void> executeSearch(String query) async { ... }
  void clearHistory() { ... }
}
```

---

## 4. Routing

```dart
// إضافة هذه المسارات إلى GoRouter

GoRoute(
  path: '/categories',
  builder: (_, __) => CategoriesScreen(),
  routes: [
    GoRoute(
      path: ':id',
      builder: (_, state) => SubcategoriesScreen(
        categoryId: int.parse(state.pathParameters['id']!),
      ),
      routes: [
        GoRoute(
          path: 'artisans',
          builder: (_, state) => ArtisanListScreen(
            categoryId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    ),
  ],
),
GoRoute(
  path: '/search',
  builder: (_, __) => SearchScreen(),
  routes: [
    GoRoute(
      path: 'results',
      builder: (_, state) => SearchResultsScreen(
        query: state.uri.queryParameters['q'] ?? '',
      ),
    ),
  ],
),
GoRoute(
  path: '/artisan/:id',
  builder: (_, state) => ArtisanProfileScreen(
    artisanId: state.pathParameters['id']!,
  ),
),
```

---

## 5. الأسئلة التقنية (لخالد + محمد)

| السؤال | ملاحظة |
|--------|--------|
| أيقونات الفئات — هل تأتي من API (URL) أم Assets محلية؟ | Asset محلية (SVG) أفضل أداء — أسماء الأيقونات = `icon_{category_id}.svg` |
| البحث — هل الـ suggestions من الـ Backend أم Local؟ | Backend (Full-Text Search) — لأن Local لا يدعم العربية بشكل جيد |
| البحث بالدارجة — هل يدعم؟ | نعم — استخدام pg_trgm مع البحث غير الحساس للحروف |
| الفلترة — يتم على الـ Client أم API؟ | API (تصفية من Backend) — Client يرسل filter parameters فقط |
| Cache للفئات — كم مرة نحدثها؟ | مرة عند فتح التطبيق (أو كل 24 ساعة) — الفئات لا تتغير يومياً |

---

## 6. مكونات Flutter الجديدة في Sprint 3

| المكون | الملف | الوصف |
|--------|-------|-------|
| `CategoryGrid` | `widgets/category_grid.dart` | Grid 3 أعمدة لبطاقات الفئات |
| `CategoryTile` | `widgets/category_tile.dart` | بطاقة فئة واحدة (أيقونة + اسم + عدد) |
| `FilterBottomSheet` | `widgets/filter_bottom_sheet.dart` | Bottom Sheet الفلترة الكامل |
| `RangeSlider` | `widgets/price_range_slider.dart` | شريط سعر مزدوج |
| `SortDropdown` | `widgets/sort_dropdown.dart` | Dropdown ترتيب النتائج |
| `SearchBar` | `widgets/search_bar.dart` | Search بار مع أيقونات وحالات |
| `SuggestionList` | `widgets/suggestion_list.dart` | قائمة الاقتراحات المنسدلة |
| `SearchHistory` | `widgets/search_history.dart` | تاريخ البحث مع حذف |
| `EmptySearchResult` | `widgets/empty_search_result.dart` | حالة عدم وجود نتائج |
| `MapBottomSheet` | `widgets/map_bottom_sheet.dart` | Mini card عند النقر على pin |

---

## 7. الـ Assets المطلوبة

| الملف | الوصف | الصيغة |
|-------|-------|--------|
| `icon_plumbing.svg` | سباكة | SVG, 48×48 |
| `icon_electricity.svg` | كهرباء | SVG, 48×48 |
| `icon_carpentry.svg` | نجارة | SVG, 48×48 |
| `icon_painting.svg` | صباغ | SVG, 48×48 |
| `icon_ac.svg` | تكييف | SVG, 48×48 |
| `icon_blacksmith.svg` | حداد | SVG, 48×48 |
| `icon_cleaning.svg` | تنظيف | SVG, 48×48 |
| `icon_mechanic.svg` | ميكانيك | SVG, 48×48 |
| `icon_construction.svg` | بناء | SVG, 48×48 |
| `icon_gardening.svg` | حدائق | SVG, 48×48 |
| `icon_other.svg` | أخرى | SVG, 48×48 |
| `search_empty.svg` | Illustration "لا نتائج" | SVG, 240×240 |

---

— ليلى السعد | UI/UX Designer
