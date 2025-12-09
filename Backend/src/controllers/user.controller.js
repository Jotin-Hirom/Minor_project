import { getAllUsers, getUserById, updateUser, deleteUser } from "../services/user.service.js";

/**
 * Get all users
 */
export const getAllUsersController = async (req, res, next) => {
  try {
    const users = await getAllUsers();
    res.json({ users });
  } catch (err) {
    next(err);
  }
};

/**
 * Get user by user_id
 */
export const getUserByIdController = async (req, res, next) => {
  try {
    const { user_id } = req.params;
    const user = await getUserById(user_id);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }
    res.json({ user });
  } catch (err) {
    next(err);
  }
};

/**
 * Update user by user_id
 */
export const updateUserController = async (req, res, next) => {
  try {
    const { user_id } = req.params;
    const updates = req.body;
    const updatedUser = await updateUser(user_id, updates);
    res.json({ user: updatedUser });
  } catch (err) {
    next(err);
  }
};

/**
 * Delete user by user_id
 */
export const deleteUserController = async (req, res, next) => {
  try {
    const { user_id } = req.params;
    await deleteUser(user_id);
    res.json({ message: "User deleted successfully" });
  } catch (err) {
    next(err);
  }
};
