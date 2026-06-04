import fs from "node:fs";
import path from "node:path";

/** Canonical: %USERPROFILE%\\OneDrive\\Lifepunch\\Rules (legacy: ...\\Documents\\Lifepunch\\Rules) */
export function resolveOneDriveRulesDir() {
    const home = process.env.USERPROFILE || process.env.HOME || "";
    const candidates = [
        path.join(home, "OneDrive", "Lifepunch", "Rules"),
        path.join(home, "OneDrive", "Documents", "Lifepunch", "Rules"),
    ];
    for (const dir of candidates) {
        if (fs.existsSync(dir)) return dir;
    }
    return candidates[0];
}
