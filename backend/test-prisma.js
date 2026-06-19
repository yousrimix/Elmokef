const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient({
  datasourceUrl: 'postgresql://postgres:postgres@localhost:5432/elmokef?schema=public'
});
prisma.$queryRawUnsafe('SELECT 1 as test')
  .then(r => console.log('✅ Prisma connected!', JSON.stringify(r)))
  .catch(e => console.log('❌ Error:', e.message))
  .finally(() => prisma.$disconnect());
