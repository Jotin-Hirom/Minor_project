import pool from "../config/pool.js";

export class SubjectModel {

    // CREATE SUBJECT
    static async createSubject({ code, course_name, teacher_id }) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = `
        INSERT INTO subjects (code, course_name, teacher_id)
        VALUES ($1, $2, $3)
        RETURNING *;
      `;

            const values = [code, course_name, teacher_id];

            const { rows } = await client.query(q, values);

            await client.query("COMMIT");
            return rows[0];

        } catch (err) {
            await client.query("ROLLBACK");
            throw err;
        } finally {
            client.release();
        }
    }

    // GET ALL SUBJECTS WITH TEACHERS
    static async getAllSubjects() {
        const q = `
      SELECT 
        s.code, s.course_name, s.teacher_id,
        t.tname, t.dept
      FROM subjects s
      LEFT JOIN teachers t ON t.user_id = s.teacher_id
      ORDER BY s.code;
    `;
        const { rows } = await pool.query(q);
        return rows;
    }

    // GET ONE SUBJECT
    static async getSubject(sub_code) {
        const q = `
      SELECT 
        s.code, s.course_name, s.teacher_id,
        t.tname, t.abbr, t.dept
      FROM subjects s
      LEFT JOIN teachers t ON t.user_id = s.teacher_id
      WHERE s.code = $1 LIMIT 1;
    `;
        const { rows } = await pool.query(q, [code]);
        return rows[0];
    }

    // UPDATE SUBJECT (INCLUDING TEACHER ASSIGNMENT)
    static async updateSubject(code, updates) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const fields = [];
            const values = [];
            let i = 1;

            for (const [key, val] of Object.entries(updates)) {
                fields.push(`${key} = $${i}`);
                values.push(val);
                i++;
            }

            const q = `
        UPDATE subjects
        SET ${fields.join(", ")}
        WHERE code = $${i}
        RETURNING *;
      `;
            values.push(code);

            const { rows } = await client.query(q, values);
            await client.query("COMMIT");
            return rows[0];

        } catch (err) {
            await client.query("ROLLBACK");
            throw err;
        } finally {
            client.release();
        }
    }

    // DELETE SUBJECT
    static async deleteSubject(code) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            await client.query("DELETE FROM subjects WHERE code = $1", [code]);
            await client.query("COMMIT");
            return true;
        } catch (err) {
            await client.query("ROLLBACK");
            throw err;
        } finally {
            client.release();
        }
    }
}






// import pool from "../config/pool.js";

// export class SubjectModel {

//   // CREATE SUBJECT
//   static async createSubject({ sub_code, sub_name, teacher_id }) {
//     const client = await pool.connect();
//     try {
//       await client.query("BEGIN");

//       const q = `
//         INSERT INTO subjects (sub_code, sub_name, teacher_id)
//         VALUES ($1, $2, $3)
//         RETURNING *;
//       `;

//       const values = [sub_code, sub_name, teacher_id];

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

//   // GET ALL SUBJECTS WITH TEACHERS
//   static async getAllSubjects() {
//     const q = `
//       SELECT 
//         s.sub_code, s.sub_name, s.teacher_id,
//         t.tname, t.abbr, t.dept
//       FROM subjects s
//       LEFT JOIN teachers t ON t.user_id = s.teacher_id
//       ORDER BY s.sub_code;
//     `;
//     const { rows } = await pool.query(q);
//     return rows;
//   }

//   // GET ONE SUBJECT
//   static async getSubject(sub_code) {
//     const q = `
//       SELECT 
//         s.sub_code, s.sub_name, s.teacher_id,
//         t.tname, t.abbr, t.dept
//       FROM subjects s
//       LEFT JOIN teachers t ON t.user_id = s.teacher_id
//       WHERE s.sub_code = $1 LIMIT 1;
//     `;
//     const { rows } = await pool.query(q, [sub_code]);
//     return rows[0];
//   }

//   // UPDATE SUBJECT (INCLUDING TEACHER ASSIGNMENT)
//   static async updateSubject(sub_code, updates) {
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
//         UPDATE subjects
//         SET ${fields.join(", ")}
//         WHERE sub_code = $${i}
//         RETURNING *;
//       `;
//       values.push(sub_code);

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

//   // DELETE SUBJECT
//   static async deleteSubject(sub_code) {
//     const client = await pool.connect();
//     try {
//       await client.query("BEGIN");
//       await client.query("DELETE FROM subjects WHERE sub_code = $1", [sub_code]);
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
// import pool from "../config/pool.js";

// export class SubjectModel {

//     // CREATE SUBJECT
//     static async createSubject({ sub_code, sub_name, teacher_id }) {
//         const client = await pool.connect();
//         try {
//             await client.query("BEGIN");

//             const q = `
//         INSERT INTO subjects (sub_code, sub_name, teacher_id)
//         VALUES ($1, $2, $3)
//         RETURNING *;
//       `;

//             const values = [sub_code, sub_name, teacher_id];

//             const { rows } = await client.query(q, values);

//             await client.query("COMMIT");
//             return rows[0];

//         } catch (err) {
//             await client.query("ROLLBACK");
//             throw err;
//         } finally {
//             client.release();
//         }
//     }

//     // GET ALL SUBJECTS WITH TEACHERS
//     static async getAllSubjects() {
//         const q = `
//       SELECT 
//         s.sub_code, s.sub_name, s.teacher_id,
//         t.tname, t.abbr, t.dept
//       FROM subjects s
//       LEFT JOIN teachers t ON t.user_id = s.teacher_id
//       ORDER BY s.sub_code;
//     `;
//         const { rows } = await pool.query(q);
//         return rows;
//     }

//     // GET ONE SUBJECT
//     static async getSubject(sub_code) {
//         const q = `
//       SELECT 
//         s.sub_code, s.sub_name, s.teacher_id,
//         t.tname, t.abbr, t.dept
//       FROM subjects s
//       LEFT JOIN teachers t ON t.user_id = s.teacher_id
//       WHERE s.sub_code = $1 LIMIT 1;
//     `;
//         const { rows } = await pool.query(q, [sub_code]);
//         return rows[0];
//     }

//     // UPDATE SUBJECT (INCLUDING TEACHER ASSIGNMENT)
//     static async updateSubject(sub_code, updates) {
//         const client = await pool.connect();
//         try {
//             await client.query("BEGIN");

//             const fields = [];
//             const values = [];
//             let i = 1;

//             for (const [key, val] of Object.entries(updates)) {
//                 fields.push(`${key} = $${i}`);
//                 values.push(val);
//                 i++;
//             }

//             const q = `
//         UPDATE subjects
//         SET ${fields.join(", ")}
//         WHERE sub_code = $${i}
//         RETURNING *;
//       `;
//             values.push(sub_code);

//             const { rows } = await client.query(q, values);
//             await client.query("COMMIT");
//             return rows[0];

//         } catch (err) {
//             await client.query("ROLLBACK");
//             throw err;
//         } finally {
//             client.release();
//         }
//     }

//     // DELETE SUBJECT
//     static async deleteSubject(sub_code) {
//         const client = await pool.connect();
//         try {
//             await client.query("BEGIN");
//             await client.query("DELETE FROM subjects WHERE sub_code = $1", [sub_code]);
//             await client.query("COMMIT");
//             return true;
//         } catch (err) {
//             await client.query("ROLLBACK");
//             throw err;
//         } finally {
//             client.release();
//         }
//     }
// }
