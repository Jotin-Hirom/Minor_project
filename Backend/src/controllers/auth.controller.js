// Authentication controller for login, refresh, logout
import { signAccessToken, signRefreshToken, verifyRefreshToken, hashToken, compareHash } from "../utils/jwt.js";
import bcrypt from "bcryptjs";
import { createUserWithTeacher } from "../services/userTeacher.service.js";
import { createUserWithStudent } from "../services/userStudent.service.js";
import { RefreshTokenModel } from '../models/refreshToken.model.js';
import {  comparePassword } from "../utils/passwordHashed.js";
import { UserModel } from '../models/user.model.js';
import env from "dotenv";
import { auth } from "../middlewares/auth.middleware.js";
import pool from "../config/pool.js";
env.config();
// compute expires_at for DB and cookie maxAge (ms)
const refreshExpire = process.env.REFRESH_EXPIRE || "3d";
const cookiesName = process.env.COOKIE_NAME || "refreshToken";
 
/**
 * Register user (student or teacher) 
 * Expects JSON body with "role" field.
 */
export const registerUser = async (req, res) => {
    try {
        const { email, password, role } = req.body;

        const password_hash = await bcrypt.hash(password, 10);

        if (role === "student") {
            const { 
                roll_no, sname, semester, programme, batch, photo_url
            } = req.body;

            const result = await createUserWithStudent(
                { email, password_hash, role },
                { roll_no, sname, semester, programme, batch, photo_url }
            );

            return res.status(201).json({
                success: true,
                message: "Student account created successfully. Please verify your email.",
                data: result
            });
        }

        if (role === "teacher") {
            const {
                 tname, designation, dept, photo_url
            } = req.body;
 
            const result = await createUserWithTeacher(
                { email, password_hash, role },
                {  tname, designation, dept, photo_url}
            );

            return res.status(201).json({
                success: true,
                message: "Teacher account created successfully. Please verify your email.",
                data: result
            });
        }

        return res.status(406).json({
            success: false,
            message: "Invalid role. Must be 'student' or 'teacher'."
        });

    } catch (error) {
        console.error("REGISTER ERROR:", error);
        return res.status(500).json({
            success: false,
            message: error.message
        });
    }
};

// Login controller  
export const login = async (req, res) => {
  try {
    const { email, password, role } = req.body;

    if (!email || !password || !role) {
      return res.status(400).json({
        success: false,
        message: "Email, password and role are required",
      });
    }

    // Find user
    const user = await UserModel.getUserByEmail(email);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: "User not found.",
      });
    }

    // Role match
    if (user.role !== role) {
      return res.status(403).json({
        success: false,
        message: `This account is registered as '${user.role}', not '${role}'.`,
      });
    }

    // Email verification
    if (!user.isverified) {
      return res.status(403).json({
        success: false,
        message: "Please verify your email before logging in.",
      });
    }

    // Validate password
    const isValidPassword = await comparePassword(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        message: "Entered wrong password.",
      });
    }
    // Generate tokens
    const accessToken = signAccessToken({
      id: user.user_id,
      role: user.role,
      email: user.email,
    });

    try {
      const refreshTokens = await RefreshTokenModel.getAllRefreshTokens(user.user_id);
      console.log(refreshTokens)
      console.log(refreshTokens.length)
      const token = refreshTokens.find(t => !t.revoked);
      console.log(token)
      const refreshToken = signRefreshToken({ id: user.user_id });
      const hashedToken = await hashToken(refreshToken);
             // Parse refresh expiry (1d → ms)
        let maxAgeMs;
        const match = refreshExpire.match(/^(\d+)([smhd])$/);
        if (match) {
          const time = Number(match[1]);
          const unit = match[2];
          const unitMap = { s: 1000, m: 60000, h: 3600000, d: 86400000 };
          maxAgeMs = time * unitMap[unit];
        } else {
          maxAgeMs = 86400000; // default
        }

        const expires_at = new Date(Date.now() + maxAgeMs);
      if (refreshTokens.length < 1 || token.revoked===true || refreshTokens.token_hash === undefined) {

        // Store hashed refresh token in DB
        await RefreshTokenModel.insertRefreshToken({
          user_id: user.user_id,
          token_hash: hashedToken,
          expires_at: expires_at,
          revoked: false,
        });
      }

        // Set cookie
        const cookieOptions = {
          httpOnly: true,
          secure: process.env.NODE_ENV === "production",
          sameSite: "none",
          path: "/",
          maxAge: maxAgeMs,
        };
        res.cookie(cookiesName, refreshToken, cookieOptions);
    } catch (error) {
      console.error("LOGIN ERROR:", error);
      return res.status(500).json({
        success: false,
        message: error.message,
      });
    }

    // Send response
    return res.status(200).json({
      success: true,
      message: "Login successful.",
      accessToken,
      user: {
        id: user.user_id,
        email: user.email,
        role: user.role,
      },
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      from: "Login Controller",
      message: err.message,
    });
  }
};

