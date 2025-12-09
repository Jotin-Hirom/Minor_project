import pool from "../config/pool.js";

export class EmailVerificationModel {
  static async storeOtp(user_id, otp, expires_at) {
    const client = await pool.connect();
    try { 
      await client.query("BEGIN");

      // delete old OTPs for this user (optional but cleaner)
      await client.query(
        "DELETE FROM email_verification_tokens WHERE user_id = $1",
        [user_id]
      );

      const q = `
        INSERT INTO email_verification_tokens (user_id, token, expires_at)
        VALUES ($1, $2, $3)
      `;
      await client.query(q, [user_id, otp, expires_at]);

      await client.query("COMMIT");
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  }

  static async findValidOtp(user_id, otp) {
    const q = `
      SELECT * FROM email_verification_tokens
      WHERE user_id = $1
        AND token = $2
        AND expires_at > NOW()
      LIMIT 1
    `;
    const { rows } = await pool.query(q, [user_id, otp]);
    
    return rows[0];
  }

  static async deleteOtp(user_id) {
    await pool.query(
      "DELETE FROM email_verification_tokens WHERE user_id = $1",
      [user_id]
    );
  }
}
 





// import pool from "../config/pool.js";

// export class EmailVerificationModel {
//     static async storeToken(user_id, token, expires_at) {
//         const client = await pool.connect();
//         try {
//             await client.query("BEGIN");

//             const query = `
//                 INSERT INTO email_verification_tokens (user_id, token, expires_at)
//                 VALUES ($1, $2, $3)
//             `;
//             await client.query(query, [user_id, token, expires_at]);

//             await client.query("COMMIT");
//         } catch (error) {
//             await client.query("ROLLBACK");
//             throw error;
//         } finally {
//             client.release();
//         }
//     }

//     static async verifyToken(token) {
//         const q = `
//             SELECT * FROM email_verification_tokens
//             WHERE token = $1 AND expires_at > NOW()
//             LIMIT 1
//         `;
//         const { rows } = await pool.query(q, [token]);
//         return rows[0];
//     }

//     static async deleteToken(user_id) {
//         await pool.query(`DELETE FROM email_verification_tokens WHERE user_id = $1`, [user_id]);
//     }
// }
