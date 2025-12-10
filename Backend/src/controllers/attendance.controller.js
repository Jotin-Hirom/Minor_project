import { AttendanceModel } from "../models/attendance.model.js";

export class AttendanceController {

    // ➤ MARK OR UPDATE ATTENDANCE
    static async mark(req, res) {
        try {
            const { student_id, course_id, attendance_date, present } = req.body;

            if (!student_id || !course_id || !attendance_date || present === undefined) {
                return res.status(400).json({
                    error: "Missing required fields (student_id, course_id, attendance_date, present)"
                });
            }

            const record = await AttendanceModel.markAttendance({
                student_id,
                course_id,
                attendance_date,
                present
            });

            res.status(201).json(record);

        } catch (err) {
            console.error("Error marking attendance:", err);
            res.status(500).json({ error: "Server error" });
        }
    }

    // ➤ GET ATTENDANCE FOR ONE STUDENT
    static async getForStudent(req, res) {
        try {
            const { student_id, course_id } = req.params;

            const data = await AttendanceModel.getStudentAttendance(student_id, course_id);

            res.json(data);

        } catch (err) {
            console.error("Error fetching student attendance:", err);
            res.status(500).json({ error: "Server error" });
        }
    }

    // ➤ GET ATTENDANCE FOR A WHOLE COURSE
    static async getForCourse(req, res) {
        try {
            const { course_id } = req.params;

            const data = await AttendanceModel.getCourseAttendance(course_id);

            res.json(data);

        } catch (err) {
            console.error("Error fetching course attendance:", err);
            res.status(500).json({ error: "Server error" });
        }
    }

    // ➤ DELETE ATTENDANCE RECORD
    static async delete(req, res) {
        try {
            const { attendance_id } = req.params;

            const deleted = await AttendanceModel.deleteAttendance(attendance_id);

            if (!deleted) {
                return res.status(404).json({ error: "Attendance record not found" });
            }

            res.json({ success: true, message: "Attendance record deleted" });

        } catch (err) {
            console.error("Error deleting attendance:", err);
            res.status(500).json({ error: "Server error" });
        }
    }


    static async summary(req, res) {
    try {
        const { student_id, course_id } = req.params;

        const summary = await AttendanceModel.getAttendanceSummary(
            student_id,
            course_id
        );

        return res.json(summary);

    } catch (err) {
        console.error("Error fetching attendance summary:", err);
        res.status(500).json({ error: "Server error" });
    }
}

}



// import subjectsData from "../subjects.js";

// export const getSubjectByCode = (code) => {
//   return subjectsData.subjects.find(
//     (sub) => sub.code.toLowerCase() === code.trim().toLowerCase()
//   );
// };

// export const getSubjectName = (code) => {
//   if (typeof code !== "string") return null;

//   const subject = subjectsData.subjects.find(
//     (sub) => sub.code.toLowerCase() === code.trim().toLowerCase()
//   );

//   return subject ? subject.course_name : null;
// };


// export const getSubject = (code) => {
//   return subjectsData.subjects.find(
//     (sub) => sub.code.toLowerCase() === code.trim().toLowerCase()
//   ) || { error: "Invalid subject code" };
// };


// export const searchSubject = (keyword) => {
//   keyword = keyword.toLowerCase();
//   return subjectsData.subjects.filter(
//     (sub) =>
//       sub.course_name.toLowerCase().includes(keyword) ||
//       sub.code.toLowerCase().includes(keyword)
//   );
// };

// console.log(getSubjectByCode("AM704"));
// console.log(getSubjectName("AM704"));