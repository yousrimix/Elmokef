const bcrypt = require('bcrypt');
const { Pool } = require('pg');

async function main() {
  const hash = bcrypt.hashSync('admin123', 10);
  console.log('Hash:', hash);
  
  const pool = new Pool({ connectionString: 'postgresql://postgres:postgres@localhost:5432/elmokef' });
  const r = await pool.query("UPDATE users SET password = $1 WHERE email = 'admin@elmokef.ma'", [hash]);
  console.log(`✅ Updated ${r.rowCount} row(s)`);
  
  // Also set a hash for 'password' for artisan accounts
  const r2 = await pool.query("UPDATE users SET password = $1 WHERE role = 'ARTISAN'", [hash]);
  console.log(`✅ Updated ${r2.rowCount} artisan(s)`);
  
  await pool.end();
}

main().catch(e => { console.error('❌', e.message); process.exit(1); });
