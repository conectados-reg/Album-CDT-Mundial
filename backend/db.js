const { Pool } = require('pg');

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

function buildValues(rows, colCount) {
  return rows
    .map((_, i) => `(${Array.from({ length: colCount }, (_, j) => `$${i * colCount + j + 1}`).join(', ')})`)
    .join(', ');
}

module.exports = {
  query: (text, params) => pool.query(text, params),
  async one(text, params) {
    const { rows } = await pool.query(text, params);
    return rows[0] ?? null;
  },
  async all(text, params) {
    const { rows } = await pool.query(text, params);
    return rows;
  },
  buildValues,
};
