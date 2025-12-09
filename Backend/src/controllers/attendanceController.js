import { markAttendance } from "../services/attendance.service.js";

export async function postMarkAttendance(req, res) {
  try {
    const r = await markAttendance(req.user.uid, req.body);
    if (!r.ok) return res.status(r.status).json(r.body);
    res.json(r.body);
  } catch {
    res.status(500).json({ error: "Server error" });
  }
}

