import pool from "../config/pool.js";

export class CourseModel {

    // ➤ CREATE COURSE OFFERING
    static async createCourse({
        sub_code,
        teacher_id,
        semester,
        programme,
        batch,
        year,
        section
    }) {

        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = `
        INSERT INTO course_offerings 
        (sub_code, teacher_id, semester, programme, batch, year, section)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING *;
      `;

            const values = [
                sub_code,
                teacher_id,
                semester,
                programme,
                batch,
                year,
                section
            ];

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
    SELECT c.*, 
           s.sub_name, s.teacher_id,
           t.tname, t.abbr, t.dept
    FROM course_offerings c
    LEFT JOIN subjects s ON c.sub_code = s.sub_code
    LEFT JOIN teachers t ON s.teacher_id = t.user_id
    ORDER BY c.created_at DESC;
  `;
        const { rows } = await pool.query(q);
        return rows;
    }


    // ➤ GET ONE COURSE
    static async getCourseById(course_id) {
        const q = `
      SELECT c.*, s.sub_name, t.tname, t.abbr
      FROM course_offerings c
      LEFT JOIN subjects s ON c.sub_code = s.sub_code
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
        SET ${fields.join(", ")}, created_at = created_at
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
