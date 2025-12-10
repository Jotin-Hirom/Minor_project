import express from "express";
import { SubjectController } from "../controllers/subject.controller.js";
import {  auth,requireRole } from "../middlewares/auth.middleware.js";

const router = express.Router();
const adminOnly = [auth, requireRole("admin","teacher","student")];

router.get("/", adminOnly, SubjectController.getAll);
router.get("/:code", adminOnly, SubjectController.getOne);
router.post("/create", adminOnly, SubjectController.create);
router.put("/:code", adminOnly, SubjectController.update);
router.delete("/:code", adminOnly, SubjectController.delete);

export default router;
 
// import express from "express";
// import { SubjectController } from "../controllers/subject.controller.js";
// import { requireAuth } from "../middlewares/auth.middleware.js";
// import { requireRole } from "../middlewares/roles.middleware.js";

// const router = express.Router();

// // ADMIN ONLY
// const adminOnly = [requireAuth, requireRole("admin")];

// /** ADMIN ROUTES */
// router.get("/", adminOnly, SubjectController.getAll);
// router.get("/:code", adminOnly, SubjectController.getOne);
// router.post("/", adminOnly, SubjectController.create);
// router.put("/:code", adminOnly, SubjectController.update);
// router.delete("/:code", adminOnly, SubjectController.delete);

// export default router;
