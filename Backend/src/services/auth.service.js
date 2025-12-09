
import pool from "../config/pool.js";
import { v4 as uuidv4 } from "uuid";
import { UserModel } from '../models/user.model.js';

// // Validators
// import {
//   isValidName,
//   isValidRoll,
//   isValidEmailForRoll,
//   isValidSemester,
//   isValidProgramme,
//   isValidBatch,
//   isValidPassword,
//   isValidDesignationOrDept,
// } from "../validators/validation.validator.js";

// JWT utils
import { signAccessToken, signRefreshToken , hashToken} from "../utils/jwt.js";
import dotenv from "dotenv";
// import { TeacherModel } from "../models/teacher.model.js";
// import { hashPassword, comparePassword } from "../utils/passwordHashed.js";
// import { StudentModel } from '../models/student.model.js';
import { RefreshTokenModel } from '../models/refreshToken.model.js';

dotenv.config();

/**
 * Helper to throw formatted error
 */
const throwError = (status, message) => {
  const err = new Error(message);
  err.status = status;
  throw err;
};


// compute expires_at for DB and cookie maxAge (ms)
const refreshExpire = process.env.REFRESH_EXPIRE || "1d";
const cookiesName = process.env.COOKIE_NAME || "refreshToken";


/**
 * Refresh flow (rotation):
 * - client sends raw refresh token
 * - server hashes it and finds DB record where token_hash matches, not revoked, and not expired
 * - if found: revoke it (set revoked=true), issue new refresh token and access token, store new token hash
 */
export const rotateRefreshToken = async (rawToken) => {
  const tokenHash =await hashToken(rawToken);

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const selectQ = `SELECT token_id, user_id, revoked, expires_at
                     FROM refresh_tokens
                     WHERE token_hash = $1
                     FOR UPDATE`;
    const sel = await client.query(selectQ, [tokenHash]);
    const row = sel.rows[0];

    if (!row) {
      throw new Error("Invalid refresh token");
    }
    if (row.revoked) throw new Error("Refresh token revoked");
    if (new Date(row.expires_at) < new Date()) throw new Error("Refresh token expired");

    // revoke old token
    const revokeQ = `UPDATE refresh_tokens SET revoked = TRUE WHERE token_id = $1`;
    await client.query(revokeQ, [row.token_id]);

    // create new token
    const { token: newToken, hash: newHash } = createRefreshToken();
    const newExpiresAt = new Date(Date.now() + REFRESH_DAYS * 24 * 60 * 60 * 1000);
 
    const insertQ = `INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
                     VALUES ($1, $2, $3)`;
    await client.query(insertQ, [row.user_id, newHash, newExpiresAt]);

    // create new access token
    const accessToken = signAccessToken({ userId: row.user_id });

    await client.query("COMMIT");
    return { accessToken, refreshToken: newToken, userId: row.user_id };
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
};


/**
 * Find refresh token row by token string
 */
export const findRefreshToken = async (token) => {
  
  const q = `
    SELECT token_id, user_id, token_hash, expires_at, revoked
    FROM refresh_tokens
    WHERE user_id = $1 AND revoked = FALSE
    ORDER BY created_at DESC
    LIMIT 1
  `;
  const { rows } = await pool.query(q, [token]);
  return rows[0];
};


// Cleanup old revoked refresh tokens (optional maintenance task)
export const cleanupOldRefreshTokens = async () => {
  const q = `
    DELETE FROM refresh_tokens
    WHERE revoked = TRUE
      AND expires_at < NOW() - INTERVAL '5 days'
  `;
  await pool.query(q);
};


// export const logoutUser = async (req, res) => {
//     try {
//         const refreshToken = req.cookies.refreshToken;

//         if (refreshToken) {
//             const hashed = hashToken(refreshToken);
//             const token = await RefreshTokenModel.findByHash(hashed);

//             if (token) {
//                 await RefreshTokenModel.revokeRefreshToken(token.token_id);
//             }
//         }

//         res.clearCookie("accessToken");
//         res.clearCookie("refreshToken");

//         return res.json({
//             success: true,
//             message: "Logged out successfully"
//         });

//     } catch (err) {
//         return res.status(500).json({ message: err.message });
//     }
// };

export const logoutUser = async (req, res) => {
  try {
    const refreshToken = req.cookies.refreshToken;

    if (refreshToken) {
      const hashed = hashToken(refreshToken);
      const tokenRecord = await RefreshTokenModel.findByHash(hashed);
      if (tokenRecord) {
        await RefreshTokenModel.revokeRefreshToken(tokenRecord.token_id);
      }
    } else {
    return res.status(500).json({
      success: false,
      message: "Refresh Token unavailable.",
    });
    }
    res.clearCookie(cookiesName, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
    });
    return res.status(200).json({
      success: true,
      message: "Logged out successfully",
    });
  } catch (error) {
    console.error("LOGOUT ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
