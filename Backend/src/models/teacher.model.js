import pool from "../config/pool.js";

export class TeacherModel {

    // ➤ CREATE TEACHER WITH TRANSACTION
    static async createTeacher({
        user_id,
        abbr,
        tname,
        designation,
        specialization,
        dept,
        photo_url
    }) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = `
        INSERT INTO teachers 
        (user_id, abbr, tname, designation, specialization, dept, photo_url)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING *;
      `;

            const params = [
                user_id,
                abbr,
                tname,
                designation,
                specialization,
                dept,
                photo_url
            ];

            const { rows } = await client.query(q, params);

            await client.query("COMMIT");
            return rows[0];

        } catch (err) {
            await client.query("ROLLBACK");
            throw err;
        } finally {
            client.release();
        }
    }

    // ➤ GET ALL TEACHERS
    static async getAllTeachers() {
        const q = `
      SELECT 
        u.user_id, u.email, u.role, u.created_at,
        t.abbr, t.tname, t.designation, t.specialization, 
        t.dept, t.photo_url
      FROM users u
      JOIN teachers t ON u.user_id = t.user_id
      WHERE u.role = 'teacher';
    `;
        const { rows } = await pool.query(q);
        return rows;
    }

    // ➤ GET ONE TEACHER BY user_id
    static async getTeacherById(user_id) {
        const q = `
      SELECT  
        u.user_id, u.email, u.role, u.created_at,
        t.abbr, t.tname, t.designation, t.specialization, 
        t.dept, t.photo_url
      FROM users u
      JOIN teachers t ON u.user_id = t.user_id
      WHERE u.user_id = $1
      LIMIT 1;
    `;
        const { rows } = await pool.query(q, [user_id]);
        return rows[0];
    }

    // ➤ UPDATE TEACHER WITH TRANSACTION
    static async updateTeacher(user_id, updates) {
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
        UPDATE teachers
        SET ${fields.join(", ")}, photo_url = photo_url, updated_at = NOW()
        WHERE user_id = $${i}
        RETURNING *;
      `;

            values.push(user_id);

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

    // ➤ DELETE TEACHER
    static async deleteTeacher(user_id) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            await client.query(
                "DELETE FROM teachers WHERE user_id = $1",
                [user_id]
            );

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

// export class TeacherModel {

//     static async getAllTeachers() {
//         const client = await pool.connect();
//         try {
//             await client.query("BEGIN");

//             const q = "SELECT * FROM teachers";
//             const { rows } = await client.query(q);

//             await client.query("COMMIT");
//             return rows;

//         } catch (error) {
//             await client.query("ROLLBACK");
//             throw error;
//         } finally {
//             client.release();
//         }
//     }

//     static async getTeacherById(user_id) {
//         const client = await pool.connect();
//         try {
//             await client.query("BEGIN");

//             const q = "SELECT * FROM teachers WHERE user_id = $1";
//             const { rows } = await client.query(q, [user_id]);

//             await client.query("COMMIT");
//             return rows[0];

//         } catch (error) {
//             await client.query("ROLLBACK");
//             throw error;
//         } finally {
//             client.release();
//         }
//     }

//     static async getTeacherByAbbr(abbr) {
//         const client = await pool.connect();
//         try { 
//             await client.query("BEGIN");

//             const q = "SELECT * FROM teachers WHERE abbr = $1 LIMIT 1";
//             const { rows } = await client.query(q, [abbr]);

//             await client.query("COMMIT");
//             return rows[0];

//         } catch (error) {
//             await client.query("ROLLBACK");
//             throw error;
//         } finally {
//             client.release();
//         }
//     }

//     static async createTeacher({ user_id, abbr, tname, designation, specialization, dept, programme, photo_url }) {
//         const client = await pool.connect();
//         try {
//             await client.query("BEGIN");

//             const q = `
//                 INSERT INTO teachers (
//                     user_id, abbr, tname, designation, specialization,
//                     dept, programme, photo_url
//                 )
//                 VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
//                 RETURNING *
//             `;

//             const { rows } = await client.query(q, [
//                 user_id, abbr, tname, designation,
//                 specialization, dept, programme, photo_url
//             ]);

//             await client.query("COMMIT");
//             return rows[0];

//         } catch (error) {
//             await client.query("ROLLBACK");
//             throw error;
//         } finally {
//             client.release();
//         }
//     }

//     static async updateTeacher(user_id, updates) {
//         const client = await pool.connect();
//         try {
//             await client.query("BEGIN");

//             const fields = [];
//             const values = [];
//             let idx = 1;

//             if (updates.abbr !== undefined) {
//                 fields.push(`abbr = $${idx++}`);
//                 values.push(updates.abbr);
//             }
//             if (updates.tname !== undefined) {
//                 fields.push(`tname = $${idx++}`);
//                 values.push(updates.tname);
//             }
//             if (updates.designation !== undefined) {
//                 fields.push(`designation = $${idx++}`);
//                 values.push(updates.designation);
//             }
//             if (updates.specialization !== undefined) {
//                 fields.push(`specialization = $${idx++}`);
//                 values.push(updates.specialization);
//             }
//             if (updates.dept !== undefined) {
//                 fields.push(`dept = $${idx++}`);
//                 values.push(updates.dept);
//             }
//             if (updates.programme !== undefined) {
//                 fields.push(`programme = $${idx++}`);
//                 values.push(updates.programme);
//             }
//             if (updates.photo_url !== undefined) {
//                 fields.push(`photo_url = $${idx++}`);
//                 values.push(updates.photo_url);
//             }

//             if (fields.length === 0) {
//                 throw new Error("No fields to update");
//             }

//             const q = `
//                 UPDATE teachers
//                 SET ${fields.join(", ")}
//                 WHERE user_id = $${idx}
//                 RETURNING *
//             `;

//             values.push(user_id);

//             const { rows } = await client.query(q, values);

//             await client.query("COMMIT");
//             return rows[0];

//         } catch (error) {
//             await client.query("ROLLBACK");
//             throw error;
//         } finally {
//             client.release();
//         }
//     }

//     static async deleteTeacher(user_id) {
//         const client = await pool.connect();
//         try {
//             await client.query("BEGIN");

//             const q = "DELETE FROM teachers WHERE user_id = $1";
//             await client.query(q, [user_id]);

//             await client.query("COMMIT");
//             return true;

//         } catch (error) {
//             await client.query("ROLLBACK");
//             throw error;
//         } finally {
//             client.release();
//         }
//     }

//     static async getTeachersByProgramme(programme) {
//         const client = await pool.connect();
//         try {
//             await client.query("BEGIN");

//             const q = "SELECT * FROM teachers WHERE programme = $1";
//             const { rows } = await client.query(q, [programme]);

//             await client.query("COMMIT");
//             return rows;

//         } catch (error) {
//             await client.query("ROLLBACK");
//             throw error;
//         } finally {
//             client.release();
//         }
//     }

//     static async getTeachersByDept(dept) {
//         const client = await pool.connect();
//         try {
//             await client.query("BEGIN");

//             const q = "SELECT * FROM teachers WHERE dept = $1";
//             const { rows } = await client.query(q, [dept]);

//             await client.query("COMMIT");
//             return rows;

//         } catch (error) {
//             await client.query("ROLLBACK");
//             throw error;
//         } finally {
//             client.release();
//         }
//     }
// }


// // Usage example:
// // import { TeacherModel } from '../models/teacher.model.js';
// //
// // const example = async () => {
// //   try {
// //     const teachers = await TeacherModel.getAllTeachers();
// //     console.log(teachers);
// //   } catch (error) {
// //     console.error('Error:', error);
// //   }
// // };
