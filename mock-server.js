const http = require('http');
const url = require('url');

const PORT = 3000;
const ADMIN_EMAIL = 'admin@elmokef.ma';
const ADMIN_PASS = 'admin123';

function jsonResponse(res, data, status = 200) {
  res.writeHead(status, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  });
  res.end(JSON.stringify(data));
}

// ─── Mock Data ────────────────────────────────────────────────

const MOCK_ARTISANS = [
  {
    id: 'art-uuid-001', bio: 'سباك محترف بخبرة 10 سنوات', coverImage: null,
    rating_avg: 4.5, total_ratings: 23, response_time_avg: 15, is_verified: true,
    distance_km: 2.3, lat: 34.01, lng: -3.15, rank_score: 0.92,
    price_range: '150-300',
    profession: 'سباك محترف',
    user: { id: 'user-uuid-001', name: 'أحمد العلوي', image: null, phone: '+212612345678', city: 'الدار البيضاء' },
    services: [
      { id: 'as-uuid-001', price: 200, service: { id: 'cat-1a', name_ar: 'تركيب وصيانة', name_fr: 'Installation & entretien' } },
      { id: 'as-uuid-002', price: 150, service: { id: 'cat-1b', name_ar: 'تسليك مجاري', name_fr: 'Débouchage' } },
      { id: 'as-uuid-003', price: 300, service: { id: 'cat-1c', name_ar: 'تركيب سخانات', name_fr: 'Chauffe-eau' } },
    ],
    portfolio: [
      { id: 'pf-1', image: null, description: 'تركيب نظام سباكة كامل' },
      { id: 'pf-2', image: null, description: 'تسليك مجاري فيلا' },
      { id: 'pf-3', image: null, description: 'تركيب سخانات شمسية' },
    ],
    reviews: [
      { id: 'rev-1', rating: 5, comment: 'خدمة ممتازة وصل فالوقت', user_name: 'عميد', created_at: '2026-06-15T10:00:00Z' },
      { id: 'rev-2', rating: 4, comment: 'خدمة جيدة لكن تأخر شويا', user_name: 'سعيد', created_at: '2026-06-12T14:30:00Z' },
      { id: 'rev-3', rating: 5, comment: 'سباك محترم ونظيف', user_name: 'محمد', created_at: '2026-06-10T09:00:00Z' },
      { id: 'rev-4', rating: 5, comment: 'شغف نظيف وخدمة في المستوى', user_name: 'فاطمة', created_at: '2026-06-08T16:00:00Z' },
    ]
  },
  {
    id: 'art-uuid-002', bio: 'كهربائي معتمد بخبرة 8 سنوات', coverImage: null,
    rating_avg: 4.2, total_ratings: 15, response_time_avg: 30, is_verified: true,
    distance_km: 4.1, lat: 34.02, lng: -3.16, rank_score: 0.85,
    price_range: '120-250',
    profession: 'كهربائي محترف',
    user: { id: 'user-uuid-002', name: 'محمد الصقلي', image: null, phone: '+212612345679', city: 'الدار البيضاء' },
    services: [
      { id: 'as-uuid-004', price: 180, service: { id: 'cat-2a', name_ar: 'تمديدات كهربائية', name_fr: 'Câblage' } },
      { id: 'as-uuid-005', price: 120, service: { id: 'cat-2b', name_ar: 'إصلاح أعطال', name_fr: 'Dépannage' } },
    ],
    portfolio: [
      { id: 'pf-4', image: null, description: 'تمديدات كهربائية فيلا' },
    ],
    reviews: [
      { id: 'rev-5', rating: 5, comment: 'كهربائي ماهر ونظيف', user_name: 'خالد', created_at: '2026-06-14T11:00:00Z' },
      { id: 'rev-6', rating: 4, comment: 'شغف مزيان', user_name: 'إسماعيل', created_at: '2026-06-11T13:00:00Z' },
    ]
  },
];

const MOCK_REQUESTS = [
  { id: 'req-1', client_name: 'عميد', service: 'سباكة', distance: '2.3 كم', time: 'منذ 10 دقائق', status: 'pending', client_phone: '+212600000001' },
  { id: 'req-2', client_name: 'سعيد', service: 'صيانة', distance: '3.1 كم', time: 'منذ 1 ساعة', status: 'pending', client_phone: '+212600000002' },
  { id: 'req-3', client_name: 'محمد', service: 'تركيب وصيانة', distance: '1.5 كم', time: 'منذ 3 ساعات', status: 'accepted', client_phone: '+212600000003' },
  { id: 'req-4', client_name: 'فاطمة', service: 'تسليك مجاري', distance: '5.2 كم', time: 'منذ أمس', status: 'completed', client_phone: '+212600000004' },
  { id: 'req-5', client_name: 'خالد', service: 'تركيب سخانات', distance: '2.8 كم', time: 'منذ يومين', status: 'completed', client_phone: '+212600000005' },
];

