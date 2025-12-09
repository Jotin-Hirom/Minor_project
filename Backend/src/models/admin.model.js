import pool from "../config/pool.js";

export class AdminModel {

    // GET ALL STUDENTS 
    static async getAllStudents() {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = `
                SELECT 
                    u.user_id, u.email, u.role, u.created_at, u.isVerified,
                    s.roll_no, s.sname, s.semester, s.programme, s.batch,
                    s.photo_url, s.isBlocked
                FROM users u
                JOIN students s ON u.user_id = s.user_id
                WHERE u.role = 'student' AND u.isActive = TRUE
                ORDER BY s.roll_no ASC
            `;

            const { rows } = await client.query(q);
            await client.query("COMMIT");

            return rows;

        } catch (err) {
            await client.query("ROLLBACK");
            throw err;
        } finally {
            client.release();
        }
    }


    // GET ALL TEACHERS 
    static async getAllTeachers() {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = `
                SELECT 
                    u.user_id, u.email, u.role, u.created_at, u.isVerified,
                    t.abbr, t.tname, t.designation, t.specialization, t.dept, t.photo_url
                FROM users u
                JOIN teachers t ON u.user_id = t.user_id
                WHERE u.role = 'teacher' AND u.isActive = TRUE
                ORDER BY t.tname ASC
            `;

            const { rows } = await client.query(q);
            await client.query("COMMIT");

            return rows;

        } catch (err) {
            await client.query("ROLLBACK");
            throw err;
        } finally {
            client.release();
        }
    }


    // UPDATE STUDENT 
    static async updateStudent(user_id, updates) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const fields = [];
            const values = [];
            let index = 1;

            for (const [key, val] of Object.entries(updates)) {
                fields.push(`${key} = $${index}`);
                values.push(val);
                index++;
            }

            const q = `
                UPDATE students
                SET ${fields.join(", ")}, updated_at = NOW()
                WHERE user_id = $${index}
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


    // UPDATE TEACHER 
    static async updateTeacher(user_id, updates) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const fields = [];
            const values = [];
            let index = 1;

            for (const [key, val] of Object.entries(updates)) {
                fields.push(`${key} = $${index}`);
                values.push(val);
                index++;
            }

            const q = `
                UPDATE teachers
                SET ${fields.join(", ")}, updated_at = NOW()
                WHERE user_id = $${index}
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


    // BLOCK / UNBLOCK STUDENT 
    static async setStudentBlockStatus(user_id, isBlocked) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = `
                UPDATE students
                SET isBlocked = $1
                WHERE user_id = $2
                RETURNING user_id, isBlocked;
            `;

            const { rows } = await client.query(q, [isBlocked, user_id]);

            await client.query("COMMIT");

            return rows[0];

        } catch (err) {
            await client.query("ROLLBACK");
            throw err;
        } finally {
            client.release();
        }
    }


    // DELETE USER (LOG + DELETE) 
    static async deleteUser(user_id, deleted_by) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            // Fetch user info
            const userQ = `SELECT email, role FROM users WHERE user_id = $1`;
            const userRes = await client.query(userQ, [user_id]);
            const user = userRes.rows[0];

            if (!user) {
                throw new Error("User not found");
            }

            // Log deleted user
            const logQ = `
                INSERT INTO deleted_users (user_id, email, role, deleted_by)
                VALUES ($1, $2, $3, $4)
            `;
            await client.query(logQ, [
                user_id,
                user.email,
                user.role,
                deleted_by
            ]);

            // Delete from users (students/teachers auto deleted)
            const delQ = `DELETE FROM users WHERE user_id = $1`;
            await client.query(delQ, [user_id]);

            await client.query("COMMIT");

            return { success: true, message: "User deleted successfully" };

        } catch (err) {
            await client.query("ROLLBACK");
            throw err;
        } finally {
            client.release();
        }
    }

}


/*
const students = await AdminModel.getAllStudents();
const teachers = await AdminModel.getAllTeachers();
await AdminModel.updateStudent(user_id, { sname: "New Name", semester: 2 });
await AdminModel.setStudentBlockStatus(user_id, true);
await AdminModel.deleteUser(target_user_id, admin_user_id);
*/