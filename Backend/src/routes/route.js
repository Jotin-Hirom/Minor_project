import express from "express";

import authRoutes from "./auth.route.js";
import studentRoutes from "./student.route.js";
import teacherRoutes from "./teacher.route.js";
import adminRoutes from "./admin.route.js";
import subjectRoutes from "./subject.route.js";
import courseRoutes from "./course.route.js";
import enrollmentRoutes from "./enrollment.route.js";
import attendanceRoutes from "./attendance.route.js";

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
  auth,
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
// SUBJECT ROUTES (admin, teacher, student)
// ------------------------------------------
router.use(
  "/subject",
  auth,
  requireRole("admin", "teacher", "student"),
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
// ENROLLMENT ROUTES (teacher + admin)
// Teachers enroll students into their course,
// Admins can also manage enrollment.
// ------------------------------------------
router.use(
  "/enrollment",
  auth,
  requireRole("teacher", "admin"),
  enrollmentRoutes
);


// ------------------------------------------
// ATTENDANCE ROUTES 
// - Teacher marks attendance
// - Student can view their attendance summary
// ------------------------------------------

// Teacher: mark + view course-level attendance
router.use(
  "/attendance",
  auth,
  requireRole("teacher", "student", "admin"),
  attendanceRoutes
);


// ------------------------------------------
// GENERAL AUTHENTICATED ROUTE (who am I?)
// ------------------------------------------
router.get("/me", auth, (req, res) => {
  res.json({ user: req.user });
});

export default router;