const MOCK_NOTIFICATIONS = [
  { id: 'notif-1', title: 'طلب جديد', body: 'طلب سباكة من عميد (2.3 كم)', type: 'request', is_read: false, created_at: '2026-06-18T13:30:00Z' },
  { id: 'notif-2', title: 'تقييم جديد', body: 'محمد قام بتقييمك 5 نجوم', type: 'review', is_read: false, created_at: '2026-06-18T12:00:00Z' },
  { id: 'notif-3', title: 'تم قبول طلبك', body: 'تم قبول طلب السباكة من أحمد', type: 'request', is_read: true, created_at: '2026-06-17T15:00:00Z' },
  { id: 'notif-4', title: 'اشتراك جديد', body: 'تم تفعيل اشتراكك البلاتيني', type: 'subscription', is_read: true, created_at: '2026-06-16T10:00:00Z' },
  { id: 'notif-5', title: 'تذكير', body: 'لديك 3 طلبات في انتظار الرد', type: 'system', is_read: true, created_at: '2026-06-15T09:00:00Z' },
];

const MOCK_SUBSCRIPTIONS = [
  { id: 'sub-1', name: 'أساسي', name_ar: 'أساسي', price: 0, period: 'شهر', features: ['3 طلبات في الشهر', 'ظهور في البحث', 'توثيق الحساب'] },
  { id: 'sub-2', name: 'مميز', name_ar: 'مميز', price: 99, period: 'شهر', features: ['طلبات غير محدودة', 'ظهور مميز في البحث', 'إحصائيات متقدمة', 'دعم فوري'] },
  { id: 'sub-3', name: 'بلاتيني', name_ar: 'بلاتيني', price: 199, period: 'شهر', features: ['كل شيء في المميز', 'ترتيب أول في البحث', 'بطاقة حرفي موسعة', 'تقرير أسبوعي', 'مساح إعلاني'] },
];

const CATEGORIES = [
  { id: 'cat-1', name_ar: 'سباكة', name_fr: 'Plomberie', order_index: 1, parent_id: null, artisan_count: 12,
    children: [
      { id: 'cat-1a', name_ar: 'تركيب وصيانة', name_fr: 'Installation & entretien', order_index: 1, parent_id: 'cat-1', artisan_count: 5 },
      { id: 'cat-1b', name_ar: 'تسليك مجاري', name_fr: 'Débouchage', order_index: 2, parent_id: 'cat-1', artisan_count: 3 },
      { id: 'cat-1c', name_ar: 'تركيب سخانات', name_fr: 'Chauffe-eau', order_index: 3, parent_id: 'cat-1', artisan_count: 4 },
    ] },
  { id: 'cat-2', name_ar: 'كهرباء', name_fr: 'Électricité', order_index: 2, parent_id: null, artisan_count: 8,
    children: [
      { id: 'cat-2a', name_ar: 'تمديدات كهربائية', name_fr: 'Câblage', order_index: 1, parent_id: 'cat-2', artisan_count: 4 },
      { id: 'cat-2b', name_ar: 'إصلاح أعطال', name_fr: 'Dépannage', order_index: 2, parent_id: 'cat-2', artisan_count: 4 },
    ] },
  { id: 'cat-3', name_ar: 'صباغة', name_fr: 'Peinture', order_index: 3, parent_id: null, artisan_count: 6,
    children: [
      { id: 'cat-3a', name_ar: 'دهان داخلي', name_fr: 'Intérieur', order_index: 1, parent_id: 'cat-3', artisan_count: 3 },
      { id: 'cat-3b', name_ar: 'دهان خارجي', name_fr: 'Extérieur', order_index: 2, parent_id: 'cat-3', artisan_count: 3 },
    ] },
  { id: 'cat-4', name_ar: 'تبريد وتكييف', name_fr: 'Climatisation', order_index: 4, parent_id: null, artisan_count: 5,
    children: [
      { id: 'cat-4a', name_ar: 'تركيب مكيفات', name_fr: 'Installation clim', order_index: 1, parent_id: 'cat-4', artisan_count: 3 },
      { id: 'cat-4b', name_ar: 'صيانة وتصليح', name_fr: 'Entretien clim', order_index: 2, parent_id: 'cat-4', artisan_count: 2 },
    ] },
  { id: 'cat-5', name_ar: 'نجارة', name_fr: 'Menuiserie', order_index: 5, parent_id: null, artisan_count: 4,
    children: [
      { id: 'cat-5a', name_ar: 'أثاث حسب الطلب', name_fr: 'Meubles sur mesure', order_index: 1, parent_id: 'cat-5', artisan_count: 2 },
      { id: 'cat-5b', name_ar: 'إصلاح أثاث', name_fr: 'Réparation meubles', order_index: 2, parent_id: 'cat-5', artisan_count: 2 },
    ] },
  { id: 'cat-6', name_ar: 'حدادة', name_fr: 'Serrurerie', order_index: 6, parent_id: null, artisan_count: 3, children: [] },
  { id: 'cat-7', name_ar: 'تنظيف', name_fr: 'Nettoyage', order_index: 7, parent_id: null, artisan_count: 7,
    children: [
      { id: 'cat-7a', name_ar: 'تنظيف منازل', name_fr: 'Ménage', order_index: 1, parent_id: 'cat-7', artisan_count: 4 },
      { id: 'cat-7b', name_ar: 'تنظيف واجهات', name_fr: 'Façades', order_index: 2, parent_id: 'cat-7', artisan_count: 3 },
    ] },
];

