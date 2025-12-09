import pool  from "../config/pool.js";
 
export async function listUsers() {
  const { rows } = await pool.query("SELECT user_id, email, role, created_at FROM users ORDER BY created_at DESC");
  return rows;
}

 