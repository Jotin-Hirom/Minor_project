import { UserModel } from "../models/user.model.js";

export const validateTeacherRegistration = async (req, res, next) => {
    try {
        const {
            email, 
        } = req.body; 

        // Check duplicate email
        const existEmail = await UserModel.getUserByEmail(email);
        if (existEmail) {
            return res.status(409).json({
                success: false,
                message: "Email already exists"
            });
        }
        next();
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message
        });
    }
};
