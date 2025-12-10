import express from "express";
import { TeacherController } from "../controllers/teacher.controller.js";
import { adminOnlyTeacher, teacherExists } from "../middlewares/teacher.middleware.js";

const router = express.Router();

// ADMIN — GET all teachers
router.get("/", adminOnlyTeacher, TeacherController.getAll);

// ADMIN — GET one teacher
router.get("/:id", adminOnlyTeacher, teacherExists, TeacherController.getOne);

// ADMIN — CREATE teacher
router.post("/", adminOnlyTeacher, TeacherController.create);

// ADMIN — UPDATE teacher
router.put("/:id", adminOnlyTeacher, teacherExists, TeacherController.update);

// ADMIN — DELETE teacher
router.delete("/:id", adminOnlyTeacher, teacherExists, TeacherController.delete);

export default router; 
