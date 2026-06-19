/**
 * Elmokef Backend Wrapper
 * Proxies to NestJS (port 3000) and adds missing dev endpoints
 */
const http = require('http');
const { Pool } = require('pg');

const BACKEND_PORT = 3000;
const WRAPPER_PORT = 3002;
const BACKEND = `http://localhost:${BACKEND_PORT}`;
const DATABASE_URL = 'postgresql://postgres:postgres@localhost:5432/elmokef?schema=public';

const server = http.createServer();

server.on('request', (req, res) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET,POST,PUT,PATCH,DELETE,OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type,Authorization',
      'Access-Control-Max-Age': '86400',
    });
    res.end();
    return;
  }

  const url = req.url;
  const method = req.method;
  res.setHeader('Access-Control-Allow-Origin', '*');

  // ── /admin/stats ──
  if (method === 'GET' && url === '/api/v1/admin/stats') {
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify({
      data: {
        stats: [
          { label: 'المستخدمون', value: '1,247', color: '#3B82F6' },
          { label: 'الحرفيون', value: '186', color: '#0D9488' },
          { label: 'الاشتراكات النشطة', value: '94', color: '#F59E0B' },
          { label: 'الإيرادات الشهرية', value: '18,506 درهم', color: '#10B981' },
        ],
        chartData: [
          { day: 'السبت', users: 12 }, { day: 'الأحد', users: 8 }, { day: 'الإثنين', users: 15 },
          { day: 'الثلاثاء', users: 20 }, { day: 'الأربعاء', users: 10 }, { day: 'الخميس', users: 18 },
          { day: 'الجمعة', users: 14 },
        ],
        complaints: [
          { client: 'أحمد الفاسي', artisan: 'كريم السباك', reason: 'تأخير', status: 'مفتوحة' },
          { client: 'فاطمة المراكشية', artisan: 'سعيد الكهربائي', reason: 'جودة', status: 'قيد المعالجة' },
          { client: 'يونس البيضاوي', artisan: 'حميد النجار', reason: 'سلوك', status: 'مفتوحة' },
          { client: 'نورة الرباطية', artisan: 'عمر الدهان', reason: 'إلغاء', status: 'مغلقة' },
        ],
      }
    }));
    return;
  }

  // ── Proxy with artisan coordinate injection ──
  const options = {
    hostname: 'localhost',
    port: BACKEND_PORT,
    path: url,
    method: method,
    headers: req.headers,
  };

  const proxyReq = http.request(options, (proxyRes) => {
    // Intercept /artisans to inject lat/lng
    if (method === 'GET' && url.startsWith('/api/v1/artisans') && proxyRes.statusCode === 200) {
      let body = '';
      proxyRes.on('data', chunk => body += chunk);
      proxyRes.on('end', async () => {
        try {
          const parsed = JSON.parse(body);
          const artisans = parsed.data || parsed.artisans || (Array.isArray(parsed) ? parsed : null);
          if (artisans && Array.isArray(artisans) && artisans.length > 0) {
            const pool = new Pool({ connectionString: DATABASE_URL });
            try {
              const ids = artisans.map(a => a.id);
              const placeholders = ids.map((_, i) => '$' + (i + 1)).join(',');
              const result = await pool.query(
                'SELECT ap.user_id, ap.latitude, ap.longitude FROM artisan_profiles ap WHERE ap.user_id IN (' + placeholders + ')',
                ids
              );
              const coords = {};
              result.rows.forEach(r => { coords[r.user_id] = { lat: r.latitude, lng: r.longitude }; });
              artisans.forEach(a => {
                if (coords[a.id]) {
                  a.latitude = coords[a.id].lat;
                  a.longitude = coords[a.id].lng;
                }
              });
            } finally { await pool.end(); }
          }
          const hdrs = { 'Content-Type': 'application/json; charset=utf-8', 'Access-Control-Allow-Origin': '*' };
          res.writeHead(proxyRes.statusCode, hdrs);
          res.end(JSON.stringify(parsed));
        } catch (e) {
          console.error('[Wrapper] Intercept error:', e.message);
          const hdrs = { 'Content-Type': 'application/json; charset=utf-8', 'Access-Control-Allow-Origin': '*' };
          res.writeHead(proxyRes.statusCode, hdrs);
          res.end(body);
        }
      });
    } else {
      proxyRes.headers['Access-Control-Allow-Origin'] = '*';
      proxyRes.headers['Access-Control-Allow-Methods'] = 'GET,POST,PUT,PATCH,DELETE,OPTIONS';
      proxyRes.headers['Access-Control-Allow-Headers'] = 'Content-Type,Authorization';
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      proxyRes.pipe(res);
    }
  });

  proxyReq.on('error', (e) => {
    console.error('[Wrapper] Proxy error:', e.message);
    res.writeHead(502, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Backend unavailable', message: e.message }));
  });

  req.pipe(proxyReq);
});

server.listen(WRAPPER_PORT, '0.0.0.0', () => {
  console.log(`🔄 Elmokef API Wrapper running on http://0.0.0.0:${WRAPPER_PORT}`);
  console.log(`   Proxying to NestJS backend on port ${BACKEND_PORT}`);
  console.log(`   Intercepting /artisans to inject coordinates`);
});
