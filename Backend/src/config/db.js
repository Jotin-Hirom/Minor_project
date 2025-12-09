import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import pool from "./pool.js";

//import.meta.url is a special value available in ES modules that gives the URL of the current script file.
const __filename = fileURLToPath(import.meta.url);
//Takes only the directory path from the full file path.
const __dirname = path.dirname(__filename);

export async function initDB() {
  try {
    console.log("STEP 1: Resolving schema path...");
    // Point to schema/schema.sql
    const schemaPath = path.join(__dirname, "..", "schema", "classQR.sql");
    // Debug print
    console.log("Searching...");
    if (!fs.existsSync(schemaPath)) {
      throw new Error("Schema file not found at " + schemaPath);
    } else {
      console.log("Schema file found at ", schemaPath);
    }
    console.log("STEP 2: Reading schema file...");
    const schema = fs.readFileSync(schemaPath, "utf8");
    console.log("Schema size:", schema.length, "bytes");
    console.log("STEP 3: Executing schema...");
    try {
      try {
        console.log("Coming connect");
        await pool.connect();
      } catch (error) {
        console.log(error);
      }
      console.log("Coming query");
      await pool.query(schema);
    } catch (sqlError) {
      console.error(" SQL Error:", sqlError);
      process.exit(1);
    }
    console.log("Database tables created successfully!");
    process.exit(0);
  } catch (err) {
    console.error("Error initializing DB:", err);
    process.exit(1);
  }
}