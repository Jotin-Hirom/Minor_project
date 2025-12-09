import pool from "../config/pool.js";
// import { generateEmailToken } from "../utils/emailToken.js";
import  {generateOTP}  from "../utils/otp.js";
import {sendOtpEmail} from "../services/emailVerification.service.js";
import { EmailVerificationModel } from "../models/emailVerification.model.js";


export async function createUserWithStudent(userData, studentData) {
    const client = await pool.connect();
    try {
        await client.query("BEGIN");

        // CREATE USER  
        const userInsert = `
            INSERT INTO users (email, password_hash, role)
            VALUES ($1, $2, $3)
            RETURNING user_id, email, role, created_at 
        `;
 
        const userRes = await client.query(userInsert, [
            userData.email.toLowerCase(),
            userData.password_hash,
            userData.role
        ]);

        const user = userRes.rows[0];
        await client.query("COMMIT");
        
        // CREATE STUDENT (using returned user_id)
        const studentInsert = `
        INSERT INTO students (user_id, roll_no, sname, semester, programme, batch, photo_url)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING *
        `;
        
        const studentRes = await client.query(studentInsert, [
            user.user_id,
            studentData.roll_no.toUpperCase(),
            studentData.sname.toUpperCase(),
            studentData.semester,
            studentData.programme.toUpperCase(),
            studentData.batch,
            studentData.photo_url
        ]);
        
        const student = studentRes.rows[0];
        await client.query("COMMIT");
        // Generate token
        // const token = generateEmailToken();
        // const expires_at = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes

        // // Save token to DB
        // await EmailVerificationModel.storeToken(user.user_id, token, expires_at);

         // generate OTP & expiry (10 minutes)
    const otp = generateOTP();
    const expires_at = new Date(Date.now() + 10 * 60 * 1000);

    // store OTP for this user
    await EmailVerificationModel.storeOtp(user.user_id, otp, expires_at);

        // Send email
        await sendOtpEmail(user.email, otp);

        // COMMIT BOTH
        await client.query("COMMIT");

        return {
            user,
            student
        };
 
    } catch (error) {
        await client.query("ROLLBACK");
        throw error;
    } finally {
        client.release();
    }
}
