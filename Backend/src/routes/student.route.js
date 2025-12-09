import { Router } from "express";
import { getSubjects, getStudentAttendance } from "../controllers/studentController.js";
import { auth } from "../middlewares/auth.middleware.js";
import { StudentController } from "../controllers/student.controller.js";
import { adminOnly, studentExists } from "../middlewares/student.middleware.js";

const router = Router();

// ADMIN — GET all students
router.get("/", adminOnly, StudentController.getAll);


// ADMIN — GET one student
router.get("/:id", adminOnly, studentExists, StudentController.getOne);

// ADMIN — CREATE student (user must be already created in users table)
router.post("/", adminOnly, StudentController.create);

// ADMIN — UPDATE student
router.put("/:id", adminOnly, studentExists, StudentController.update);

// ADMIN — DELETE student
router.delete("/:id", adminOnly, studentExists, StudentController.delete);

export default router;


