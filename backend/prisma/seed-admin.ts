import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import * as dotenv from 'dotenv';
import * as path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const prisma = new PrismaClient();

async function main() {
  const password = await bcrypt.hash('admin123', 10);
  await prisma.user.upsert({
    where: { email: 'admin@elmokef.ma' },
    update: {},
    create: {
      name: 'Admin Elmokef',
      phone: '0600000000',
      email: 'admin@elmokef.ma',
      password,
      role: 'ADMIN',
      isActive: true,
      isVerified: true,
    },
  });
  console.log('✅ Admin user created: admin@elmokef.ma / admin123');
}

main().catch(console.error).finally(() => prisma.$disconnect());
