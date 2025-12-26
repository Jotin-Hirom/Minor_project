import pool from "../config/pool.js";

export class AttendanceModel {

    static async getHistory(req, res) {
    const { student_id } = req.params;

    const { rows } = await pool.query(`
        SELECT attendance_date, present
        FROM attendance
        WHERE student_id = $1
        ORDER BY attendance_date;
    `, [student_id]);

    res.json(rows);
}


    static async markAllPresent(req, res) {
    const { course_id } = req.body;

    await pool.query(`
        UPDATE attendance
        SET present = TRUE
        WHERE course_id = $1
          AND attendance_date = CURRENT_DATE;
    `, [course_id]);

    res.json({ success: true });
}


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

    static async initAttendance(course_id) {
    await pool.query(`
        INSERT INTO attendance (student_id, course_id, attendance_date, present)
        SELECT student_id, course_id, CURRENT_DATE, FALSE
        FROM student_enrollments
        WHERE course_id = $1
        ON CONFLICT (student_id, course_id, attendance_date)
        DO NOTHING;
    `, [course_id]);
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

    // GET FULL ATTENDANCE LIST FOR A COURSE
    static async getCourseAttendance(course_id) {
        const q = `
               SELECT
            st.user_id,
            st.roll_no,
            st.sname,
            a.present
        FROM attendance a
        JOIN students st ON a.student_id = st.user_id
        WHERE a.course_id = $1
          AND a.attendance_date = CURRENT_DATE
        ORDER BY st.roll_no;
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
