import express from "express";
import { registerUser, login, refreshAccessToken, logoutUser, me } from "../controllers/auth.controller.js";
import { auth } from "../middlewares/auth.middleware.js";
import { roleBasedSignupValidator } from "../validators/signup.validator.js";
import { verifyEmail, resendVerificationEmail } from "../controllers/emailVerification.controller.js";
import { validateUserVerification } from "../validators/userLogin.validator.js";
import { verifyOtp,resetPassword,verifyForgotOtp,forgotPassword } from "../controllers/otpVerification.controller.js";

const router = express.Router();
 

/**
 * POST /api/auth/signup
 * Body must include "role" = 'student' | 'teacher' and the required fields per role.
 */

// Signup (existing)
router.post("/signup", roleBasedSignupValidator, registerUser);
// router.get("/verify-email", verifyEmail); //Node Mailer does not work.
router.post("/verify", verifyOtp);
router.post("/resend-otp", resendVerificationEmail);
router.post("/forgot-password", forgotPassword);
router.post("/verify-forgot", verifyForgotOtp);
router.post("/reset-password", resetPassword);

// Login -> returns access token + sets refresh cookie
router.post("/login", validateUserVerification, login);
// Refresh endpoint -> reads refresh cookie and returns new access token
router.post("/refresh", refreshAccessToken);
// Logout -> revoke refresh token & clear cookie
router.post("/logout", auth ,logoutUser);

export default router;


