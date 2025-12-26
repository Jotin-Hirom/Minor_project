// middleware/student.middleware.js

import { auth ,requireRole } from "./auth.middleware.js";
import { StudentModel } from "../models/student.model.js";

// Ensure user exists and is a student
export async function studentExists(req, res, next) { 
    try {
        const { id } = req.params; // user_id

        const student = await StudentModel.getStudentById(id);

        if (!student) {
            return res.status(404).json({ error: "Student not found" });
        }

        req.student = student;
        next();
    } catch (err) {
        console.error("studentExists error:", err);
        res.status(500).json({ error: "Server error" });
    }
}

// Only admin can modify student records
export const adminTeacherOnly = [auth, requireRole("admin", "teacher")];
