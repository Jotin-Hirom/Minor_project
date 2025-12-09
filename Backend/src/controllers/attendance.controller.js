export const scanAttendance = async (req, res) => {};
export const getAttendanceDetails = async (req, res) => {};
export const exportAttendance = async (req, res) => {};
export const getAttendanceSummary = async (req, res) => {};
export const updateAttendanceRecord = async (req, res) => {};
export const deleteAttendanceRecord = async (req, res) => {};
export const getCourseAttendance = async (req, res) => {};
export const getStudentAttendance = async (req, res) => {};
export const markAttendanceManually = async (req, res) => {};
export const getAttendanceByDate = async (req, res) => {};
export const getLatecomers = async (req, res) => {};
export const getAbsentees = async (req, res) => {};

import subjectsData from "../subjects.js";

export const getSubjectByCode = (code) => {
  return subjectsData.subjects.find(
    (sub) => sub.code.toLowerCase() === code.trim().toLowerCase()
  );
};

export const getSubjectName = (code) => {
  if (typeof code !== "string") return null;

  const subject = subjectsData.subjects.find(
    (sub) => sub.code.toLowerCase() === code.trim().toLowerCase()
  );

  return subject ? subject.course_name : null;
};


export const getSubject = (code) => {
  return subjectsData.subjects.find(
    (sub) => sub.code.toLowerCase() === code.trim().toLowerCase()
  ) || { error: "Invalid subject code" };
};


export const searchSubject = (keyword) => {
  keyword = keyword.toLowerCase();
  return subjectsData.subjects.filter(
    (sub) =>
      sub.course_name.toLowerCase().includes(keyword) ||
      sub.code.toLowerCase().includes(keyword)
  );
};


console.log(getSubjectByCode("AM704"));
console.log(getSubjectName("AM704"));