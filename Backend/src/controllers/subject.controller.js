import { SubjectModel } from "../models/subject.model.js";

export class SubjectController {
    static async getByTeacherId(req, res) {
        try {
            const { id } = req.params;
            const subjects = await SubjectModel.getSubjectsByTeacherId(id);
            res.json(subjects);
        } catch (err) {
            console.error("Error:", err);
            res.status(500).json({ error: "Server error" });
        }
    }

    static async getAll(req, res) {
        try {
            const subjects = await SubjectModel.getAllSubjects();
            res.json(subjects);
        } catch (err) {
            console.error("Error:", err);
            res.status(500).json({ error: "Server error" }); 
        }
    }

    static async getOne(req, res) {
        try {
            const subject = await SubjectModel.getSubject(req.params.code);
            if (!subject) return res.status(404).json({ error: "Subject not found" });
            res.json(subject);
        } catch (err) {
            res.status(500).json({ error: "Server error" });
        }
    }

    static async create(req, res) {
        try {
            const { code, course_name, teacher_id } = req.body;

            if (!code || !course_name)
                return res.status(400).json({ error: "Missing required fields" });

            const subject = await SubjectModel.createSubject({
                code,
                course_name,
                teacher_id,
            });

            res.status(201).json(subject);
        } catch (err) {
            res.status(500).json({ error: "Server error" });
        }
    }

    static async update(req, res) {
        try {
            const updated = await SubjectModel.updateSubject(
                req.params.code,
                req.body
            );
            res.json(updated);
        } catch (err) {
            res.status(500).json({ error: "Server error" });
        }
    }

    static async delete(req, res) {
        try {
            await SubjectModel.deleteSubject(req.params.code);
            res.json({ success: true });
        } catch (err) {
            res.status(500).json({ error: "Server error" });
        }
    }
}