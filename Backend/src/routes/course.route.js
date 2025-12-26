import express from "express";
import { CourseController } from "../controllers/course.controller.js";
import { auth, requireRole } from "../middlewares/auth.middleware.js";

const router = express.Router();

// ADMIN ONLY
const adminOnly = [auth, requireRole("admin","teacher","student")];

router.get("/", adminOnly, CourseController.getAll);
router.get("/:id", adminOnly, CourseController.getOne);
router.post("/create", adminOnly, CourseController.create);
router.put("/:id", adminOnly, CourseController.update);
router.delete("/:id", adminOnly, CourseController.delete);
router.get("/code/:code", adminOnly, CourseController.getCoursesByCode);

export default router;
