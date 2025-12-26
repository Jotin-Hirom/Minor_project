import express from "express";
import { EnrollmentController } from "../controllers/enrollment.controller.js";

const router = express.Router();
 
// ➤ ENROLL A STUDENT
router.post("/enroll", EnrollmentController.enroll);

// ➤ GET ALL STUDENTS ENROLLED IN A COURSE
router.get("/course/:course_id", EnrollmentController.getByCourse);

// ➤ GET ALL COURSES A STUDENT IS ENROLLED IN
router.get("/student/:student_id", EnrollmentController.getByStudent);

// ➤ UNENROLL STUDENT
router.delete("/unenroll", EnrollmentController.unenroll);

router.post("/bulk-enroll", EnrollmentController.bulkEnroll);


export default router;
