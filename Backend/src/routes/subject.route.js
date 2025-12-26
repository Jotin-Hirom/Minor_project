import express from "express";
import { SubjectController } from "../controllers/subject.controller.js";
import {  auth,requireRole } from "../middlewares/auth.middleware.js";

const router = express.Router();
const adminTeacherOnly = [auth, requireRole("admin","teacher")];

router.get("/", adminTeacherOnly, SubjectController.getAll);

//get teacher subjects by teacher id
router.get("/:id/subjects", SubjectController.getByTeacherId);
router.get("/:code", adminTeacherOnly, SubjectController.getOne);
router.post("/create", adminTeacherOnly, SubjectController.create);
router.put("/:code", adminTeacherOnly, SubjectController.update);
router.delete("/:code", adminTeacherOnly, SubjectController.delete);

export default router;
