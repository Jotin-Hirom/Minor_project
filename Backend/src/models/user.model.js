import pool from "../config/pool.js";

export class UserModel {

    static async markVerified(user_id) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");
            const q = `
                UPDATE users SET isverified = TRUE WHERE user_id = $1
            `;
            await client.query(q, [user_id]);
            await client.query("COMMIT");
        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }


    // CREATE USER
    static async createUser({ email, password_hash, role }) {
        const client = await pool.connect();
        try {
            await client.query("BEGIN");

            const q = `
                INSERT INTO users (email, password_hash, role)
                VALUES ($1, $2, $3)
                RETURNING user_id, email, role, created_at
            `;

            const { rows } = await client.query(q, [
                email.toLowerCase(),
                password_hash,
                role
            ]);

            await client.query("COMMIT");
            return rows[0];

        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }
    }

    // GET USER BY EMAIL
    static async getUserByEmail(email) {
        const q = "SELECT * FROM users WHERE email = $1 LIMIT 1";
        const { rows } = await pool.query(q, [email.toLowerCase()]);
        return rows[0];
    }

    // GET USER BY ID
    static async getUserById(user_id) {
        const q = "SELECT * FROM users WHERE user_id = $1 LIMIT 1";
        const { rows } = await pool.query(q, [user_id]);
        return rows[0];
    }

    // UPDATE USER PASSWORD
    static async updateUserPassword(user_id, new_password_hash) {
        const q = `
            UPDATE users
            SET password_hash = $1
            WHERE user_id = $2
            RETURNING user_id, email, role, created_at
        `;

        const { rows } = await pool.query(q, [
            new_password_hash,
            user_id
        ]);

        return rows[0];
    }

    // UPDATE USER
    static async updateUser(user_id, updates) {
        const fields = [];
        const values = [];
        let index = 1;

        if (updates.email) {
            fields.push(`email = $${index++}`);
            values.push(updates.email);
        }

        if (updates.role) {
            fields.push(`role = $${index++}`);
            values.push(updates.role);
        }

        if (fields.length === 0) throw new Error("No fields to update");

        const q = `
            UPDATE users
            SET ${fields.join(", ")}
            WHERE user_id = $${index}
            RETURNING user_id, email, role, created_at
        `;

        values.push(user_id);

        const { rows } = await pool.query(q, values);
        return rows[0];
    }

    // DELETE USER
    static async deleteUser(user_id) {
        const q = "DELETE FROM users WHERE user_id = $1";
        await pool.query(q, [user_id]);
        return true;
    }

    // GET ALL USERS
    static async getAllUsers() {
        const q = "SELECT user_id, email, role, created_at FROM users";
        const { rows } = await pool.query(q);
        return rows;
    }

static async findByHash(token_hash) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const q = "SELECT * FROM refresh_tokens WHERE token_hash = $1 LIMIT 1";
    const { rows } = await client.query(q, [token_hash]);
    await client.query("COMMIT");
    return rows[0];
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

}


// Usage example of object UserModel:
// import { UserModel } from '../models/user.model.js';
//
// const example = async () => {
//   try {
//     const newUser = await UserModel.createUser({
//       email: 'user@example.com',
//       password_hash: 'hashed_password_here',
//       role: 'student'
//     });
//     console.log(newUser);
//   } catch (error) {
//     console.error('Error:', error);
//   }
// };



// Usage example of class StudentModel:
// import { StudentModel } from '../models/student.model.js';
// const newStudent = await StudentModel.createStudent({
//   user_id: 'uuid-here',
//   roll_no: '12345',
//   sname: 'John Doe',
//   semester: 1,
//   programme: 'B.Tech',
//   batch: 2023,
//   photo_url: 'http://example.com/photo.jpg'
// });

// // Get all students
// const students = await StudentModel.getAllStudents();

// // Get student by ID
// const student = await StudentModel.getStudentById('user-uuid');

// // Update student
// const updated = await StudentModel.updateStudent('user-uuid', { sname: 'Jane Doe', semester: 2 });

// // Delete student
// await StudentModel.deleteStudent('user-uuid');

// // Get students by programme
// const Students = await StudentModel.getStudentsByProgramme('MCA');