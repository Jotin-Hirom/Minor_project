import { AdminModel } from "../models/admin.model.js";

export const adminGetStudents = async (req, res) => {
  try {
    const students = await AdminModel.getAllStudents();
    res.json(students);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
};

export const adminGetTeachers = async (req, res) => {
  try {
    const teachers = await AdminModel.getAllTeachers();
    res.json(teachers);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
};

export const adminUpdateStudent = async (req, res) => {
  try {
    const updated = await AdminModel.updateStudent(req.params.id, req.body);
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
};

export const adminUpdateTeacher = async (req, res) => {
  try {
    const updated = await AdminModel.updateTeacher(req.params.id, req.body);
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
};

// BLOCK/UNBLOCK STUDENT
export const adminBlockStudent = async (req, res) => {
  try {
    const updated = await AdminModel.setStudentBlockStatus(
      req.params.id,
      req.body.isBlocked
    );
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
};

// DELETE USER
export const adminDeleteAnyUser = async (req, res) => {
  try {
    const result = await AdminModel.deleteUser(
      req.params.id,
      req.user.user_id // admin who is deleting
    );
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
};
