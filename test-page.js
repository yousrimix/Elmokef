const http = require('http');
http.createServer((req, res) => {
    res.writeHead(200, {'Content-Type': 'text/html; charset=utf-8'});
    res.end(`<!DOCTYPE html><html><head><meta charset='utf-8'><title>Elmokef Test</title>
    <style>body{font-family:sans-serif;text-align:center;padding:40px;background:linear-gradient(135deg,#059669,#0D9488);color:#fff}
    h1{font-size:2.5em} .ok{color:#4ade80} .info{background:rgba(255,255,255,.1);padding:20px;border-radius:12px;margin:20px auto;max-width:500px}
    a{color:#fff;display:inline-block;margin:10px;padding:12px 24px;background:rgba(255,255,255,.2);border-radius:8px;text-decoration:none}
    </style></head><body>
    <h1>🧪 Elmokef — الاختبار</h1>
    <div class='info'>
        <p>✅ Backend: <span class='ok' id='be'>جاري التحقق...</span></p>
        <p>✅ Database: <span class='ok' id='db'>جاري التحقق...</span></p>
        <p>✅ Artisans: <span class='ok' id='ar'>جاري التحقق...</span></p>
    </div>
    <a href='http://localhost:5181'>🚀 Flutter App</a>
    <a href='http://localhost:3000/api/docs'>📚 API Docs</a>
    <script>
        fetch('http://localhost:3000/api/v1/services').then(r=>r.json()).then(d=>document.getElementById('be').textContent=d.length+' فئة').catch(()=>document.getElementById('be').textContent='❌'));
        fetch('http://localhost:3000/api/v1/artisans').then(r=>r.json()).then(d=>document.getElementById('ar').textContent=(d.data||d).length+' حرفي').catch(()=>document.getElementById('ar').textContent='❌'));
    </script>
</body></html>`);
}).listen(5199, () => console.log('Test page: http://localhost:5199'));
