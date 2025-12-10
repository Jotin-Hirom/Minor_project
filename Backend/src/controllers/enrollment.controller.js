import { EnrollmentModel } from "../models/enrollment.model.js";

export class EnrollmentController {

    // ➤ ENROLL (POST)
    static async enroll(req, res) {
        try {
            const { student_id, course_id } = req.body;

            if (!student_id || !course_id) {
                return res.status(400).json({
                    error: "Missing required fields (student_id, course_id)"
                });
            }

            const result = await EnrollmentModel.enrollStudent({
                student_id,
                course_id,
            });

            if (!result) {
                return res.status(409).json({
                    error: "Student already enrolled in this course"
                });
            }

            return res.status(201).json({
                success: true,
                enrollment: result
            });

        } catch (err) {
            console.error("Error enrolling student:", err);
            res.status(500).json({ error: "Server error" });
        }
    }

    // ➤ GET ALL ENROLLMENTS IN A COURSE
    static async getByCourse(req, res) {
        try {
            const { course_id } = req.params;

            const data = await EnrollmentModel.getEnrollmentsByCourse(course_id);
            res.json(data);

        } catch (err) {
            console.error("Error fetching enrollments by course:", err);
            res.status(500).json({ error: "Server error" });
        }
    }

    // ➤ GET ALL COURSES FOR A STUDENT
    static async getByStudent(req, res) {
        try {
            const { student_id } = req.params;

            const data = await EnrollmentModel.getEnrollmentsByStudent(student_id);
            res.json(data);

        } catch (err) {
            console.error("Error fetching enrollments by student:", err);
            res.status(500).json({ error: "Server error" });
        }
    }

    // ➤ UNENROLL
    static async unenroll(req, res) {
        try {
            const { student_id, course_id } = req.body;

            const result = await EnrollmentModel.unenrollStudent(student_id, course_id);

            if (!result) {
                return res.status(404).json({
                    error: "Enrollment not found"
                });
            }

            return res.json({
                success: true,
                message: "Student unenrolled successfully"
            });

        } catch (err) {
            console.error("Error unenrolling student:", err);
            res.status(500).json({ error: "Server error" });
        }
    }
}
