const http = require('http'), fs = require('fs'), path = require('path');
const dir = 'E:\\charika\\elmokef-admin\\dist';
const apiHost = 'localhost', apiPort = 3002;
const mime = { '.html':'text/html; charset=utf-8','.js':'application/javascript','.css':'text/css','.svg':'image/svg+xml','.png':'image/png','.ico':'image/x-icon','.json':'application/json' };

http.createServer((req, res) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    }); res.end(); return;
  }

  // Proxy /api/ calls to backend
  if (req.url.startsWith('/api/')) {
    const opts = {
      hostname: apiHost, port: apiPort,
      path: req.url, method: req.method,
      headers: { ...req.headers, host: apiHost + ':' + apiPort },
    };
    const proxyReq = http.request(opts, (proxyRes) => {
      res.writeHead(proxyRes.statusCode, {
        ...proxyRes.headers,
        'Access-Control-Allow-Origin': '*',
      });
      proxyRes.pipe(res);
    });
    proxyReq.on('error', () => {
      res.writeHead(502, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ message: 'خطأ في الاتصال بالخادم' }));
    });
    req.pipe(proxyReq); return;
  }

  // Serve static files with SPA fallback
  const p = req.url === '/' ? '/index.html' : req.url;
  const fp = path.join(dir, p);
  fs.readFile(fp, (e, d) => {
    if (e) {
      fs.readFile(path.join(dir, 'index.html'), (e2, d2) => {
        if (e2) { res.writeHead(404); res.end('Not found'); return; }
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8', 'Access-Control-Allow-Origin': '*' });
        res.end(d2);
      });
    } else {
      const ext = path.extname(p);
      res.writeHead(200, { 'Content-Type': mime[ext] || 'application/octet-stream', 'Access-Control-Allow-Origin': '*' });
      res.end(d);
    }
  });
}).listen(3003, '0.0.0.0', () => console.log('✅ Admin panel + API proxy on http://localhost:3003'));
