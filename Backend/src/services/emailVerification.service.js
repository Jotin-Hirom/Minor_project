import dotenv from "dotenv";
import { Resend } from "resend";
dotenv.config();

const resend = new Resend(process.env.RESEND_API_KEY_CSM24042);

export async function sendOtpEmail(text, email, otp) {
  const htmlContent = `
  <div style="
    max-width: 480px;
    margin: auto;
    padding: 20px;
    font-family: Arial, sans-serif;
    background: #ffffff;
    border-radius: 12px;
    border: 1px solid #e5e7eb;
    box-shadow: 0 4px 10px rgba(0,0,0,0.06);
  ">
    <h2 style="color: #374151; text-align: center;">"${text !=="reset"?"Verify Your Email":"Reset Your Password"}"</h2>
    <p style="font-size: 15px; color: #4b5563; text-align: center;">
      Use the OTP below to "${text !=="reset"?"verify your email address.":"reset your password."}" 
    </p>

    <div style="
      margin: 24px auto;
      padding: 16px 24px;
      max-width: 200px;
      text-align: center;
      border-radius: 8px;
      border: 1px dashed #2563eb;
      background: #eff6ff;
      ">
      <span style="font-size: 24px; letter-spacing: 6px; color: #1d4ed8; font-weight: bold;">
        ${otp}
      </span>
    </div>

    <p style="font-size: 14px; color: #6b7280; text-align: center;">
      This OTP will expire in <strong>10 minutes</strong>.
    </p>

    <hr style="margin: 25px 0; border: none; border-top: 1px solid #e5e7eb">

    <p style="font-size: 12px; color: #9ca3af; text-align: center;">
      If you didn’t create this account, you can safely ignore this email.
    </p>
  </div>
  `;

const emailSubject = text !== "reset"? "Verify your email for ClassQR":"Reset your password for ClassQR.";
const sendEmail = email !== "csm24042@tezu.ac.in" ? "csm24042@tezu.ac.in" : email; //send only to the csm24042@tezu.ac.in
  return await resend.emails.send({
    from: "ClassQR <onboarding@resend.dev>", // or your verified sender
    to: sendEmail,
    subject: emailSubject,
    html: htmlContent,
  });
}




// import { Resend } from "resend";
// const resend = new Resend(process.env.RESEND_API_KEY_CSM24042);
// export async function sendVerificationEmail(email, token) {
//   const link = `${process.env.FRONTEND_URL}/verify-email?token=${token}`;
//   const htmlContent = `
//   <div style="
//     max-width: 480px;
//     margin: auto;
//     padding: 20px;
//     font-family: Arial, sans-serif;
//     background: #ffffff;
//     border-radius: 12px;
//     border: 1px solid #e5e7eb;
//     box-shadow: 0 4px 10px rgba(0,0,0,0.06);
//   ">
//     <h2 style="color: #374151; text-align: center;">Verify Your Email</h2>
//     <p style="font-size: 15px; color: #4b5563; text-align: center;">
//       Click the button below to verify your email address.
//     </p>
//     <div style="text-align: center; margin: 30px 0;">
//       <a href="${link}"
//         style="
//           display: inline-block;
//           background-color: #2563eb;
//           color: white;
//           padding: 12px 24px;
//           text-decoration: none;
//           border-radius: 6px;
//           font-weight: bold;
//           font-size: 16px;
//         ">
//         Verify Email
//       </a>
//     </div>
//     <p style="font-size: 14px; color: #6b7280; text-align: center;">
//       This link will expire in 30 minutes.
//     </p>
//     <hr style="margin: 25px 0; border: none; border-top: 1px solid #e5e7eb">
//     <p style="font-size: 12px; color: #9ca3af; text-align: center;">
//       If you didn't create this account, ignore this email.
//     </p>
//   </div>
//   `;
// const emailSubject = "Verify your email for ClassQR";
// const sendEmail = email !== "csm24042@tezu.ac.in" ? "csm24042@tezu.ac.in" : email;
//    const { data, error } =  await resend.emails.send({
//     from: "ClassQR <onboarding@resend.dev>",
//     to: sendEmail,
//     subject: emailSubject,
//     html: htmlContent,
//   });
//    if (error) {
//     return console.error({ error });
//   }
//  return data;
// }





// import { mailTransport } from "../config/mailer.js";

// export async function sendVerificationEmail(email, token) {
//     const link = `${process.env.FRONTEND_URL}/verify-email?token=${token}`; 
//     // Example: https://classqr.com/verify-email?token=1234

//     const message = `
// <div style="
//   max-width: 480px;
//   margin: auto;
//   padding: 20px;
//   font-family: 'Arial', sans-serif;
//   background: #ffffff;
//   border-radius: 12px;
//   border: 1px solid #e5e7eb;
//   box-shadow: 0 4px 10px rgba(0,0,0,0.06);
// ">

//   <h2 style="color: #374151; text-align: center;">
//     Verify Your Email
//   </h2>

//   <p style="font-size: 15px; color: #4b5563; text-align: center; margin-top: 10px;">
//     Thank you for signing up! Please click the button below to verify your email address.
//   </p>

//   <div style="text-align: center; margin: 30px 0;">
//     <a href="${link}"
//       style="
//         display: inline-block;
//         background-color: #2563eb;
//         color: white;
//         padding: 12px 24px;
//         text-decoration: none;
//         border-radius: 6px;
//         font-weight: bold;
//         font-size: 16px;
//       ">
//       Verify Email
//     </a>
//   </div>

//   <p style="font-size: 14px; color: #6b7280; text-align: center;">
//     This link will expire in <strong>30 minutes</strong>.
//   </p>

//   <hr style="margin: 25px 0; border: none; border-top: 1px solid #e5e7eb">

//   <p style="font-size: 12px; color: #9ca3af; text-align: center;">
//     If you didn’t create this account, you can safely ignore this email.
//   </p>

// </div>
//     `;

//     const mailOption = {
//             from: `"ClassQR" <${process.env.EMAIL_USER}>`,
//             to: email,
//             subject: "Verify your email",
//             html: message
//         };
//     try {
//       return mailTransport.sendMail(mailOption,(error, info) => {
//                 if (error) {
//                     return console.log(error);
//                 } else{
//                     console.log('Email has been sent');
//                     res.send(info);
//                 }
//             });
//     } catch (e) {
//         return { ok: false, error: "Email delivery failed", code: e.code, reason: e.response };
//     }
    
// }



// // const mailOption = {
// //             from: `yourmail@gmail.com`,
// //             to: 'receiver's mail',
// //             subject: "Subject of mail",
// //             html: "<h1>Hello there</h1>"
// //         };
// //         transporter.sendMail(mailOption, (error, info) => {
// //                 if (error) {
// //                     return console.log(error);
// //                 } else{
// //                     console.log('Email has been sent');
// //                     res.send(info);
// //                 }
// //             });
// //     });
