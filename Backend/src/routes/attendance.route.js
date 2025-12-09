import { Router } from "express";
import { postMarkAttendance } from "../controllers/attendanceController.js";
import { auth } from "../middleware/auth.js";

const router = Router();

router.post("/attendance/mark", auth, postMarkAttendance);

export default router;

