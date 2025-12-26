import { Router } from "express";
import { auth } from "../middlewares/auth.middleware.js";
import { StudentController } from "../controllers/student.controller.js";
import { adminTeacherOnly, studentExists } from "../middlewares/student.middleware.js";

const router = Router();

// ADMIN — GET all students
router.get("/", StudentController.getAll);

//Get student by semsester and programme
router.get("/filter", StudentController.getBySemesterAndProgramme);

// ADMIN — GET one student
router.get("/:id", adminTeacherOnly, studentExists, StudentController.getOne);

// ADMIN — CREATE student (user must be already created in users table)
router.post("/", adminTeacherOnly, StudentController.create);

// ADMIN — UPDATE student
router.put("/:id", adminTeacherOnly, studentExists, StudentController.update);

// ADMIN — DELETE student
router.delete("/:id", adminTeacherOnly, studentExists, StudentController.delete);

export default router;