// ─── Server ───────────────────────────────────────────────────

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;

  // CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    });
    return res.end();
  }

  let body = '';
  req.on('data', chunk => body += chunk);
  req.on('end', () => {
    const data = body ? (() => { try { return JSON.parse(body); } catch (e) { return {}; } })() : {};

    // Helper to match /api/v1 prefix
    const p = (endpoint) => path === endpoint || path === '/api/v1' + endpoint;

    // ─── AUTH ─────────────────────────────────────────────
    if (req.method === 'POST' && (p('/auth/login'))) {
      if (data.email === ADMIN_EMAIL && data.password === ADMIN_PASS) {
        return jsonResponse(res, {
          accessToken: 'mock-token-elmokef-admin-2026',
          user: { id: 'admin-uuid-001', name: 'مدير الموقف', email: ADMIN_EMAIL, role: 'ADMIN', phone: '0600000000' }
        });
      }
      if (data.email && data.password) {
        // Also accept any email/password for testing
        return jsonResponse(res, {
          accessToken: 'mock-token-' + Date.now(),
          user: { id: 'user-uuid-' + Date.now(), name: data.email.split('@')[0], email: data.email, role: 'CLIENT', phone: '0600000000' }
        });
      }
      return jsonResponse(res, { message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة' }, 401);
    }

    // Register
    if (req.method === 'POST' && (p('/auth/register'))) {
      return jsonResponse(res, {
        accessToken: 'mock-token-reg-' + Date.now(),
        user: { id: 'user-uuid-' + Date.now(), name: data.name || 'مستخدم', email: data.email, role: data.role || 'CLIENT', phone: data.phone || '' }
      });
    }

    // Profile
    if (req.method === 'GET' && (p('/auth/profile'))) {
      return jsonResponse(res, { id: 'admin-uuid-001', name: 'مدير الموقف', email: ADMIN_EMAIL, role: 'ADMIN', image: null, phoneVerified: true, createdAt: '2026-06-18T00:00:00Z' });
    }

    // ─── CATEGORIES ────────────────────────────────────────
    if (req.method === 'GET' && (p('/categories') || p('/services'))) {
      return jsonResponse(res, CATEGORIES);
    }

    // ─── ARTISANS ──────────────────────────────────────────
    if (req.method === 'GET' && p('/artisans') && !path.match(/\/artisans\//)) {
      const serviceId = parsedUrl.query.service_id;
      let result = MOCK_ARTISANS;
      if (serviceId) {
        result = result.filter(a => a.services.some(s => s.service.id === serviceId));
      }
      return jsonResponse(res, { data: result, total: result.length });
    }

    // Single artisan
    const artisanDetailMatch = path.match(/\/api\/v1\/artisans\/(.+?)(\/|$)/);
    if (req.method === 'GET' && artisanDetailMatch) {
      const artisanId = artisanDetailMatch[1];
      const artisan = MOCK_ARTISANS.find(a => a.id === artisanId);
      if (artisan) return jsonResponse(res, artisan);
    }

    // Artisan reviews
    const artisanReviewsMatch = path.match(/\/api\/v1\/artisans\/(.+)\/reviews/);
    if (req.method === 'GET' && artisanReviewsMatch) {
      const artisanId = artisanReviewsMatch[1];
      const artisan = MOCK_ARTISANS.find(a => a.id === artisanId);
      if (artisan) return jsonResponse(res, { data: artisan.reviews, total: artisan.reviews.length });
    }

    // ─── ARTISAN (own) ─────────────────────────────────────
    if (req.method === 'GET' && p('/artisan/stats')) {
      return jsonResponse(res, {
        views: 45, calls: 12, rating_avg: 4.8, total_reviews: 23,
        profile_completion: 70,
        weekly_views: [{ day: 'الإثنين', count: 8 }, { day: 'الثلاثاء', count: 12 }, { day: 'الأربعاء', count: 6 }, { day: 'الخميس', count: 10 }, { day: 'الجمعة', count: 5 }, { day: 'السبت', count: 3 }, { day: 'الأحد', count: 1 }],
      });
    }

    // Artisan requests
    if (req.method === 'GET' && p('/artisan/requests')) {
      const status = parsedUrl.query.status;
      let result = MOCK_REQUESTS;
      if (status) result = result.filter(r => r.status === status);
      return jsonResponse(res, { data: result, total: result.length });
    }

    if (req.method === 'PATCH' && p('/artisan/requests') && path.match(/\/requests\/\w+\/status/)) {
      // Accept/reject/complate request
      return jsonResponse(res, { success: true });
    }

    // Artisan subscription
    if (req.method === 'GET' && p('/artisan/subscription')) {
      return jsonResponse(res, {
        current_plan: 'مميز', status: 'active', expires_at: '2026-07-18T00:00:00Z',
        features: ['طلبات غير محدودة', 'ظهور مميز', 'إحصائيات متقدمة'],
      });
    }

    if (req.method === 'POST' && p('/artisan/subscription')) {
      return jsonResponse(res, { success: true, plan: data.plan_id, message: 'تم تفعيل الاشتراك' });
    }

    // Artisan profile update
    if (req.method === 'PATCH' && p('/artisan/profile')) {
      return jsonResponse(res, { success: true, message: 'تم تحديث الملف' });
    }

    // Artisan portfolio
    if (req.method === 'GET' && p('/artisan/portfolio')) {
      return jsonResponse(res, { data: MOCK_ARTISANS[0].portfolio });
    }

    if (req.method === 'POST' && p('/artisan/portfolio')) {
      return jsonResponse(res, { success: true, message: 'تمت إضافة الصورة' });
    }

    // ─── REVIEWS ──────────────────────────────────────────
    if (req.method === 'POST' && p('/reviews')) {
      return jsonResponse(res, { success: true, message: 'شكراً لتقييمك!' });
    }

    // ─── NOTIFICATIONS ────────────────────────────────────
    if (req.method === 'GET' && p('/notifications')) {
      return jsonResponse(res, { data: MOCK_NOTIFICATIONS, total: MOCK_NOTIFICATIONS.length });
    }

    const markReadMatch = path.match(/\/api\/v1\/notifications\/(.+?)\/read/);
    if (req.method === 'POST' && markReadMatch) {
      return jsonResponse(res, { success: true });
    }

    // ─── COMPLAINTS ──────────────────────────────────────
    if (req.method === 'POST' && p('/complaints')) {
      return jsonResponse(res, { success: true, message: 'تم استلام شكواك', reference: 'CMP-' + Date.now() });
    }

    // ─── SUBSCRIPTIONS ────────────────────────────────────
    if (req.method === 'GET' && p('/subscriptions')) {
      return jsonResponse(res, { data: MOCK_SUBSCRIPTIONS, total: MOCK_SUBSCRIPTIONS.length });
    }

    // ─── ADMIN STATS ──────────────────────────────────────
    if (req.method === 'GET' && p('/stats')) {
      return jsonResponse(res, {
        totalUsers: 245, totalArtisans: 128, totalOrders: 89, totalRevenue: 45200,
        weeklyStats: [
          { day: 'الإثنين', users: 12, orders: 5 },
          { day: 'الثلاثاء', users: 18, orders: 7 },
          { day: 'الأربعاء', users: 15, orders: 4 },
          { day: 'الخميس', users: 22, orders: 9 },
          { day: 'الجمعة', users: 20, orders: 6 },
          { day: 'السبت', users: 10, orders: 3 },
          { day: 'الأحد', users: 8, orders: 2 },
        ],
      });
    }

    // ─── USERS ────────────────────────────────────────────
    if (req.method === 'GET' && p('/users')) {
      return jsonResponse(res, {
        data: [
          { id: '1', name: 'أحمد العلوي', email: 'ahmed@test.com', role: 'ARTISAN', phone: '0612345678', createdAt: '2026-05-01' },
          { id: '2', name: 'فاطمة بنعلي', email: 'fatima@test.com', role: 'CLIENT', phone: '0612345679', createdAt: '2026-05-10' },
          { id: '3', name: 'محمد الصقلي', email: 'mohamed@test.com', role: 'ARTISAN', phone: '0612345680', createdAt: '2026-05-15' },
        ],
        total: 3,
      });
    }

    // ─── 404 ─────────────────────────────────────────────
    jsonResponse(res, { message: 'Not found', path }, 404);
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Elmokef Mock API running on http://0.0.0.0:${PORT}`);
  console.log(`   Login: ${ADMIN_EMAIL} / ${ADMIN_PASS}`);
  console.log(`   Endpoints: auth, categories, artisans, notifications, reviews, complaints, subscriptions, stats`);
});
