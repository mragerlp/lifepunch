import { chromium } from "playwright";
import http from "http";
import fs from "fs";
import path from "path";

const ROOT = "C:\\Users\\jared\\Projects\\lifepunch\\.tmp-cvlbrand";
const OUT = "C:\\Users\\jared\\Projects\\lifepunch\\.tmp-cvlbrand-scratch";
const MIME = { ".html": "text/html", ".css": "text/css", ".js": "text/javascript", ".png": "image/png", ".ico": "image/x-icon" };

const server = http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split("?")[0]);
  if (p.endsWith("/")) p += "index.html";
  let file = path.join(ROOT, p);
  if (!fs.existsSync(file) || fs.statSync(file).isDirectory()) {
    const idx = path.join(ROOT, p, "index.html");
    if (fs.existsSync(idx)) file = idx; else { res.writeHead(404); res.end("nf"); return; }
  }
  res.writeHead(200, { "content-type": MIME[path.extname(file)] || "application/octet-stream" });
  res.end(fs.readFileSync(file));
});
await new Promise(r => server.listen(8344, r));

const browser = await chromium.launch();
const errors = [];

for (const [name, vp] of [["desktop", { width: 1440, height: 900 }], ["mobile", { width: 390, height: 844 }]]) {
  const page = await browser.newPage({ viewport: vp });
  page.on("console", m => { if (m.type() === "error") errors.push(`${name}: ${m.text()}`); });
  page.on("response", r => { if (r.status() >= 400) errors.push(`${name}: HTTP ${r.status()} ${r.url()}`); });
  await page.goto("http://127.0.0.1:8344/about/", { waitUntil: "networkidle" });
  await page.waitForTimeout(800);

  const probe = await page.evaluate(() => {
    const body = document.querySelector(".about-panel-body");
    const paras = body.querySelectorAll("p.about-p").length;
    const creator = body.querySelector(".about-creator");
    const copy = creator.querySelector(".about-creator-copy").textContent.replace(/\s+/g, " ").trim();
    const panelH = document.querySelector(".about-panel").getBoundingClientRect().height;
    return {
      aboutParas: paras,
      craftGone: !body.querySelector(".about-craft"),
      bulkGone: !body.textContent.includes("LIFEPUNCH") && !body.textContent.includes("black hole"),
      punchline: copy,
      punchlineOk: copy === "Every business benefits from better systems. Bring scattered ideas; leave with something organized, usable, and yours to run. Create and control the orbit.",
      creatorLast: body.lastElementChild.classList.contains("about-creator"),
      rainAnimating: !!document.getElementById("creator-rain"),
      h1: document.querySelectorAll("h1").length,
      panelHeightPx: Math.round(panelH),
      pageHeightPx: Math.round(document.documentElement.scrollHeight),
      hscroll: document.documentElement.scrollWidth > document.documentElement.clientWidth,
    };
  });
  console.log(name, JSON.stringify(probe, null, 1));
  await page.screenshot({ path: `${OUT}\\v357_about_${name}.png`, fullPage: true });
  await page.close();
}
console.log("errors:", errors.length ? errors : "none");
await browser.close();
server.close();
