import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import pg from 'pg';

const pool = new pg.Pool({
  host: 'aws-0-eu-west-1.pooler.supabase.com',
  port: 5432,
  user: 'postgres.dvkefmbmftvigrnympuq',
  password: 'j6AN8?T_c!e,XdH',
  database: 'postgres',
  max: 10,
});

const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

const categories = [
  { nameAr: 'سباكة', nameFr: 'Plomberie', icon: 'plumber', orderIndex: 1 },
  { nameAr: 'كهرباء', nameFr: 'Électricité', icon: 'electrician', orderIndex: 2 },
  { nameAr: 'دهان', nameFr: 'Peinture', icon: 'painter', orderIndex: 3 },
  { nameAr: 'نجارة', nameFr: 'Menuiserie', icon: 'carpenter', orderIndex: 4 },
  { nameAr: 'تبليط وسيراميك', nameFr: 'Carrelage', icon: 'tiler', orderIndex: 5 },
  { nameAr: 'جبس وديكور', nameFr: 'Plâtrerie et Décoration', icon: 'plaster', orderIndex: 6 },
  { nameAr: 'حدادة ولحام', nameFr: 'Serrurerie et Soudure', icon: 'welder', orderIndex: 7 },
  { nameAr: 'تكييف وتبريد', nameFr: 'Climatisation et Réfrigération', icon: 'ac', orderIndex: 8 },
  { nameAr: 'صيانة منزلية', nameFr: 'Entretien Ménager', icon: 'maintenance', orderIndex: 9 },
  { nameAr: 'نقل وتنظيف', nameFr: 'Transport et Nettoyage', icon: 'cleaning', orderIndex: 10 },
];

const subServices: { parent: string; items: { nameAr: string; nameFr: string; icon?: string }[] }[] = [
  {
    parent: 'سباكة',
    items: [
      { nameAr: 'تركيب وصيانة سخانات', nameFr: 'Installation et entretien de chauffe-eau' },
      { nameAr: 'تسليك مجاري', nameFr: 'Débouchage de canalisations' },
      { nameAr: 'تركيب خلاطات ومواسير', nameFr: 'Installation de robinets et tuyaux' },
    ],
  },
  {
    parent: 'كهرباء',
    items: [
      { nameAr: 'تمديد أسلاك وتوصيلات', nameFr: 'Câblage et connexions électriques' },
      { nameAr: 'تركيب لوحات كهربائية', nameFr: 'Installation de tableaux électriques' },
      { nameAr: 'إصلاح أعطال كهربائية', nameFr: 'Réparation de pannes électriques' },
    ],
  },
  {
    parent: 'دهان',
    items: [
      { nameAr: 'دهان داخلي', nameFr: 'Peinture intérieure' },
      { nameAr: 'دهان خارجي', nameFr: 'Peinture extérieure' },
    ],
  },
  {
    parent: 'نجارة',
    items: [
      { nameAr: 'تصنيع وتركيب مطابخ', nameFr: 'Fabrication et installation de cuisines' },
      { nameAr: 'أبواب وشبابيك', nameFr: 'Portes et fenêtres' },
    ],
  },
  {
    parent: 'تبليط وسيراميك',
    items: [
      { nameAr: 'تبليط أرضيات', nameFr: 'Carrelage de sols' },
      { nameAr: 'تركيب سيراميك جدران', nameFr: 'Installation de céramique murale' },
    ],
  },
  {
    parent: 'جبس وديكور',
    items: [
      { nameAr: 'أسقف جبسية معلقة', nameFr: 'Plafonds suspendus en plâtre' },
      { nameAr: 'ديكورات جبسية', nameFr: 'Décorations en plâtre' },
    ],
  },
  {
    parent: 'حدادة ولحام',
    items: [
      { nameAr: 'أبواب حديدية وشبابيك', nameFr: 'Portes et fenêtres métalliques' },
      { nameAr: 'هياكل معدنية', nameFr: 'Structures métalliques' },
    ],
  },
  {
    parent: 'تكييف وتبريد',
    items: [
      { nameAr: 'تركيب مكيفات', nameFr: 'Installation de climatiseurs' },
      { nameAr: 'صيانة وتنظيف مكيفات', nameFr: 'Entretien et nettoyage de climatiseurs' },
    ],
  },
  {
    parent: 'صيانة منزلية',
    items: [
      { nameAr: 'صيانة عامة', nameFr: 'Entretien général' },
      { nameAr: 'إصلاح أثاث', nameFr: 'Réparation de meubles' },
    ],
  },
  {
    parent: 'نقل وتنظيف',
    items: [
      { nameAr: 'نقل عفش', nameFr: 'Déménagement' },
      { nameAr: 'تنظيف منازل ومكاتب', nameFr: 'Nettoyage de maisons et bureaux' },
    ],
  },
];

async function main() {
  console.log('🌱 بدء بذر البيانات...');

  for (const cat of categories) {
    const created = await prisma.service.upsert({
      where: { id: cat.nameAr },
      update: {},
      create: { id: cat.nameAr, ...cat },
    });
    console.log(`  ✅ فئة: ${cat.nameAr}`);

    const sub = subServices.find((s) => s.parent === cat.nameAr);
    if (sub) {
      for (const item of sub.items) {
        await prisma.service.create({
          data: {
            nameAr: item.nameAr,
            nameFr: item.nameFr,
            icon: item.icon || cat.icon,
            parentId: created.id,
            orderIndex: sub.items.indexOf(item) + 1,
          },
        });
      }
      console.log(`     └→ ${sub.items.length} خدمات فرعية`);
    }
  }

  console.log('✅ تم بذر 10 فئات وخدماتها الفرعية بنجاح');
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
