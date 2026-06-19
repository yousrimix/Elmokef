const { Pool } = require('pg');
const bcrypt = require('bcrypt');

async function main() {
  const pool = new Pool({ connectionString: 'postgresql://postgres:postgres@localhost:5432/elmokef' });
  
  // Check password
  const r = await pool.query("SELECT email, password FROM users WHERE email='admin@elmokef.ma'");
  console.log('Email:', r.rows[0].email);
  console.log('Hash length:', r.rows[0].password?.length);
  console.log('Hash:', r.rows[0].password);
  
  // Test bcrypt
  console.log('Match admin123:', bcrypt.compareSync('admin123', r.rows[0].password));
  
  // If not matching, reset all passwords
  const salt = bcrypt.genSaltSync(10);
  const hash = bcrypt.hashSync('admin123', salt);
  console.log('New hash:', hash);
  
  await pool.query("UPDATE users SET password = $1 WHERE email = 'admin@elmokef.ma'", [hash]);
  console.log('✅ Admin password reset');
  
  await pool.end();
}
main().catch(e => { console.error(e); process.exit(1); });
