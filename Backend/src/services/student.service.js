import pool  from "../config/pool.js";

export async function listSubjects(userId) {
  const { rows } = await pool.query(`SELECT s.subject_id, s.name FROM enrolments e JOIN subjects s ON e.subject_id=s.subject_id WHERE e.user_id=$1`, [userId]);
  return rows;
}

export async function getAttendance(userId, subjectId) {
  const { rows: classes } = await pool.query("SELECT class_id, held_on FROM classes WHERE subject_id=$1 ORDER BY held_on", [subjectId]);
  const { rows: marks } = await pool.query("SELECT class_id, status FROM attendance WHERE user_id=$1 AND class_id = ANY($2)", [userId, classes.map(c => c.class_id)]);
  const statusByClass = new Map(marks.map(m => [m.class_id, m.status]));
  const days = classes.map(c => ({ date: c.held_on, present: statusByClass.get(c.class_id) === "present" }));
  const total = classes.length;
  const attended = days.filter(d => d.present).length;
  const missed = total - attended;
  const pct = total ? Math.round(attended / total * 100) : 0;
  return { total, attended, missed, pct, days };
}

