import { auth, requireRole } from "../middlewares/auth.middleware.js";
import express from "express";

import {
    adminGetStudents,
    adminGetTeachers,
    adminUpdateStudent,
    adminUpdateTeacher,
    adminBlockStudent,
    adminDeleteAnyUser
} from "../controllers/admin.controller.js";

const router = express.Router();


//  FETCH DATA 
router.get(  
    "/students",
    auth,
    requireRole("admin"),
    adminGetStudents
);

router.get(
    "/teachers",
    auth,
    requireRole("admin"),
    adminGetTeachers
);


//  UPDATE STUDENT / TEACHER 
router.put(
    "/student/:id",
    auth,
    requireRole("admin"),
    adminUpdateStudent
);

router.put(
    "/teacher/:id",
    auth,
    requireRole("admin"),
    adminUpdateTeacher
);


// BLOCK / UNBLOCK STUDENT 
router.patch(
    "/block-student/:id",
    auth,
    requireRole("admin"),
    adminBlockStudent
);


//  DELETE USER 
router.delete(
    "/delete-user/:id",
    auth,
    requireRole("admin"),
    adminDeleteAnyUser
);

export default router;


 