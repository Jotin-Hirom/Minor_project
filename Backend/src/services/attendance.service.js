import pool  from "../config/pool.js";

export async function markAttendance(userId, payload) {
  const { code, device } = payload || {};
  await pool.query("INSERT INTO scan_events(user_id, code, user_agent, platform, language, res_w, res_h) VALUES($1,$2,$3,$4,$5,$6,$7)", [userId, code || null, device?.userAgent || null, device?.platform || null, device?.language || null, device?.resolution?.w || null, device?.resolution?.h || null]);
  const enrol = await pool.query("SELECT subject_id FROM enrolments WHERE user_id=$1 LIMIT 1", [userId]);
  if (!enrol.rows[0]) return { ok: false, status: 400, body: { error: "Not enrolled" } };
  const subjectId = enrol.rows[0].subject_id;
  const today = new Date();
  const ymd = today.toISOString().slice(0,10);
  const c = await pool.query("SELECT class_id FROM classes WHERE subject_id=$1 AND held_on=$2", [subjectId, ymd]);
  let classId;
  if (c.rows[0]) classId = c.rows[0].class_id;
  else {
    const ins = await pool.query("INSERT INTO classes(subject_id, held_on) VALUES($1,$2) RETURNING class_id", [subjectId, ymd]);
    classId = ins.rows[0].class_id;
  }
  await pool.query("INSERT INTO attendance(user_id, class_id, status) VALUES($1,$2,'present') ON CONFLICT (user_id, class_id) DO UPDATE SET status='present'", [userId, classId]);
  return { ok: true, status: 200, body: { ok: true } };
}

