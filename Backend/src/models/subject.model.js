import pool from "../config/pool.js";

export class SubjectModel {
 // GET SUBJECTS BY TEACHER
static async getSubjectsByTeacherId(teacher_id) {
    const client = await pool.connect();
    try {
        const query = `
            SELECT 
                s.code,
                s.course_name,
                c.course_id
            FROM subjects s
            INNER JOIN course_offerings c
                ON s.code = c.code
            WHERE s.teacher_id = $1;
        `;

        const { rows } = await client.query(query, [teacher_id]);
        return rows;

    } finally {
        client.release();
    }
}

  static async createSubjectsBulk(subjects) {
    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      /**
       * subjects = [
       *   { code: "CS101", course_name: "DBMS", teacher_id: "uuid" },
       *   { code: "CS102", course_name: "OS", teacher_id: null },
       * ]
       */

      const values = [];
      const placeholders = [];

      subjects.forEach((s, index) => {
        const baseIndex = index * 3;
        placeholders.push(
          `($${baseIndex + 1}, $${baseIndex + 2}, $${baseIndex + 3})`
        );
        values.push(s.code, s.course_name, s.teacher_id);
      });

      const insertQuery = `
        INSERT INTO subjects (code, course_name, teacher_id)
        VALUES ${placeholders.join(", ")}
        ON CONFLICT (code) DO NOTHING
        RETURNING *;
      `;

      const { rows: createdSubjects } =
        await client.query(insertQuery, values);

      await client.query("COMMIT");

      return {
        created: createdSubjects,
        skipped: subjects.length - createdSubjects.length,
      };

    } catch (err) {
      await client.query("ROLLBACK");
      throw err;
    } finally {
      client.release();
    }
  }

 // CREATE SUBJECT + COURSE OFFERING (ATOMIC)
static async createSubject({ code, course_name, teacher_id }) {
    const client = await pool.connect();
    try {
        const query = `
            WITH inserted_subject AS (
                INSERT INTO subjects (code, course_name, teacher_id)
                VALUES ($1, $2, $3)
                RETURNING code, course_name, teacher_id
            )
            INSERT INTO course_offerings (code, teacher_id)
            SELECT code, teacher_id
            FROM inserted_subject
            RETURNING *;
        `;

        const values = [code, course_name, teacher_id];

        const { rows } = await client.query(query, values);

        return rows[0];

    } catch (err) {
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

   // DELETE SUBJECT + COURSE OFFERING (ATOMIC, NO CASCADE)
static async deleteSubject(code) {
    const client = await pool.connect();
    try {
        const query = `
            WITH deleted_offerings AS (
                DELETE FROM course_offerings
                WHERE code = $1
            )
            DELETE FROM subjects
            WHERE code = $1
            RETURNING *;
        `;

        const { rowCount } = await client.query(query, [code]);
        return rowCount > 0;

    } catch (err) {
        throw err;
    } finally {
        client.release();
    }
}
}
