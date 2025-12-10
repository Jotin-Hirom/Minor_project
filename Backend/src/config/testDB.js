export const testConnection = async (pool) => {
  let client;

  try {
    client = await pool.connect();   // if this fails, client stays undefined
    console.log("DB Connection: OK");

  } catch (err) {
    console.error("DB Connection Error:", err.message);
  } finally {
    // only release if client exists
    if (client) client.release(); 
  }
}; 