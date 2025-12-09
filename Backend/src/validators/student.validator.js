import { UserModel } from "../models/user.model.js";
import { StudentModel } from "../models/student.model.js";

export const validateStudentRegistration = async (req, res, next) => {
    try {
        const {
            email, 
            roll_no
        } = req.body; 

        // ----------- DUPLICATE EMAIL CHECK -----------
        const existingUser = await UserModel.getUserByEmail(email);
        if (existingUser) {
            return res.status(408).json({
                success: false,
                message: "Email already exists."
            });
        }

        // ----------- DUPLICATE ROLL NO CHECK -----------
        const existingRoll = await StudentModel.getStudentByRollNo(roll_no);
        if (existingRoll) {
            return res.status(409).json({
                success: false,
                message: "Roll number already exists."
            });
        }

        // VALID → pass to next handler
        next();

    } catch (error) {
        console.error("VALIDATION ERROR:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error."
        });
    }
};
