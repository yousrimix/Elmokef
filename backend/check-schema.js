const {Pool} = require('pg');
const pool = new Pool({connectionString: 'postgresql://postgres:postgres@localhost:5432/elmokef'});
pool.query("SELECT column_name FROM information_schema.columns WHERE table_name='artisan' AND (column_name='latitude' OR column_name='longitude')")
  .then(r => {
    console.log('Columns:', r.rows.map(c => c.column_name).join(', ') || 'NONE');
    pool.end();
  })
  .catch(e => {
    console.log('ERR:', e.message);
    pool.end();
  });
