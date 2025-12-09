import { UserModel } from "../models/user.model.js";

export const validateUserVerification = async (req, res, next) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({
                success: false,
                message: "Email is required"
            });  
        }

        const user = await UserModel.getUserByEmail(email);

        if (!user) {
            return res.status(400).json({
                success: false,
                message: "Invalid email or password."
            });
        }

        if (!user.isverified) {
            return res.status(403).json({
                success: false,
                message: "Please verify your email before logging in."
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
