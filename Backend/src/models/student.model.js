import pool from "../config/pool.js";

export class StudentModel {

    static async getStudentsBySemesterAndProgramme(semester, programme) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const q = `
                SELECT * FROM students
                WHERE semester = $1 AND programme = $2
            `;
            const { rows } = await client.query(q, [semester, programme]);
            await client.query("COMMIT");
            return rows;
        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }

    static async getAllStudents() {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const { rows } = await client.query("SELECT * FROM students");
            await client.query("COMMIT");
            return rows;
        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }

    static async getStudentById(user_id) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const q = "SELECT * FROM students WHERE user_id = $1";
            const { rows } = await client.query(q, [user_id]);
            await client.query("COMMIT");
            return rows[0];
        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }

    static async getStudentByRollNo(roll_no) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const q = "SELECT * FROM students WHERE roll_no = $1";
            const { rows } = await client.query(q, [roll_no]);
            await client.query("COMMIT");
            return rows[0];
        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }

    static async createStudent({ user_id, roll_no, sname, semester, programme, batch, photo_url }) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = `
                INSERT INTO students (user_id, roll_no, sname, semester, programme, batch, photo_url)
                VALUES ($1, $2, $3, $4, $5, $6, $7)
                RETURNING *
            `;

            const result = await client.query(q, [
                user_id, roll_no, sname, semester, programme, batch, photo_url
            ]);

            await client.query("COMMIT");
            return result.rows[0];

        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }

    static async updateStudent(user_id, updates) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const fields = [];
            const values = [];
            let index = 1;

            if (updates.sname !== undefined) {
                fields.push(`sname = $${index++}`);
                values.push(updates.sname);
            }
            if (updates.semester !== undefined) {
                fields.push(`semester = $${index++}`);
                values.push(updates.semester);
            }
            if (updates.programme !== undefined) {
                fields.push(`programme = $${index++}`);
                values.push(updates.programme);
            }
            if (updates.batch !== undefined) {
                fields.push(`batch = $${index++}`);
                values.push(updates.batch);
            }
            if (updates.photo_url !== undefined) {
                fields.push(`photo_url = $${index++}`);
                values.push(updates.photo_url);
            }

            if (fields.length === 0) {
                throw new Error("No fields to update");
            }

            const q = `
                UPDATE students
                SET ${fields.join(", ")}
                WHERE user_id = $${index}
                RETURNING *
            `;

            values.push(user_id);

            const { rows } = await client.query(q, values);

            await client.query("COMMIT");
            return rows[0];

        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }

    static async deleteStudent(user_id) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const q = "DELETE FROM students WHERE user_id = $1";
            await client.query(q, [user_id]);
            await client.query("COMMIT");
            return true;
        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }

    static async getStudentsByProgramme(programme) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const q = "SELECT * FROM students WHERE programme = $1";
            const { rows } = await client.query(q, [programme]);
            await client.query("COMMIT");
            return rows;
        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }

    static async getStudentByRollNo(roll_no) {

        const client = await pool.connect();
        try {
            
            await client.query("BEGIN");
            const q = "SELECT * FROM students WHERE roll_no = $1 LIMIT 1";
            const { rows } = await pool.query(q, [roll_no]);
            await client.query("COMMIT");
            return rows[0];
        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
}


    static async getStudentsBySemester(semester) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const q = "SELECT * FROM students WHERE semester = $1";
            const { rows } = await client.query(q, [semester]);
            await client.query("COMMIT");
            return rows;
        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }
}


// Usage example of class StudentModel:
// import { StudentModel } from '../models/student.model.js';
// const example = async () => {
//   try {
//     const students = await StudentModel.getAllStudents();
//     console.log(students.rows);
//   } catch (error) {
//     console.error('Error:', error);
//   }
// };
