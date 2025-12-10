import { SubjectModel } from "../models/subject.model.js";

export class SubjectController {

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




// import { SubjectModel } from "../models/subject.model.js";

// export class SubjectController {

//     // ➤ GET ALL SUBJECTS
//     static async getAll(req, res) {
//         try {
//             const subjects = await SubjectModel.getAllSubjects();
//             res.json(subjects);
//         } catch (err) {
//             console.error("Error fetching subjects:", err);
//             res.status(500).json({ error: "Server error" });
//         }
//     }

//     // ➤ GET ONE SUBJECT
//     static async getOne(req, res) {
//         try {
//             const { code } = req.params;
//             const subject = await SubjectModel.getSubject(code);

//             if (!subject) {
//                 return res.status(404).json({ error: "Subject not found" });
//             }

//             res.json(subject);
//         } catch (err) {
//             console.error("Error fetching subject:", err);
//             res.status(500).json({ error: "Server error" });
//         }
//     }

//     // ➤ CREATE SUBJECT
//     static async create(req, res) {
//         try {
//             const { sub_code, sub_name } = req.body;

//             if (!sub_code || !sub_name) {
//                 return res.status(400).json({ error: "Subject code and name required" });
//             }

//             const subject = await SubjectModel.createSubject({ sub_code, sub_name });
//             res.status(201).json(subject);

//         } catch (err) {
//             console.error("Error creating subject:", err);
//             res.status(500).json({ error: "Server error" });
//         }
//     }

//     // ➤ UPDATE SUBJECT
//     static async update(req, res) {
//         try {
//             const { code } = req.params;
//             const updates = req.body;

//             const updated = await SubjectModel.updateSubject(code, updates);
//             res.json(updated);

//         } catch (err) {
//             console.error("Error updating subject:", err);
//             res.status(500).json({ error: "Server error" });
//         }
//     }

//     // ➤ DELETE SUBJECT
//     static async delete(req, res) {
//         try {
//             const { code } = req.params;

//             await SubjectModel.deleteSubject(code);

//             res.json({ success: true, message: "Subject deleted" });

//         } catch (err) {
//             console.error("Error deleting subject:", err);
//             res.status(500).json({ error: "Server error" });
//         }
//     }
// }
