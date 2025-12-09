import { validateStudentRegistration } from "./student.validator.js";
import { validateTeacherRegistration } from "./teacher.validator.js";

export const roleBasedSignupValidator = async (req, res, next) => {
    const role = req.body.role;

    if (!role) {  
        return res.status(400).json({
            success: false,
            message: "Role is required (admin/student/teacher)"
        }); 
    }

    if (role === "student") {
        return validateStudentRegistration(req, res, next); 
    }

    if (role === "teacher") {
        return validateTeacherRegistration(req, res, next);
    }

    return res.status(400).json({
        success: false,
        message: "Invalid role. Allowed roles: student, teacher"
    });
};
