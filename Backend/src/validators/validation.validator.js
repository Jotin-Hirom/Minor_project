/**
 * Validation utilities for signup
 */

// name: alphabets and spaces only
export const isValidName = (name) => {
  if (typeof name !== "string") return false;
  const re = /^[A-Za-z ]+$/;
  return re.test(name.trim());
};
 
// roll: first 3 letters then 5 digits (total 8)
export const isValidRoll = (roll) => {
  if (typeof roll !== "string") return false;
  const re = /^[A-Za-z]{3}\d{5}$/;
  return re.test(roll.trim());
};

// Email for student must match roll_no and end with @tezu.ac.in
export const isValidEmailForRoll = (email, roll) => {
  if (typeof email !== "string" || typeof roll !== "string") return false;
  const normalized = email.trim().toLowerCase();
  const expected = `${roll.trim().toLowerCase()}@tezu.ac.in`;
  return normalized === expected;
};

// semester: integer between 4 and 10 (user requirement)
export const isValidSemester = (sem) => {
  const n = parseInt(sem, 10);
  return Number.isInteger(n) && n >= 1 && n <= 10;
};

// programme: alphabets and spaces allowed
export const isValidProgramme = (programme) => {
  if (typeof programme !== "string") return false;
  const re = /^[A-Za-z ]+$/;
  return re.test(programme.trim());
};

// batch: four digit year between 2000 and 2099 (simple)
export const isValidBatch = (batch) => {
  const n = parseInt(batch, 10);
  return Number.isInteger(n) && n >= 2000 && n <= 2099;
};

// password: min 6 chars, at least 4 letters, 1 digit, 1 special
export const isValidPassword = (pwd) => {
  if (typeof pwd !== "string") return false;
  // Positive lookahead regex for required counts
  // at least 4 letters: (?=(.*[A-Za-z]){4,})
  // at least 1 digit: (?=.*\d)
  // at least 1 special: (?=.*\W)
  // min length 6: .{6,}
  const re = /^(?=(.*[A-Za-z]){4,})(?=.*\d)(?=.*\W).{6,}$/;
  return re.test(pwd);
};

// // designation/department: letters, spaces, dots, hyphens allowed
export const isValidDesignationOrDept = (str) => {
  return typeof str === "string" && /^[a-z .-]+$/i.test(str.trim());
};