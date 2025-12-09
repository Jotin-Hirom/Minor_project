// controllers/student.controller.js

import { StudentModel } from "../models/student.model.js";
import { UserModel } from "../models/user.model.js";

export class StudentController {

  // ADMIN → GET ALL STUDENTS
  static async getAll(req, res) {
    try {
      const students = await StudentModel.getAllStudents();
      res.json(students);
    } catch (err) {
      console.error("Error fetching students:", err);
      res.status(500).json({ error: "Server error" });
    }
  }

  // ADMIN → GET ONE STUDENT
  static async getOne(req, res) {
    try {
      const student = req.student; // from middleware
      res.json(student);
    } catch (err) {
      console.error("Error fetching student:", err);
      res.status(500).json({ error: "Server error" });
    }
  }

  // ADMIN → CREATE STUDENT
  static async create(req, res) {
    try {
      const {
        user_id,
        roll_no,
        sname,
        semester,
        programme,
        batch,
        photo_url,
      } = req.body;

      if (!user_id || !roll_no || !sname) {
        return res.status(400).json({ error: "Missing required fields" });
      }

      const newStudent = await StudentModel.createStudent({
        user_id,
        roll_no,
        sname,
        semester,
        programme,
        batch,
        photo_url,
      });

      res.status(201).json(newStudent);
    } catch (err) {
      console.error("Error creating student:", err);
      res.status(500).json({ error: "Server error" });
    }
  }

  // ADMIN → UPDATE STUDENT
  static async update(req, res) {
    try {
      const { id } = req.params;
      const updates = req.body;

      const updated = await StudentModel.updateStudent(id, updates);

      res.json(updated);
    } catch (err) {
      console.error("Error updating student:", err);
      res.status(500).json({ error: "Server error" });
    }
  }

  // ADMIN → DELETE STUDENT
  static async delete(req, res) {
    try {
      const { id } = req.params;

      await StudentModel.deleteStudent(id);
      await UserModel.deleteUser(id); // remove from users table

      res.json({ success: true, message: "Student deleted" });
    } catch (err) {
      console.error("Error deleting student:", err);
      res.status(500).json({ error: "Server error" });
    }
  }
}




// import pool from "../config/pool.js";

// export class StudentModel {

//   //  CREATE STUDENT WITH TRANSACTION
//   static async createStudent({
//     user_id,
//     roll_no,
//     sname,
//     semester,
//     programme,
//     batch,
//     photo_url
//   }) {
//     const client = await pool.connect();
//     try {
//       await client.query("BEGIN");

//       const q = `
//         INSERT INTO students 
//         (user_id, roll_no, sname, semester, programme, batch, photo_url)
//         VALUES ($1, $2, $3, $4, $5, $6, $7)
//         RETURNING *;
//       `;

//       const params = [
//         user_id,
//         roll_no,
//         sname,
//         semester,
//         programme,
//         batch,
//         photo_url
//       ];

//       const { rows } = await client.query(q, params);

//       await client.query("COMMIT");
//       return rows[0];

//     } catch (err) {
//       await client.query("ROLLBACK");
//       throw err;
//     } finally {
//       client.release();
//     }
//   }

//   //  GET ALL STUDENTS
//   static async getAllStudents() {
//     const q = `
//       SELECT 
//         u.user_id, u.email, u.role, u.created_at,
//         s.roll_no, s.sname, s.semester, s.programme, 
//         s.batch, s.photo_url, s.isBlocked
//       FROM users u
//       JOIN students s ON u.user_id = s.user_id
//       WHERE u.role = 'student';
//     `;
//     const { rows } = await pool.query(q);
//     return rows;
//   }

//   //  GET STUDENT BY ID
//   static async getStudentById(user_id) {
//     const q = `
//       SELECT 
//         u.user_id, u.email, u.role, u.created_at,
//         s.roll_no, s.sname, s.semester, s.programme, 
//         s.batch, s.photo_url, s.isBlocked
//       FROM users u
//       JOIN students s ON u.user_id = s.user_id
//       WHERE u.user_id = $1
//       LIMIT 1;
//     `;
//     const { rows } = await pool.query(q, [user_id]);
//     return rows[0];
//   }

//   //  UPDATE STUDENT WITH TRANSACTION
//   static async updateStudent(user_id, updates) {
//     const client = await pool.connect();

//     try {
//       await client.query("BEGIN");

//       const fields = [];
//       const values = [];
//       let i = 1;

//       for (const [key, val] of Object.entries(updates)) {
//         fields.push(`${key} = $${i}`);
//         values.push(val);
//         i++;
//       }

//       const q = `
//         UPDATE students
//         SET ${fields.join(", ")}, updated_at = NOW()
//         WHERE user_id = $${i}
//         RETURNING *;
//       `;
//       values.push(user_id);

//       const { rows } = await client.query(q, values);

//       await client.query("COMMIT");
//       return rows[0];

//     } catch (err) {
//       await client.query("ROLLBACK");
//       throw err;

//     } finally {
//       client.release();
//     }
//   }

//   //  DELETE STUDENT
//   static async deleteStudent(user_id) {
//     const client = await pool.connect();
//     try {
//       await client.query("BEGIN");

//       await client.query(
//         "DELETE FROM students WHERE user_id = $1",
//         [user_id]
//       );

//       await client.query("COMMIT");
//       return true;

//     } catch (err) {
//       await client.query("ROLLBACK");
//       throw err;

//     } finally {
//       client.release();
//     }
//   }
// }
