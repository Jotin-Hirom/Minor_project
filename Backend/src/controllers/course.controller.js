import { CourseModel } from "../models/course.model.js"; 

export class CourseController {

    // ➤ GET ALL COURSES
    static async getAll(req, res) {
        try {
            const courses = await CourseModel.getAllCourses();
            res.json(courses);
        } catch (err) {
            console.error("Error fetching courses:", err);
            return res.status(500).json({ error: "Server error" });
        }
    }

    // ➤ GET ONE COURSE
    static async getOne(req, res) {
        try {
            const { id } = req.params;
            const course = await CourseModel.getCourseById(id);

            if (!course) {
                return res.status(404).json({ error: "Course not found" });
            }

            res.json(course);

        } catch (err) {
            console.error("Error fetching course:", err);
            return res.status(500).json({ error: "Server error" });
        }
    }

    // ➤ CREATE COURSE
    static async create(req, res) {
        try {
            const { code, teacher_id } = req.body;

            // Validate required fields
            if (!code || !teacher_id) {
                return res.status(400).json({
                    error: "Missing required fields (code, teacher_id)"
                });
            }

            const course = await CourseModel.createCourse({
                code,
                teacher_id
            });

            res.status(201).json(course);

        } catch (err) {
            console.error("Error creating course:", err);
            res.status(500).json({ error: "Server error" });
        }
    }

    // ➤ UPDATE COURSE
    static async update(req, res) {
        try {
            const { id } = req.params;
            const updates = req.body;

            const updated = await CourseModel.updateCourse(id, updates);

            res.json(updated);

        } catch (err) {
            console.error("Error updating course:", err);
            res.status(500).json({ error: "Server error" });
        }
    }

    // ➤ DELETE COURSE
    static async delete(req, res) {
        try {
            const { id } = req.params;

            await CourseModel.deleteCourse(id);

            res.json({ success: true, message: "Course deleted" });

        } catch (err) {
            console.error("Error deleting course:", err);
            res.status(500).json({ error: "Server error" });
        }
    }
}
