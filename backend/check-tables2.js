const {Pool} = require('pg');
const pool = new Pool({
  connectionString: 'postgresql://postgres:postgres@localhost:5432/elmokef?schema=public'
});

async function main() {
  const res = await pool.query(
    "SELECT column_name, data_type FROM information_schema.columns WHERE table_name='artisan_profiles'"
  );
  console.log('artisan_profiles columns:');
  res.rows.forEach(c => console.log(' - ' + c.column_name + ' (' + c.data_type + ')'));
  
  const rows = await pool.query("SELECT id FROM artisan_profiles ORDER BY id");
  console.log('\nExisting IDs:');
  rows.rows.forEach(r => console.log(' - ' + r.id));
  
  await pool.end();
}

main().catch(e => { console.error('ERR:', e.message); pool.end(); });
