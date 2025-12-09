// import { createTransport } from "nodemailer";
// import { MailtrapTransport } from "mailtrap"; 
// const transport = createTransport(
//   MailtrapTransport({
//     token: TOKEN,
//   })
// );

// const sender = {
//   address: "hello@demomailtrap.co",
//   name: "Mailtrap Test",
// };
// const recipients = [
//   "jotin24613@gmail.com",
// ];

// transport
//   .sendMail({
//     from: sender,
//     to: recipients,
//     subject: "You are awesome!",
//     text: "Congrats for sending test email with Mailtrap!",
//     category: "Integration Test",
//   })
//   .then(console.log, console.error);







// import nodemailer from "nodemailer";
// import dotenv from "dotenv";
// dotenv.config();


// const EMAIL_USER = process.env.EMAIL_USER;
// const EMAIL_APP_PASSWORD = process.env.APP_PASSWORD;


// export const mailTransport = nodemailer.createTransport({
//   // service: "gmail.com",
//   host: 'smtp.gmail.com',
//   pool: true,
//   port: 465,
//   secure: true,
//     auth: {
//         user: EMAIL_USER,
//         pass: EMAIL_APP_PASSWORD
//     }
// });
// console.log(mailTransport)
// mailTransport.sendMail({
//   from: EMAIL_USER,
//   to: "jotin24613@gmail.com",
//   subject: "Test",
//   text: "Email working"
// })
// .then(() => console.log("Sent"))
// .catch(err => console.error(err));

    // const host = "smtp.gmail.com";
    // const port = 587;
    // const secure = false;
    // mailer = nodemailer.createTransport({ host, port, secure, auth: { user: SMTP_USER, pass: SMTP_PASS || EMAIL_PASSWORD }, pool: true, connectionTimeout: 10000, socketTimeout: 10000 });
    // pool: true, connectionTimeout: 10000, socketTimeout: 10000 