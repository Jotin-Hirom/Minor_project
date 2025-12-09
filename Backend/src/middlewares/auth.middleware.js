import { verifyAccessToken } from "../utils/jwt.js";
import { UserModel } from "../models/user.model.js";
 
export async function auth(req, res, next) {
  const authHeader = req.headers.authorization || "";
  if (!authHeader || !authHeader.startsWith("Bearer")) {
  return res.status(401).json({ error: "No token provided" });
  }
  const [, token] = authHeader.split(" ");
  if (!token) return res.status(401).json({ error: "Invalid token" });
  try {
    const payload = verifyAccessToken(token);
    console.log(payload);

    req.user = payload;
    next();  
  } catch {
    res.status(401).json({ error: "Unauthorized Token." });
  }  
  const user =await UserModel.getUserById(req.user.id);
  if (!user) {
    return res.status(401).json({ error: "User does not exist" });
  }
}

export function requireRole(...allowedRoles) {
  return (req, res, next) => {
    try { 
      // Must be authenticated first
      if (!req.user) {
        return res.status(401).json({ error: "Not authenticated" });
      }

      const userRole = req.user.role;

      // Check if user's role matches allowed roles
      if (!allowedRoles.includes(userRole)) {
        return res.status(403).json({
          error: "Access denied. Insufficient permissions.",
        });
      }

      next();
    } catch (err) {
      console.error("Role middleware error:", err);
      res.status(500).json({ error: "Server error" });
    }
  };
}
