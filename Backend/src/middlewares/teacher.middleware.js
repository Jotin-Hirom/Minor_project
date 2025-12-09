import { TeacherModel } from "../models/teacher.model.js";
import { requireRole, auth } from "./auth.middleware.js";

// Ensure teacher exists
export async function teacherExists(req, res, next) {
    try {
        const { id } = req.params;
        const teacher = await TeacherModel.getTeacherById(id);

        if (!teacher) {
            return res.status(404).json({ error: "Teacher not found" });
        }

        req.teacher = teacher;
        next();
    } catch (err) {
        console.error("teacherExists error:", err);
        res.status(500).json({ error: "Server error" });
    }
}

// Only admin can manage teachers
export const adminOnlyTeacher = [auth, requireRole("admin")];
