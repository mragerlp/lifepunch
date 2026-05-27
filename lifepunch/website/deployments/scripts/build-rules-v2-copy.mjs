import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rulesDir = path.resolve(process.env.USERPROFILE || "", "OneDrive", "Documents", "Lifepunch", "Rules");
const repoRulesDir = path.resolve(__dirname, "..", "Rules");
const test1Candidates = [
    path.join(repoRulesDir, "Rules-Test1.txt"),
    path.join(rulesDir, "Rules-Test1.txt"),
];
const sourcePath =
    process.argv[2] ||
    test1Candidates.find((candidate) => fs.existsSync(candidate)) ||
    path.join(repoRulesDir, "Rules-Test1.txt");
const fallbackSource = path.resolve(__dirname, "..", "cloudflare-worker.mjs");
const outPath = process.argv[3] || path.join(
    fs.existsSync(rulesDir) ? rulesDir : repoRulesDir,
    "Rules-V2.txt"
);

const readSource = () => {
    if (fs.existsSync(sourcePath)) return fs.readFileSync(sourcePath, "utf8");
    if (fs.existsSync(fallbackSource)) return fs.readFileSync(fallbackSource, "utf8");
    throw new Error(`Source not found: ${sourcePath}`);
};

let text = readSource();

const collapseSingleBulletSublist = (input) =>
    input.replace(
        /html: `\s*<b>([^<]*)<\/b>\s*<ul class="rule-sublist">\s*<li>((?:[^<]|<(?!\/li>))*?)<\/li>\s*<\/ul>\s*`/g,
        'html: `<b>$1</b> — $2`'
    );

text = collapseSingleBulletSublist(text);

text = text.replace(
    /\{ id: "demote-reasons", html: `[^`]+` \},/,
    '{ id: "demote-reasons", html: `<b>Demotions</b><ul class="rule-sublist"><li>Not doing job</li><li>30+ min AFK</li><li>Police corruption</li></ul>` },'
);

text = text.replace(
    /const createRule = \(stream\) => \(id, html\) => \{[\s\S]*?\n            \};/,
    `const createRule = () => (id, html) => renderWebRuleLine(id, html, "", "");`
);

text = text.replace(
    /const renderRawRuleEntry = \(id, html, stream\) => \{[\s\S]*?\n        \};/,
    `const renderRawRuleEntry = (id, html) => \`<li id="\${id}">\${html}</li>\`;`
);

if (!text.includes(".rule-text ul.rule-sublist")) {
    text = text.replace(
        "              .rule-line b { color: var(--lp-blue); }",
        `              .rule-line b { color: var(--lp-blue); }
              .rule-text ul.rule-sublist { margin: 0; padding-left: 20px; list-style: disc; }
              .rule-text b + ul.rule-sublist { margin-top: 4px; }
              .rule-text ul.rule-sublist li { margin-bottom: 6px; line-height: 1.5; }`
    );
}

if (!text.includes(".content li ul.rule-sublist")) {
    text = text.replace(
        "                    .content li.rule-intro ul.rule-sublist { display: none; }",
        `                    .content li.rule-intro ul.rule-sublist { display: none; }
                    .content li ul.rule-sublist { list-style: disc; margin: 8px 0 0 0; padding-left: 20px; }
                    .content li ul.rule-sublist li { border-left: none; padding-left: 0; margin-bottom: 6px; }
                    .content b + ul.rule-sublist { margin-top: 4px; }`
    );
}

fs.writeFileSync(outPath, text, "utf8");
if (outPath.startsWith(rulesDir) && fs.existsSync(repoRulesDir)) {
    fs.writeFileSync(path.join(repoRulesDir, "Rules-V2.txt"), text, "utf8");
}

const splitCreates = (text.match(/parsed = parseRuleSublist\(html\)/g) || []).length;
const singleLiLeft = (text.match(/<ul class="rule-sublist">\s*<li>[^<]*<\/li>\s*<\/ul>/g) || []).length;

console.log(`Wrote ${outPath}`);
console.log(`parseRuleSublist calls remaining: ${splitCreates}`);
console.log(`Single-item sublists remaining: ${singleLiLeft}`);