// Logout controller
export const logoutUser = async (req, res, next) => {
  const user = await RefreshTokenModel.getAllRefreshTokens(req.user.id);
  const hashedToken = user[0].token_hash

  try {
    const refreshToken = req.cookies.cookiesName || req.body?.cookiesName;
    if (refreshToken) {
      if (!compareHash(hashedToken, refreshToken)) {
        return res.status(403).json({ message: "Invalid refresh token." });
      } 
      let payload;
      try {
        payload = verifyRefreshToken(hashedToken);
        // Revoke all refresh tokens for this user
        await RefreshTokenModel.revokeAllRefreshTokensByUser(payload.id);
      } catch (e) {
        // ignore invalid token — just clear cookie
        console.log("Error in Logout:", e);
      }
    }
    res.clearCookie(cookiesName, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "Strict",
    });

    return res.json({ success: true, message: "Logged out" });
  } catch (err) {
    next(err);
  }
};

// Refresh token controller
export const refreshAccessToken = async (req, res) => {
  const { email } = req.body;
  const user = await UserModel.getUserByEmail(email);
  if (!user) {
    return res.status(400).json({
      success: false,
      message: "User not found.",
    });
  } 
  const refreshDB = await RefreshTokenModel.getAllRefreshTokens(user.user_id);
  console.log(refreshDB)
  const hashedToken = refreshDB[0].token_hash;
  try {
    const token = req.cookies;
    console.log(req.cookies)

        if (!token) return res.status(401).json({ error: "Refresh token missing" });

        if (token) {
          if (!compareHash(hashedToken, token)) {
            return res.status(403).json({ message: "Invalid refresh token." });
          }
        }
        // verify signature
        let payload;
        try {
          payload = verifyRefreshToken(token);
        } catch(e){
          return res.status(401).json({ error: "Cannot verify refresh token" });
        }
        // DB lookup for this refresh token
      const tokens = await RefreshTokenModel.findByHash(hashedToken);

        if (!tokens) {
            return res.status(403).json({ message: "Token does not exist." });
        }

        // REVOKE OLD TOKEN
          await RefreshTokenModel.deleteRefreshToken(tokens.token_id);
        // await RefreshTokenModel.revokeRefreshToken(tokens.token_id);
        //This is done for saving db space.

        // GENERATE NEW TOKENS
      const newAccessToken = signAccessToken({
        id: user.user_id,
        role: user.role,
        email: user.email});

      const newRefreshToken = signRefreshToken(
        { id: user.user_id}
        );

      let maxAgeMs;
      const match = refreshExpire.match(/^(\d+)([smhd])$/);
      if (match) {
        const time = Number(match[1]);
        const unit = match[2];
        const unitMap = { s: 1000, m: 60000, h: 3600000, d: 86400000 };
        maxAgeMs = time * unitMap[unit];
      } else {
        maxAgeMs = 86400000; // default
      }

      const expires_at = new Date(Date.now() + maxAgeMs);

      const hashedNew = hashToken(newRefreshToken);

        // SAVE NEW REFRESH TOKEN
        await RefreshTokenModel.insertRefreshToken({
          user_id: user.user_id,
            token_hash: hashedNew,
            expires_at: expires_at,
            revoked: false
        });
        // SET COOKIES  
      res.cookie(cookiesName, newRefreshToken, {
            httpOnly: true,
            secure: process.env.NODE_ENV === "production",
            sameSite: "none",
            maxAge: maxAgeMs ,
            path: "/",
        });

        return res.json({
            success: true,
            accessToken: newAccessToken,
            message: "Token freshed successfully.",
          user: {
            id: user.user_id,
            email: user.email,
            role: user.role,
          }
        });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}


// Me controller {Specific users fetch}
export const me = async (req, res, next) => {
  try {
    const userId = req.user.id;   // added by verifyToken middleware
    const role = req.user.role;

    // 1. Fetch base user info
    const userQuery = `
      SELECT user_id, email, role, created_at
      FROM users
      WHERE user_id = $1
      LIMIT 1
    `;
    const userRes = await pool.query(userQuery, [userId]);
    const user = userRes.rows[0];
    if (!user) return res.status(404).json({ error: "User not found" });

    // 2. Load profile based on role
    let profileDetails = null;

    if (role === "student") {
      const q = `
        SELECT user_id, roll_no, sname, semester, programme, batch, photo_url
        FROM students
        WHERE user_id = $1
        LIMIT 1
      `;
      const r = await pool.query(q, [userId]);
      profileDetails = r.rows[0] || {};
    }

    if (role === "teacher") {
      const q = `
        SELECT user_id, abbr, tname, designation, specialization, dept, programme, photo_url
        FROM teachers
        WHERE user_id = $1
        LIMIT 1
      `;
      const r = await pool.query(q, [userId]);
      profileDetails = r.rows[0] || {};
    }

    // Admins don't have separate profile tables — return basic data only

    return res.json({
      user,
      profileDetails,
    });

  } catch (err) {
    next(err);
  }
};