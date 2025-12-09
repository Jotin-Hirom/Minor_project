import { listSubjects, getAttendance } from "../services/student.service.js";

export async function getSubjects(req, res) {
  try {
    const rows = await listSubjects(req.user.uid);
    res.json(rows);
  } catch {
    res.status(500).json({ error: "Server error" });
  }
}

export async function getStudentAttendance(req, res) {
  try {
    const { subject_id } = req.query;
    const r = await getAttendance(req.user.uid, subject_id);
    res.json(r);
  } catch {
    res.status(500).json({ error: "Server error" });
  }
}

