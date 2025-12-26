import express from "express";
import { AttendanceController } from "../controllers/attendance.controller.js";
import { auth } from "../middlewares/auth.middleware.js";

const router = express.Router();

// MARK (or update) ATTENDANCE
router.post("/mark", AttendanceController.mark);

router.post("/init/:course_id", AttendanceController.initializeAttendance);

// GET ATTENDANCE FOR A STUDENT IN A COURSE
router.get("/student/:student_id/course/:course_id", AttendanceController.getForStudent);

// GET FULL COURSE ATTENDANCE
router.get("/course/:course_id", AttendanceController.getForCourse); 

// DELETE ATTENDANCE RECORD
router.delete("/:attendance_id", AttendanceController.delete);

// ATTENDANCE SUMMARY for a student in a course
router.get(
    "/summary/student/:student_id/course/:course_id",
    AttendanceController.summary
);


export default router;
