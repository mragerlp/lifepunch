/**
 * Smoke-test /rules HTML generation.
 * Run: node scripts/test-rules-html.mjs
 */
import worker from "../lifepunch/website/deployments/cloudflare-worker.mjs";
import { writeFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const outPath = join(__dirname, "../tmp-rules.html");

const env = {
  LINKS: null,
  ADMIN_STEAMIDS: "",
  STEAM_API_KEY: "",
};

const res = await worker.fetch(new Request("https://lifepunch.co/rules"), env);
const html = await res.text();
writeFileSync(outPath, html);

const copyIdx = html.indexOf("function copyRuleText");
const exportIdx = html.indexOf("export default");
const dataCopyIdx = html.indexOf("data-copy-text");
const enOnly = html.match(/<div class="rule-line" id="en-only"[\s\S]{0,800}/);

console.log("HTML length:", html.length);
console.log("copyRuleText found:", copyIdx >= 0, copyIdx);
console.log("export default in HTML:", exportIdx);
console.log("data-copy-text in HTML:", dataCopyIdx);
console.log("\nen-only markup:\n", enOnly?.[0] ?? "MISSING");

// Last script block in body (rules page scripts)
const parts = html.split("<script>");
const rulesScript = parts[parts.length - 1]?.split("</script>")[0] ?? "";
try {
  new Function(rulesScript);
  console.log("\nRules script: parses OK");
} catch (e) {
  console.error("\nRules script PARSE ERROR:", e.message);
  const lines = rulesScript.split("\n");
  for (let i = 0; i < lines.length; i++) {
    try {
      new Function(lines.slice(0, i + 1).join("\n"));
    } catch {
      console.error("Breaks around line", i + 1, ":", lines[i]?.slice(0, 120));
      break;
    }
  }
}
