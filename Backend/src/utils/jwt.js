import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import { hashTokened, comparehashTokened } from "./tokenHash.js"
dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET;
const REFRESH_SECRET = process.env.REFRESH_SECRET;
const JWT_EXPIRE = process.env.JWT_EXPIRE || "30m";
const REFRESH_EXPIRE = process.env.REFRESH_EXPIRE || "3d";
 
// Sign access token 
export const signAccessToken = (payload) => {
  // payload: e.g. { sub: user_id, role, email }
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRE });
}; 

// Sign refresh token
export const signRefreshToken = (payload) => {
  return jwt.sign(payload, REFRESH_SECRET, { expiresIn: REFRESH_EXPIRE });
};

// Verify access token
export const verifyAccessToken = (token) => { 
  return jwt.verify(token, JWT_SECRET);
};

// Verify refresh token
export const verifyRefreshToken = (token) => {
  return jwt.verify(token, REFRESH_SECRET); 
}; 

// Function to hash a token
export const hashToken= async (token) =>{
    const token_hash = hashTokened(token);
    return token_hash;
};

export const compareHash = async (token, hashedToken) => {
  return comparehashTokened(token, hashedToken);
}