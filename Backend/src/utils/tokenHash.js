import * as crypto from "crypto";

export function generateEmailToken() {
    return crypto.randomBytes(32).toString("hex");
}

export function hashTokened(token) {
    return crypto.createHash("sha256").update(token).digest("hex");
}

export function comparehashTokened(token, hashedToken) {
    return crypto.createHash("sha256").update(token).digest("hex") === hashedToken;
} 