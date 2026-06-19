const http = require('http');
const http2 = require('http');
const fs = require('fs');
const path = require('path');

const WEB_DIR = 'E:\\charika\\almawqef\\build\\web';
const PORT = 5181;
const API_HOST = 'localhost';
const API_PORT = 3002;

const MIME = {
  '.html': 'text/html;charset=utf-8',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.json': 'application/json',
  '.wasm': 'application/wasm',
  '.otf': 'font/otf',
  '.ttf': 'font/ttf',
};

const server = http.createServer((req, res) => {
  const url = req.url.split('?')[0];

  // ✅ Proxy /api/ calls to the backend
  if (url.startsWith('/api/')) {
    const apiPath = url;  // Keep full path including /api/
    const options = {
      hostname: API_HOST,
      port: API_PORT,
      path: apiPath,
      method: req.method,
      headers: {
        ...req.headers,
        host: API_HOST + ':' + API_PORT,
      },
    };

    const proxyReq = http2.request(options, (proxyRes) => {
      res.writeHead(proxyRes.statusCode, {
        ...proxyRes.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      });
      proxyRes.pipe(res);
    });

    proxyReq.on('error', (err) => {
      console.error('[API Proxy Error]', err.message);
      res.writeHead(502, { 'Content-Type': 'application/json; charset=utf-8' });
      res.end(JSON.stringify({ message: 'خطأ في الاتصال بالخادم', error: err.message }));
    });

    req.pipe(proxyReq);
    return;
  }

  // ✅ Handle CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    });
    res.end();
    return;
  }

  // ✅ Serve static files with SPA fallback
  let fileUrl = url;
  if (fileUrl === '/') fileUrl = '/index.html';

  let filePath = path.join(WEB_DIR, fileUrl);

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      filePath = path.join(WEB_DIR, 'index.html');
    }

    fs.readFile(filePath, (err2, data) => {
      if (err2) {
        res.writeHead(500);
        res.end('Internal Server Error');
        return;
      }
      const ext = path.extname(filePath);
      res.writeHead(200, {
        'Content-Type': MIME[ext] || 'application/octet-stream',
        'Access-Control-Allow-Origin': '*',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
      });
      res.end(data);
    });
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Elmokef SPA + API Proxy on http://0.0.0.0:${PORT}`);
  console.log(`📁 Serving: ${WEB_DIR}`);
  console.log(`🔗 Proxying /api/* → http://${API_HOST}:${API_PORT}`);
  console.log(`🔄 SPA fallback enabled — all routes serve index.html`);
});
