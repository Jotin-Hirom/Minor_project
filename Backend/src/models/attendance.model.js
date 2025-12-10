import pool from "../config/pool.js";

export class AttendanceModel {

    // ➤ MARK ATTENDANCE
    static async markAttendance({ student_id, course_id, attendance_date, present }) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = `
                INSERT INTO attendance (student_id, course_id, attendance_date, present)
                VALUES ($1, $2, $3, $4)
                ON CONFLICT (student_id, course_id, attendance_date)
                DO UPDATE SET present = EXCLUDED.present
                RETURNING *;
            `;

            const values = [student_id, course_id, attendance_date, present];

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

    // ➤ GET ATTENDANCE FOR ONE STUDENT IN ONE COURSE
    static async getStudentAttendance(student_id, course_id) {
        const q = `
            SELECT *
            FROM attendance
            WHERE student_id = $1 AND course_id = $2
            ORDER BY attendance_date ASC;
        `;
        const { rows } = await pool.query(q, [student_id, course_id]);
        return rows;
    }

    // ➤ GET FULL ATTENDANCE LIST FOR A COURSE
    static async getCourseAttendance(course_id) {
        const q = `
            SELECT 
                a.*, 
                s.sname AS student_name,
                s.roll_no
            FROM attendance a
            JOIN students s ON a.student_id = s.user_id
            WHERE a.course_id = $1
            ORDER BY a.attendance_date ASC, s.sname ASC;
        `;
        const { rows } = await pool.query(q, [course_id]);
        return rows;
    }

    // ➤ DELETE ATTENDANCE RECORD
    static async deleteAttendance(attendance_id) {
        const q = `
            DELETE FROM attendance 
            WHERE attendance_id = $1
            RETURNING *;
        `;
        const { rows } = await pool.query(q, [attendance_id]);
        return rows[0];
    }


    static async getAttendanceSummary(student_id, course_id) {
    const q = `
        SELECT
            SUM(CASE WHEN present = TRUE THEN 1 ELSE 0 END) AS present_days,
            SUM(CASE WHEN present = FALSE THEN 1 ELSE 0 END) AS absent_days,
            COUNT(*) AS total_classes,
            ROUND(
                (SUM(CASE WHEN present = TRUE THEN 1 ELSE 0 END)::decimal 
                / NULLIF(COUNT(*), 0)) * 100, 2
            ) AS attendance_percentage
        FROM attendance
        WHERE student_id = $1 AND course_id = $2;
    `;

    const { rows } = await pool.query(q, [student_id, course_id]);
    return rows[0];
}

}
