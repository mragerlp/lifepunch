import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { resolveOneDriveRulesDir } from "./resolve-onedrive-rules-dir.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRulesDir = path.resolve(__dirname, "..", "Rules");
const rulesDir = resolveOneDriveRulesDir();
const v1Candidates = [
    path.join(rulesDir, "Rules-V1.txt"),
    path.join(repoRulesDir, "Rules-V1.txt"),
];
const sourcePath =
    process.argv[2] ||
    v1Candidates.find((candidate) => fs.existsSync(candidate)) ||
    path.join(rulesDir, "Rules-V1.txt");
const outPath =
    process.argv[3] ||
    path.resolve(__dirname, "..", "..", "rules", "current-rules.md");

const source = fs.readFileSync(sourcePath, "utf8");
const catalogMatch = source.match(/const LP_RULES = (\[[\s\S]*?\n        \]);/);
if (!catalogMatch) {
    throw new Error(`Could not extract LP_RULES from ${sourcePath}`);
}

const LP_RULES = Function(`"use strict"; return (${catalogMatch[1]});`)();

const htmlToPlainText = (html) =>
    String(html ?? "")
        .replace(/<br\s*\/?>/gi, "\n")
        .replace(/<\/li>\s*<li>/gi, "\n")
        .replace(/<[^>]+>/g, "")
        .replace(/&amp;/g, "&")
        .replace(/&lt;/g, "<")
        .replace(/&gt;/g, ">")
        .replace(/&#39;/g, "'")
        .replace(/&quot;/g, '"')
        .replace(/\s+/g, " ")
        .trim();

const extractTitle = (html) => {
    const match = String(html ?? "").match(/<b>([^<]*)<\/b>/i);
    return match ? match[1].trim() : "";
};

const parseSublistBullets = (html) => {
    const marker = '<ul class="rule-sublist">';
    const start = html.indexOf(marker);
    if (start === -1) return [];
    const end = html.indexOf("</ul>", start);
    if (end === -1) return [];
    const listHtml = html.slice(start + marker.length, end);
    const bullets = [];
    const liRegex = /<li>([\s\S]*?)<\/li>/gi;
    let match;
    while ((match = liRegex.exec(listHtml)) !== null) {
        const item = htmlToPlainText(match[1]);
        if (item && item.trim() !== "[[skip-num]]") bullets.push(item);
    }
    return bullets;
};

const formatRuleLine = (html) => {
    const title = extractTitle(html);
    const marker = '<ul class="rule-sublist">';
    const bullets = parseSublistBullets(html);
    const introHtml = html.includes(marker) ? html.slice(0, html.indexOf(marker)) : html;
    const emDashMatch = introHtml.match(/<\/b>\s*—\s*([\s\S]*)/i);
    const introBody = emDashMatch ? htmlToPlainText(emDashMatch[1]) : "";

    if (bullets.length) {
        const intro = introBody.replace(/:\s*$/, "").trim();
        const parts = intro ? [intro, ...bullets] : bullets;
        const body = parts.join("; ");
        return title ? `- ${title}: ${body}` : `- ${body}`;
    }

    if (introBody) return `- ${title}: ${introBody}`;

    const plain = htmlToPlainText(html);
    return plain ? `- ${plain}` : "";
};

const headingLabel = (block) => {
    if (block.web) return block.web.replace(/^[^\w]+/, "").trim() || block.web;
    if (block.raw) return block.raw;
    return block.webHeading || block.rawHeading || "Section";
};

const renderRules = (rules) =>
    (rules || [])
        .map((rule) => formatRuleLine(rule.html))
        .filter(Boolean)
        .map((line) => `${line}\n`)
        .join("");

const renderGuide = (block) => {
    const title = block.webHeading || block.rawHeading || "Guide";
    const lines = (block.items || []).map((item) => `- ${item}`);
    return `\n### ${title}\n\n${lines.join("\n")}\n\n`;
};

const renderBlock = (block) => {
    if (block.type === "heading") {
        const label = headingLabel(block);
        return `### ${label}\n\n`;
    }
    if (block.type === "rules") return renderRules(block.rules);
    if (block.type === "guide") return renderGuide(block);
    return "";
};

const renderSubcategory = (sub) => {
    const label = (sub.webBtn || sub.rawTitle || "Rules")
        .replace(/^SUB-CATEGORY \d+[A-Z]?:\s*/i, "")
        .trim();
    return `### ${label}\n\n${renderRules(sub.rules)}`;
};

const renderCategory = (cat) => {
    let out = `## ${cat.title}\n\n`;
    if (cat.rules?.length) out += renderRules(cat.rules);
    if (cat.subcategories?.length) {
        out += cat.subcategories.map(renderSubcategory).join("\n");
    }
    if (cat.blocks?.length) {
        out += cat.blocks.map(renderBlock).join("");
    }
    return `${out.trim()}\n\n`;
};

const body = LP_RULES.map(renderCategory).join("").trimEnd();

const markdown = `# LifePunch Official Rules Snapshot

Source: \`https://lifepunch.co/rules\`

Generated from \`${path.basename(sourcePath)}\`. This is a public rules snapshot for review and website maintenance. Direct website links should use stable rule anchors where possible.

${body}
`;

fs.writeFileSync(outPath, `${markdown}\n`, "utf8");
console.log(`Wrote ${outPath}`);
console.log(`Source: ${sourcePath}`);
