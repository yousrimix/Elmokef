const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');

const pool = new Pool({ connectionString: 'postgresql://postgres:postgres@localhost:5432/elmokef?schema=public' });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log('🌱 Seeding Elmokef database...');

  // Clean data using raw SQL with CASCADE
  await prisma.$executeRawUnsafe('TRUNCATE TABLE "users" CASCADE');
  await prisma.$executeRawUnsafe('TRUNCATE TABLE "services" CASCADE');
  await prisma.$executeRawUnsafe('TRUNCATE TABLE "ranking_config" CASCADE');
  console.log('✅ Database cleaned');

  // Create admin user
  await prisma.user.create({
    data: { name: 'مدير الموقع', phone: '0600000000', email: 'admin@elmokef.ma', role: 'ADMIN', isVerified: true },
  });
  console.log('✅ Admin: مدير الموقع');

  // Categories
  const catData = [
    { nameAr: 'سباكة', nameFr: 'Plomberie', orderIndex: 1 },
    { nameAr: 'كهرباء', nameFr: 'Électricité', orderIndex: 2 },
    { nameAr: 'صباغة', nameFr: 'Peinture', orderIndex: 3 },
    { nameAr: 'نجارة', nameFr: 'Menuiserie', orderIndex: 4 },
    { nameAr: 'تبريد وتكييف', nameFr: 'Climatisation', orderIndex: 5 },
    { nameAr: 'حدادة', nameFr: 'Serrurerie', orderIndex: 6 },
    { nameAr: 'تنظيف', nameFr: 'Nettoyage', orderIndex: 7 },
  ];
  const cats = {};
  for (const c of catData) cats[c.nameAr] = await prisma.service.create({ data: c });
  console.log(`✅ ${catData.length} categories`);

  // Sub-services
  const subData = [
    { parent: 'سباكة', items: ['تركيب وصيانة','تسليك مجاري','تركيب سخانات'] },
    { parent: 'كهرباء', items: ['تمديدات كهربائية','إصلاح أعطال'] },
    { parent: 'صباغة', items: ['دهان داخلي','دهان خارجي'] },
    { parent: 'تبريد وتكييف', items: ['تركيب مكيفات','صيانة وتصليح'] },
    { parent: 'نجارة', items: ['أثاث حسب الطلب','إصلاح أثاث'] },
    { parent: 'حدادة', items: [] },
    { parent: 'تنظيف', items: ['تنظيف منازل','تنظيف واجهات'] },
  ];
  for (const g of subData) {
    for (const item of g.items) {
      await prisma.service.create({ data: { nameAr: item, nameFr: item, parentId: cats[g.parent].id, orderIndex: 1 } });
    }
  }
  const allSubServices = await prisma.service.findMany({ where: { parentId: { not: null } } });
  console.log(`✅ ${allSubServices.length} sub-services`);

  // Artisans with full nested create
  const artisanProfiles = [];
  const artisanData = [
    {n:'أحمد العلوي',p:'+212612345678',lat:33.5731,lng:-7.5898},
    {n:'محمد الصقلي',p:'+212612345679',lat:33.5780,lng:-7.5950},
    {n:'فاطمة بنعلي',p:'+212612345680',lat:33.5700,lng:-7.5850},
  ];
  for (const a of artisanData) {
    const user = await prisma.user.create({
      data: {
        name: a.n, phone: a.p, role: 'ARTISAN', isVerified: true,
        artisanProfile: {
          create: {
            bio: `${a.n} محترف في المجال`, ratingAvg: 4.5, totalRatings: 20,
            responseTimeAvg: 15, totalOrders: 35, rankingScore: 0.92, isVerified: true,
            latitude: a.lat, longitude: a.lng,
          },
        },
      },
      include: { artisanProfile: true },
    });
    artisanProfiles.push(user.artisanProfile);
  }
  console.log(`✅ ${artisanProfiles.length} artisans`);

  // Services for artisans
  for (const profile of artisanProfiles) {
    const shuffled = [...allSubServices].sort(() => Math.random() - 0.5).slice(0, 2);
    for (const s of shuffled) {
      await prisma.artisanService.create({
        data: { artisanId: profile.id, serviceId: s.id, price: 100 + Math.floor(Math.random() * 250) },
      });
    }
  }
  console.log('✅ Artisan services assigned');

  // Portfolio
  for (const profile of artisanProfiles) {
    console.log('Portfolio for:', profile?.id);
    for (let i = 0; i < 3; i++) {
      await prisma.artisanPortfolio.create({
        data: { artisanId: profile.id, imageUrl: '', description: 'صورة '+(i+1) },
      });
    }
  }
  console.log('✅ Portfolio items');

  // Client with reviews
  const client = await prisma.user.create({
    data: {
      name: 'عميد', phone: '+212600000001', role: 'CLIENT',
      clientProfile: { create: {} },
    },
  });
  console.log('✅ Client: عميد');

  // Reviews (different service per review to avoid unique constraint)
  let ri = 0;
  for (const profile of artisanProfiles) {
    for (let i = 0; i < 3; i++) {
      const svc = allSubServices[ri % allSubServices.length];
      ri++;
      try {
        await prisma.review.create({
          data: {
            clientId: client.id, artisanId: profile.userId, serviceId: svc.id,
            rating: 4 + i % 2, comment: ['خدمة ممتازة','شغل نظيف','أخلاق عالية'][i],
            isApproved: true,
          },
        });
      } catch(e) { /* skip duplicates */ }
    }
  }
  console.log('✅ Reviews');

  // Ranking config
  await prisma.rankingConfig.create({
    data: { id: 'singleton', weights: {}, boosts: {} },
  });
  console.log('✅ Ranking config');

  // Notifications
  for (const profile of artisanProfiles) {
    await prisma.notification.create({
      data: { userId: profile.userId, title: 'طلب جديد', body: 'وصل طلب جديد من عميد', data: { type: 'request' } },
    });
  }
  console.log('✅ Notifications');

  console.log('\n🎉 Done!');
  console.log('👤 Login: admin@elmokef.ma / admin123');
}

main()
  .catch(e => { console.error('❌', e.message?.substring(0, 300)); process.exit(1); })
  .finally(() => prisma.$disconnect());
