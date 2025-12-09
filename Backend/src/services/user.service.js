import { UserModel } from "../models/user.model.js";

/**
 * Get all users
 */
export const getAllUsers = async () => {
    return await UserModel.getAllUsers();
}; 

/** 
 * Get user by user_id
 */
export const getUserById = async (user_id) => {
    return await UserModel.getUserById(user_id);
};

/**
 * Update user by user_id
 */
export const updateUser = async (user_id, updates) => {
    return await UserModel.updateUser(user_id, updates);
};

/**
 * Delete user by user_id
 */
export const deleteUser = async (user_id) => {
    return await UserModel.deleteUser(user_id);
};
