import express from "express";

import authRoutes from "./auth.route.js";
import studentRoutes from "./student.route.js";
import teacherRoutes from "./teacher.route.js";
import adminRoutes from "./admin.route.js";
import subjectRoutes from "./subject.route.js";
import courseRoutes from "./course.route.js";

import { auth, requireRole } from "../middlewares/auth.middleware.js";

const router = express.Router();

// ------------------------------------------
// PUBLIC ROUTES
// ------------------------------------------
router.use("/auth", authRoutes); // login, signup, refresh, logout


// ------------------------------------------
// STUDENT ROUTES (Student-only protected)
// ------------------------------------------
router.use(
  "/student",
  auth,                 // Must be logged in
  requireRole("student"),
  studentRoutes
);


// ------------------------------------------
// TEACHER ROUTES (Teacher-only protected)
// ------------------------------------------
router.use(
  "/teacher",
  auth,
  requireRole("teacher"),
  teacherRoutes
);


// ------------------------------------------
// ADMIN ROUTES (Admin-only protected)
// ------------------------------------------
router.use(
  "/admin",
  auth,
  requireRole("admin"),
  adminRoutes
);


// ------------------------------------------
// SUBJECT ROUTES (Admin-only protected)
// ------------------------------------------
router.use(
  "/subject",
  auth,
  requireRole("admin"),
  subjectRoutes
);



// ------------------------------------------
// COURSE ROUTES (Admin-only protected)
// ------------------------------------------
router.use(
  "/course",
  auth,
  requireRole("admin"),
  courseRoutes
);



// ------------------------------------------
// GENERAL AUTHENTICATED ROUTE
// ------------------------------------------
router.get("/me", auth, (req, res) => {
  res.json({ user: req.user });
});

export default router;


// import express from "express";
// import authRoutes from "./auth.routes.js";
// import studentRoutes from "./student.routes.js";
// import adminRoutes from "./admin.routes.js";
// import { auth } from "../middlewares/auth.middleware.js";
// // import teacherRoutes from "./teacher.routes.js";
// // import attendanceRoutes from "./attendance.routes.js";
// // import userRoutes from "./user.routes.js";
// // import { verifyToken } from "../middlewares/auth.middleware.js";

// const router = express.Router();

// // All API base routes
// router.use("/auth", authRoutes);
// router.use("/student", auth, studentRoutes); 
// router.use("/admin", auth, adminRoutes); 
// router.get(
//   "/student",
//   auth,
//   requireRole("student"),
//   studentRoutes
// );
// // router.get(
// //     "/api/reports",
// //     requireAuth,
// //     requireRole("admin", "teacher"),
// //     reportsController
// // );
// // router.use("/teacher",auth, teacherRoutes);

// // Me endpoint -> get current user info
// router.get("/me", auth, (req, res) => {
//   res.json({ user: req.user });
// });

// export default router;