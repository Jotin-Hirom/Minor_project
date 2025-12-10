import pool from "../config/pool.js";

export class EnrollmentModel {

    // ➤ ENROLL STUDENT INTO COURSE
    static async enrollStudent({ student_id, course_id }) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = `
                INSERT INTO student_enrollments (student_id, course_id)
                VALUES ($1, $2)
                ON CONFLICT (student_id, course_id)
                DO NOTHING
                RETURNING *;
            `;

            const values = [student_id, course_id];

            const { rows } = await client.query(q, values);

            await client.query("COMMIT");
            return rows[0];    // may be undefined if already enrolled

        } catch (err) {
            await client.query("ROLLBACK");
            throw err;
        } finally {
            client.release();
        }
    }

    // ➤ GET ALL ENROLLMENTS FOR A COURSE
    static async getEnrollmentsByCourse(course_id) {
        const q = `
            SELECT 
                e.enrollment_id,
                e.student_id,
                s.sname AS student_name,
                s.roll_no,
                s.semester,
                s.programme,
                e.course_id
            FROM student_enrollments e
            JOIN students s ON e.student_id = s.user_id
            WHERE e.course_id = $1
            ORDER BY s.sname ASC;
        `;

        const { rows } = await pool.query(q, [course_id]);
        return rows;
    }

    // ➤ GET ALL COURSES FOR A STUDENT
    static async getEnrollmentsByStudent(student_id) {
        const q = `
            SELECT 
                e.enrollment_id,
                e.course_id,
                c.code AS course_code,
                s.course_name
            FROM student_enrollments e
            JOIN course_offerings c ON e.course_id = c.course_id
            LEFT JOIN subjects s ON c.code = s.code
            WHERE e.student_id = $1
            ORDER BY s.course_name ASC;
        `;

        const { rows } = await pool.query(q, [student_id]);
        return rows;
    }

    // ➤ UNENROLL
    static async unenrollStudent(student_id, course_id) {
        const q = `
            DELETE FROM student_enrollments
            WHERE student_id = $1 AND course_id = $2
            RETURNING *;
        `;

        const { rows } = await pool.query(q, [student_id, course_id]);
        return rows[0];
    }
}
