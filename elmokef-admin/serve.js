const http = require('http'), fs = require('fs'), path = require('path');
const dir = 'E:\\charika\\elmokef-admin\\dist';
const mime = { '.html':'text/html','.js':'application/javascript','.css':'text/css','.svg':'image/svg+xml','.png':'image/png','.ico':'image/x-icon','.json':'application/json' };
http.createServer((req,res) => {
  let p = req.url === '/' ? '/index.html' : req.url;
  const fp = path.join(dir, p);
  fs.readFile(fp, (e,d) => {
    if (e) {
      // SPA fallback
      fs.readFile(path.join(dir,'index.html'), (e2,d2) => {
        if (e2) { res.writeHead(404); res.end('Not found'); return; }
        res.writeHead(200, {'Content-Type':'text/html; charset=utf-8'});
        res.end(d2);
      });
    } else {
      const ext = path.extname(p);
      res.writeHead(200, {'Content-Type': mime[ext] || 'application/octet-stream'});
      res.end(d);
    }
  });
}).listen(3003, '0.0.0.0', () => console.log('Admin panel on http://0.0.0.0:3003'));
