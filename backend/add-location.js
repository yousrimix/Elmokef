const {Pool} = require('pg');
const pool = new Pool({
  connectionString: 'postgresql://postgres:postgres@localhost:5432/elmokef?schema=public'
});

async function main() {
  const res = await pool.query(
    "SELECT column_name FROM information_schema.columns WHERE table_name='artisan' AND (column_name='latitude' OR column_name='longitude')"
  );
  
  const existing = res.rows.map(r => r.column_name);
  console.log('Existing geo columns:', existing.length > 0 ? existing.join(', ') : 'NONE');
  
  if (!existing.includes('latitude')) {
    await pool.query('ALTER TABLE artisan ADD COLUMN latitude DOUBLE PRECISION DEFAULT 33.5731');
    console.log('✅ Added latitude');
  }
  if (!existing.includes('longitude')) {
    await pool.query('ALTER TABLE artisan ADD COLUMN longitude DOUBLE PRECISION DEFAULT -7.5898');
    console.log('✅ Added longitude');
  }
  
  // Update unique artisan coordinates
  await pool.query("UPDATE artisan SET latitude=33.5731, longitude=-7.5898 WHERE id='art-uuid-001'");
  await pool.query("UPDATE artisan SET latitude=33.5780, longitude=-7.5950 WHERE id='art-uuid-002'");
  await pool.query("UPDATE artisan SET latitude=33.5700, longitude=-7.5850 WHERE id='art-uuid-003'");
  
  // Verify
  const verify = await pool.query("SELECT id, latitude, longitude FROM artisan");
  verify.rows.forEach(r => console.log(`  ${r.id}: ${r.latitude}, ${r.longitude}`));
  
  await pool.end();
  console.log('✅ Done!');
}

main().catch(e => { console.error('ERR:', e.message); pool.end(); });
