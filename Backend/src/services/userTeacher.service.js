import pool from "../config/pool.js";
import { EmailVerificationModel } from "../models/emailVerification.model.js";
import { sendOtpEmail } from "../services/emailVerification.service.js";
import { generateOTP } from "../utils/otp.js";

export async function createUserWithTeacher(userData, teacherData) {
    const client = await pool.connect();
    try {
        await client.query("BEGIN"); 

        // Create user 
        const userQuery = `
            INSERT INTO users (email, password_hash, role)
            VALUES ($1, $2, $3)
            RETURNING user_id, email, role
        `;
        const { rows: userRows } = await client.query(userQuery, [
            userData.email.toLowerCase(),
            userData.password_hash,
            userData.role
        ]);
        const user = userRows[0];
        await client.query("COMMIT");
        await client.query("BEGIN");

        // Create teacher
        const teacherQuery = `
            INSERT INTO teachers (
                user_id, tname, designation, dept, photo_url
            )
            VALUES ($1, $2, $3, $4, $5)
            RETURNING *
        `;

        const { rows: teacherRows } = await client.query(teacherQuery, [
            user.user_id,
            teacherData.tname.toUpperCase(),
            teacherData.designation,
            teacherData.dept,
            teacherData.photo_url
        ]);

        const teacher = teacherRows[0];
        await client.query("COMMIT");

            // generate OTP & expiry (10 minutes)
            const otp = generateOTP();
            const expires_at = new Date(Date.now() + 10 * 60 * 1000);
        
            // store OTP for this user
            await EmailVerificationModel.storeOtp(user.user_id, otp, expires_at);
        
            // Send email
            await sendOtpEmail(user.email, otp); 

        await client.query("COMMIT");

        return { user, teacher };

    } catch (error) {
        await client.query("ROLLBACK");
        throw error;
    } finally {
        client.release();
    }
}
