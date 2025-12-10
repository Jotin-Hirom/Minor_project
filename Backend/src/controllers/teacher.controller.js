import { TeacherModel } from "../models/teacher.model.js";
import { UserModel } from "../models/user.model.js";

export class TeacherController {

  // ADMIN → GET ALL TEACHERS
  static async getAll(req, res) {
    try {
      const teachers = await TeacherModel.getAllTeachers();
      res.json(teachers);
    } catch (err) {
      console.error("Error fetching teachers:", err);
      res.status(500).json({ error: "Server error" });
    }
  }

  // ADMIN → GET ONE TEACHER
  static async getOne(req, res) {
    try {
      res.json(req.teacher); 
    } catch (err) {
      res.status(500).json({ error: "Server error" });
    }
  }

  // ADMIN → CREATE TEACHER
  static async create(req, res) {
    try {
      const {
        user_id,
        abbr,
        tname,
        designation,
        specialization,
        dept,
        photo_url
      } = req.body;

      if (!user_id || !abbr || !tname) {
        return res.status(400).json({ error: "Missing required fields" });
      }

      const teacher = await TeacherModel.createTeacher({
        user_id,
        abbr,
        tname,
        designation,
        specialization,
        dept,
        photo_url
      });

      res.status(201).json(teacher);
    } catch (err) {
      console.error("Error creating teacher:", err);
      res.status(500).json({ error: "Server error" });
    }
  }

  // ADMIN → UPDATE TEACHER
  static async update(req, res) {
    try {
      const { id } = req.params;
      const updates = req.body;

      const updated = await TeacherModel.updateTeacher(id, updates);

      res.json(updated);
    } catch (err) {
      console.error("Error updating teacher:", err);
      res.status(500).json({ error: "Server error" });
    }
  }

  // ADMIN → DELETE TEACHER
  static async delete(req, res) {
    try {
      const { id } = req.params;

      await TeacherModel.deleteTeacher(id);
      await UserModel.deleteUser(id); // delete from users table too

      res.json({ success: true, message: "Teacher deleted" });
    } catch (err) {
      console.error("Error deleting teacher:", err);
      res.status(500).json({ error: "Server error" });
    }
  }
}




// import { TeacherModel } from "../models/teacher.model.js";

// /**
//  * Get all teachers
//  */
// export const getAllTeachers = async (req, res, next) => {
//   try {
//     const { rows } = await TeacherModel.getAllTeachers();
//     res.json({ teachers: rows });
//   } catch (err) {
//     next(err);
//   }
// };

// /**
//  * Get teacher by user_id
//  */
// export const getTeacherById = async (req, res, next) => {
//   try {
//     const { user_id } = req.params;
//     const teacher = await TeacherModel.getTeacherById(user_id);
//     if (!teacher) {
//       return res.status(404).json({ error: "Teacher not found" });
//     }
//     res.json({ teacher });
//   } catch (err) {
//     next(err);
//   }
// };

// /**
//  * Get teacher by abbr
//  */
// export const getTeacherByAbbr = async (req, res, next) => {
//   try {
//     const { abbr } = req.params;
//     const teacher = await TeacherModel.getTeacherByAbbr(abbr);
//     if (!teacher) {
//       return res.status(404).json({ error: "Teacher not found" });
//     }
//     res.json({ teacher });
//   } catch (err) {
//     next(err);
//   }
// };

// /**
//  * Create a new teacher
//  */
// export const createTeacher = async (req, res, next) => {
//   try {
//     const teacherData = req.body;
//     const newTeacher = await TeacherModel.createTeacher(teacherData);
//     res.status(201).json({ teacher: newTeacher });
//   } catch (err) {
//     next(err);
//   }
// };

// /**
//  * Update teacher by user_id
//  */
// export const updateTeacher = async (req, res, next) => {
//   try {
//     const { user_id } = req.params;
//     const updates = req.body;
//     const updatedTeacher = await TeacherModel.updateTeacher(user_id, updates);
//     res.json({ teacher: updatedTeacher });
//   } catch (err) {
//     next(err);
//   }
// };

// /**
//  * Delete teacher by user_id
//  */
// export const deleteTeacher = async (req, res, next) => {
//   try {
//     const { user_id } = req.params;
//     await TeacherModel.deleteTeacher(user_id);
//     res.json({ message: "Teacher deleted successfully" });
//   } catch (err) {
//     next(err);
//   }
// };

// /**
//  * Get teachers by programme
//  */
// export const getTeachersByProgramme = async (req, res, next) => {
//   try {
//     const { programme } = req.params;
//     const { rows } = await TeacherModel.getTeachersByProgramme(programme);
//     res.json({ teachers: rows });
//   } catch (err) {
//     next(err);
//   }
// };

// /**
//  * Get teachers by dept
//  */
// export const getTeachersByDept = async (req, res, next) => {
//   try {
//     const { dept } = req.params;
//     const { rows } = await TeacherModel.getTeachersByDept(dept);
//     res.json({ teachers: rows });
//   } catch (err) {
//     next(err);
//   }
// };
