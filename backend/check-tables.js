const {Pool} = require('pg');
const pool = new Pool({
  connectionString: 'postgresql://postgres:postgres@localhost:5432/elmokef?schema=public'
});

async function main() {
  const tables = await pool.query(
    "SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name"
  );
  console.log('Tables in public schema:');
  tables.rows.forEach(t => console.log(' - ' + t.table_name));
  
  // Find artisan-related table
  const artisanTable = tables.rows.find(t => t.table_name.toLowerCase().includes('artisan'));
  if (artisanTable) {
    console.log('\nArtisan table found:', artisanTable.table_name);
    const cols = await pool.query(
      "SELECT column_name, data_type FROM information_schema.columns WHERE table_name=$1",
      [artisanTable.table_name]
    );
    console.log('Columns:');
    cols.rows.forEach(c => console.log(' - ' + c.column_name + ' (' + c.data_type + ')'));
  }
  
  await pool.end();
}

main().catch(e => { console.error('ERR:', e.message); pool.end(); });
