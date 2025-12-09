import { EmailVerificationModel } from "../models/emailVerification.model.js";
import { UserModel } from "../models/user.model.js";
import { sendOtpEmail } from "../services/emailVerification.service.js";
import {generateOTP} from "../utils/otp.js"

export const verifyEmail = async (req, res) => {
    try {
        const { token } = req.query;
        if(!token){
            return res.status(400).json({ 
                success: false,
                message: "Token is required"
            })
        }

        // Find token
        const record = await EmailVerificationModel.verifyToken(token);

        if (!record) {
            return res.status(400).json({
                success: false,
                message: "Invalid or expired verification otp"
            });
        }

        // Mark user verified
        await UserModel.markVerified(record.user_id);

        // Delete used token
        await EmailVerificationModel.deleteToken(record.user_id);

        return res.status(200).json({
            success: true,
            message: "Email verified successfully!"
        });

    } catch (error) {
        return res.status(500).json({ success: false, from:"verify email", message: error.message });
    }
};



export const resendVerificationEmail = async (req, res) => {
    try {
        const { email } = req.body;
        console.log(req.body)

        const user = await UserModel.getUserByEmail(email.toLowerCase());
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        if (user.isVerified) {
            return res.status(400).json({ message: "User already verified" });
        }

        // Delete old token
        await EmailVerificationModel.deleteOtp(user.user_id);

        // // Generate new token
        // const token = generateEmailToken();
        // const expires_at = new Date(Date.now() + 10 * 60 * 1000);

        // await EmailVerificationModel.storeToken(user.user_id, token, expires_at);

        // await sendOtpEmail(email, token);

            // generate OTP & expiry (10 minutes)
            const otp = generateOTP();
            const expires_at = new Date(Date.now() + 10 * 60 * 1000);
        
            // store OTP for this user
            await EmailVerificationModel.storeOtp(user.user_id, otp, expires_at);
        
            // Send email
            await sendOtpEmail(user.email, otp);

        return res.json({
            success: true, 
            message: "OTP resent!"
        });

    } catch (error) {
        return res.status(500).json({ from :"resendVerificationEmail",message: error.message });
    }
};
