import { EmailVerificationModel } from "../models/emailVerification.model.js";
import { UserModel } from "../models/user.model.js";
import { hashPassword } from "../utils/passwordHashed.js";
import {generateOTP} from "../utils/otp.js"
import {sendOtpEmail} from "../services/emailVerification.service.js"

export const verifyOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: "Email and OTP are required",
      });
    }

    const user = await UserModel.getUserByEmail(email.toLowerCase()); 
    if (!user) {
      return res.status(400).json({
        success: false,
        message: "Invalid email or OTP",
      });
    }

    // Find OTP record
    const record = await EmailVerificationModel.findValidOtp(user.user_id, otp);

    if (!record) {
      return res.status(400).json({
        success: false,
        message: "Invalid or expired OTP",
      });
    }

    // Mark user as verified
    await UserModel.markVerified(user.user_id);

    // Delete used OTP
    await EmailVerificationModel.deleteOtp(user.user_id);

    return res.status(200).json({
      success: true,
      message: "Email verified successfully!",
    });

  } catch (error) {
    console.error("VERIFY OTP ERROR:", error);
    return res.status(500).json({ success: false, message: error.message });
  }
};


export const resendOtp = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email is required",
      });
    }

    const user = await UserModel.getUserByEmail(email);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (user.isVerified) {
      return res.status(400).json({
        success: false,
        message: "User already verified",
      });
    }

    // Delete old OTPs
    await EmailVerificationModel.deleteOtp(user.user_id);

    // Generate new OTP
    const otp = generateOTP();
    const expires_at = new Date(Date.now() + 10 * 60 * 1000); // 10 mins

    // Save new OTP
    await EmailVerificationModel.storeOtp(user.user_id, otp, expires_at);

    // Send OTP via Resend
    await sendOtpEmail(user.email, otp);

    return res.status(200).json({
      success: true,
      message: "OTP resent successfully",
    });

  } catch (error) {
    console.error("RESEND OTP ERROR:", error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email)
      return res.status(400).json({ success: false, message: "Email is required" });

    const user = await UserModel.getUserByEmail(email);

    if (!user)
      return res.status(404).json({ success: false, message: "User not found" });

    // Remove old OTP
    await EmailVerificationModel.deleteOtp(user.user_id);

    // Generate a new OTP
    const otp = generateOTP();
    const expires_at = new Date(Date.now() + 10 * 60 * 1000);

    // Save OTP
    await EmailVerificationModel.storeOtp(user.user_id, otp, expires_at);

    // Email OTP
    await sendOtpEmail("reset",email, otp);

    return res.status(200).json({
      success: true,
      message: "Password reset OTP sent to your email",
    });

  } catch (error) {
    console.error("FORGOT PASSWORD ERROR:", error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

export const verifyForgotOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp)
      return res.status(400).json({ success: false, message: "Email and OTP required" });

    const user = await UserModel.getUserByEmail(email);
    if (!user)
      return res.status(404).json({ success: false, message: "User not found" });

    const record = await EmailVerificationModel.findValidOtp(user.user_id, otp);

    if (!record) {
      return res.status(400).json({
        success: false,
        message: "Invalid or expired OTP",
      });
    }

    return res.status(200).json({
      success: true,
      message: "OTP verified. You may now reset password.",
    });

  } catch (error) {
    console.error("VERIFY FORGOT OTP ERROR:", error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

export const resetPassword = async (req, res) => {
  try {
    const { email, new_password } = req.body;

    if (!email || !new_password)
      return res.status(400).json({ success: false, message: "Email and new password are required" });

    const user = await UserModel.getUserByEmail(email);

    if (!user)
      return res.status(404).json({ success: false, message: "User not found" });

    const hashed = await hashPassword(new_password);

    await UserModel.updateUserPassword(user.user_id, hashed);

    return res.status(200).json({
      success: true,
      message: "Password reset successful",
    });

  } catch (error) {
    console.error("RESET PASSWORD ERROR:", error);
    return res.status(500).json({ success: false, message: error.message });
  }
};