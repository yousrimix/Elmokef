const {Pool} = require('pg');
const pool = new Pool({
  connectionString: 'postgresql://postgres:postgres@localhost:5432/elmokef?schema=public'
});

async function main() {
  // Add lat/lng columns
  await pool.query("ALTER TABLE artisan_profiles ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION DEFAULT 33.5731");
  await pool.query("ALTER TABLE artisan_profiles ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION DEFAULT -7.5898");
  console.log('✅ Added columns');
  
  // Get IDs and update each with unique coordinates
  const ids = await pool.query("SELECT id FROM artisan_profiles ORDER BY created_at");
  const coords = [
    [33.5731, -7.5898],
    [33.5780, -7.5950],
    [33.5700, -7.5850]
  ];
  
  for (let i = 0; i < ids.rows.length && i < coords.length; i++) {
    const [lat, lng] = coords[i];
    await pool.query("UPDATE artisan_profiles SET latitude=$1, longitude=$2 WHERE id=$3", [lat, lng, ids.rows[i].id]);
    console.log(`  ${ids.rows[i].id}: ${lat}, ${lng}`);
  }
  
  console.log('✅ Updated coordinates');
  await pool.end();
}

main().catch(e => { console.error('ERR:', e.message); pool.end(); });
