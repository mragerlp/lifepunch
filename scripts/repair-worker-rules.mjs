import fs from "fs";
import { execSync } from "child_process";

const textPath = process.argv[2] || "c:/Users/stute/OneDrive/Documents/SeperationRules.txt";
const workerPath =
    process.argv[3] || "c:/Users/stute/lifepunch/lifepunch/website/deployments/cloudflare-worker.mjs";

const text = fs.readFileSync(textPath, "utf8");
const head = execSync("git show HEAD:lifepunch/website/deployments/cloudflare-worker.mjs", {
    encoding: "utf8"
});

const rulesMatch = text.match(/\n        \/\/ --- LIFE PUNCH RULES CATALOG[\s\S]*?\n        \];/);
const preMatch = head.match(/^[\s\S]*?(?=        \/\/ --- LIFE PUNCH RULES CATALOG)/);
const postMatch = head.match(/\n        \];[\s\S]*$/);

if (!rulesMatch || !preMatch || !postMatch) {
    console.error("Failed to extract LP_RULES sections", {
        rules: Boolean(rulesMatch),
        pre: Boolean(preMatch),
        post: Boolean(postMatch)
    });
    process.exit(1);
}

const fixed = preMatch[0] + rulesMatch[0] + postMatch[0].slice("\n        ];".length);
fs.writeFileSync(workerPath, fixed);
console.log(`Repaired ${workerPath}`);
