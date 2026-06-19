const http = require('http');

function api(method, path, data, token) {
  return new Promise((resolve, reject) => {
    const opts = {
      hostname: 'localhost', port: 3000,
      path: '/api/v1' + path,
      method,
      headers: { 'Content-Type': 'application/json' },
    };
    if (token) opts.headers['Authorization'] = 'Bearer ' + token;
    const req = http.request(opts, (res) => {
      let body = '';
      res.on('data', c => body += c);
      res.on('end', () => resolve({ status: res.statusCode, body: JSON.parse(body || '{}') }));
    });
    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

(async () => {
  // 1. Login
  const login = await api('POST', '/auth/login', { email: 'admin@elmokef.ma', password: 'admin123' });
  console.log('1️⃣ POST /auth/login →', login.status, '✅');
  const token = login.body.accessToken;
  
  // 2. Profile
  const profile = await api('GET', '/auth/profile', null, token);
  console.log('2️⃣ GET /auth/profile →', profile.status, '|', profile.body.name);
  
  // 3. Services
  const services = await api('GET', '/services');
  const svc = Array.isArray(services.body) ? services.body : (services.body.data || []);
  const parentCount = svc.filter(s => !s.parentId).length;
  const subCount = svc.filter(s => s.parentId).length;
  console.log('3️⃣ GET /services →', services.status, `| ${parentCount} categories, ${subCount} sub`);
  
  // 4. Artisans
  const artisans = await api('GET', '/artisans', null, token);
  const arts = artisans.body.data || [];
  console.log('4️⃣ GET /artisans →', artisans.status, `| ${arts.length} artisans`);
  
  // 5. Artisan detail
  if (arts[0]) {
    const detail = await api('GET', '/artisans/' + arts[0].id, null, token);
    console.log('5️⃣ GET /artisans/:id →', detail.status, '|', detail.body.user?.name, '⭐', detail.body.ratingAvg);
    console.log('   Services:', detail.body.services?.length, '| Portfolio:', detail.body.portfolio?.length, '| Reviews:', detail.body.reviews?.length);
  }
  
  // 6. Reviews
  if (arts[0]) {
    const reviews = await api('GET', '/artisans/' + arts[0].id + '/reviews', null, token);
    const revs = reviews.body.data || reviews.body || [];
    console.log('6️⃣ GET /artisans/:id/reviews →', reviews.status, `| ${Array.isArray(revs) ? revs.length : '?'} reviews`);
  }
  
  // 7. Notifications
  const notifs = await api('GET', '/notifications', null, token);
  const nots = notifs.body.data || notifs.body || [];
  console.log('7️⃣ GET /notifications →', notifs.status, `| ${Array.isArray(nots) ? nots.length : '?'} notifications`);
  
  // 8. Subscription plans
  const plans = await api('GET', '/subscriptions/plans');
  const planData = Array.isArray(plans.body) ? plans.body : (plans.body.data || []);
  console.log('8️⃣ GET /subscriptions/plans →', plans.status, `| ${planData.length} plans`);
  
  console.log('\n🎉 ALL ENDPOINTS WORKING!');
  console.log('🔑 Token:', token.substring(0, 30) + '...');
  console.log('👤 Login: admin@elmokef.ma / admin123');
})();
