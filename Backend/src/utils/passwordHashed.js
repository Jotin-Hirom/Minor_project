import bcrypt from "bcrypt";

const SALT_ROUNDS = 10;

export const hashPassword = async (plainPassword) => {
  if (!plainPassword) throw new Error("Password missing!");
  return await bcrypt.hash(plainPassword, SALT_ROUNDS);
};

export const comparePassword = async (plainPassword, hashed) => {
  return await bcrypt.compare(plainPassword, hashed);
};
