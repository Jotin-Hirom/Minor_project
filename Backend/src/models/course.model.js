import pool from "../config/pool.js";

export class CourseModel {

    // ➤ CREATE COURSE OFFERING
    static async createCourse({ code, teacher_id }) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = `
                INSERT INTO course_offerings (code, teacher_id)
                VALUES ($1, $2)
                RETURNING *;
            `;

            const values = [code, teacher_id];

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

    // ➤ GET ALL COURSES
    static async getAllCourses() {
        const q = `
            SELECT 
                c.*,
                s.course_name AS subject_name,
                t.tname AS teacher_name,
                t.abbr AS teacher_abbr,
                t.dept AS teacher_dept
            FROM course_offerings c
            LEFT JOIN subjects s ON c.code = s.code
            LEFT JOIN teachers t ON c.teacher_id = t.user_id
            ORDER BY c.created_at DESC;
        `;

        const { rows } = await pool.query(q);
        return rows;
    }

    //GET BY CODE
    static async getCoursesByCode(code) {
        const q = `
            SELECT 
                c.*,
                s.course_name AS subject_name,
                t.tname AS teacher_name,
                t.abbr AS teacher_abbr,
                t.dept AS teacher_dept
            FROM course_offerings c
            LEFT JOIN subjects s ON c.code = s.code
            LEFT JOIN teachers t ON c.teacher_id = t.user_id
            WHERE c.code = $1
            ORDER BY c.created_at DESC;
        `;

        const { rows } = await pool.query(q, [code]);
        return rows;
    }

    // ➤ GET ONE COURSE
    static async getCourseById(course_id) {
        const q = `
            SELECT 
                c.*,
                s.course_name AS subject_name,
                t.tname AS teacher_name,
                t.abbr AS teacher_abbr
            FROM course_offerings c
            LEFT JOIN subjects s ON c.code = s.code
            LEFT JOIN teachers t ON c.teacher_id = t.user_id
            WHERE c.course_id = $1
            LIMIT 1;
        `;

        const { rows } = await pool.query(q, [course_id]);
        return rows[0];
    }

    // ➤ UPDATE COURSE
    static async updateCourse(course_id, updates) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const fields = [];
            const values = [];
            let i = 1;

            for (const [key, value] of Object.entries(updates)) {
                fields.push(`${key} = $${i}`);
                values.push(value);
                i++;
            }

            const q = `
                UPDATE course_offerings
                SET ${fields.join(", ")}
                WHERE course_id = $${i}
                RETURNING *;
            `;
            values.push(course_id);

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

    // ➤ DELETE COURSE
    static async deleteCourse(course_id) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            await client.query(
                "DELETE FROM course_offerings WHERE course_id = $1",
                [course_id]
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
