import pool from "../config/pool.js";

export class RefreshTokenModel { 
  
    static async getAllRefreshTokens(user_id) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const q = "SELECT * FROM refresh_tokens WHERE user_id = $1";
            const { rows } = await client.query(q, [user_id]);
            await client.query("COMMIT");
            return rows; 
        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }

    static async findByHash(token_hash) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const q = "SELECT * FROM refresh_tokens WHERE token_hash = $1 LIMIT 1";
            const { rows } = await client.query(q, [token_hash]);
            await client.query("COMMIT");
            return rows[0];
        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }



    static async getRefreshTokenById(token_id) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const q = "SELECT * FROM refresh_tokens WHERE token_id = $1";
            const { rows } = await client.query(q, [token_id]);
            await client.query("COMMIT");
            return rows[0];
        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }


    static async insertRefreshToken({ user_id, token_hash, expires_at, revoked }) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = `
                INSERT INTO refresh_tokens (user_id, token_hash, expires_at, revoked)
                VALUES ($1, $2, $3, $4)
                RETURNING *
            `;

            const { rows } = await client.query(q, [
                user_id,
                token_hash,
                expires_at,
                revoked
            ]);

            await client.query("COMMIT");
            return rows[0];

        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }


    static async updateRefreshToken(token_id, updates) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const fields = [];
            const values = [];
            let index = 1;

            if (updates.token_hash !== undefined) {
                fields.push(`token_hash = $${index++}`);
                values.push(updates.token_hash);
            }
            if (updates.expires_at !== undefined) {
                fields.push(`expires_at = $${index++}`);
                values.push(updates.expires_at);
            }
            if (updates.revoked !== undefined) {
                fields.push(`revoked = $${index++}`);
                values.push(updates.revoked);
            }

            if (fields.length === 0) throw new Error("No fields to update");

            const q = `
                UPDATE refresh_tokens
                SET ${fields.join(", ")}
                WHERE token_id = $${index}
                RETURNING *
            `;

            values.push(token_id);

            const { rows } = await client.query(q, values);

            await client.query("COMMIT");
            return rows[0];

        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }


    static async deleteRefreshToken(token_id) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = "DELETE FROM refresh_tokens WHERE token_id = $1";
            await client.query(q, [token_id]);

            await client.query("COMMIT");
            return true;

        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }


    static async getRefreshTokensByUser(user_id) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = "SELECT * FROM refresh_tokens WHERE user_id = $1";
            const { rows } = await client.query(q, [user_id]);

            await client.query("COMMIT");
            return rows;

        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }


    static async getValidRefreshTokensByUser(user_id) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = `
                SELECT * FROM refresh_tokens 
                WHERE user_id = $1 AND revoked = FALSE AND expires_at > NOW()
            `;
            const { rows } = await client.query(q, [user_id]);

            await client.query("COMMIT");
            return rows;

        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }


    static async revokeRefreshToken(token_id) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = "UPDATE refresh_tokens SET revoked = TRUE WHERE token_id = $1 RETURNING *";
            const { rows } = await client.query(q, [token_id]);

            await client.query("COMMIT");
            return rows[0];

        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }


    static async revokeAllRefreshTokensByUser(user_id) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = "UPDATE refresh_tokens SET revoked = TRUE WHERE user_id = $1";
            await client.query(q, [user_id]);

            await client.query("COMMIT");
            return true;

        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }
}

// Usage example:
// import { RefreshTokenModel } from '../models/refreshToken.model.js';
//
// const example = async () => {
//   try {
//     const tokens = await RefreshTokenModel.getAllRefreshTokens();
//     console.log(tokens);
//   } catch (error) {
//     console.error('Error:', error);
//   }
// };
