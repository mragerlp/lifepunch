import { chromium } from "playwright";
import http from "http";
import fs from "fs";
import path from "path";

const ROOT = "C:\\Users\\jared\\Projects\\lifepunch\\.tmp-cvlbrand";
const OUT = "C:\\Users\\jared\\Projects\\lifepunch\\.tmp-cvlbrand-scratch";
const MIME = { ".html": "text/html", ".css": "text/css", ".js": "text/javascript", ".png": "image/png", ".ico": "image/x-icon", ".svg": "image/svg+xml", ".webmanifest": "application/manifest+json" };
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
await new Promise(r => server.listen(8350, r));

const browser = await chromium.launch();
const shots = [
  ["home", "/", "1440", { width: 1440, height: 900 }, ".arch-map"],
  ["home", "/", "390", { width: 390, height: 844 }, ".arch-map"],
  ["sys", "/system/", "1440", { width: 1440, height: 900 }, ".loop-diagram"],
  ["sys", "/system/", "390", { width: 390, height: 844 }, ".loop-diagram"],
  ["strips", "/system/", "1440", { width: 1440, height: 900 }, null],
];

for (const [tag, url, vpTag, vp, sel] of shots) {
  const page = await browser.newPage({ viewport: vp });
  const errs = [];
  page.on("pageerror", e => errs.push(e.message));
  await page.goto("http://127.0.0.1:8350" + url, { waitUntil: "networkidle" });
  if (sel) await page.evaluate((s) => document.querySelector(s)?.scrollIntoView({ block: "center" }), sel);
  else await page.evaluate(() => document.getElementById("tooling")?.scrollIntoView({ block: "start" }));
  await page.waitForTimeout(3500);
  const probe = await page.evaluate(() => {
    const stages = [...document.querySelectorAll(".loop-stage")].map(el => el.textContent.trim() + ":" + el.className);
    const observe = document.querySelector(".loop-observe")?.textContent?.trim() || null;
    const caption = document.querySelector(".loop-caption")?.textContent?.trim() || null;
    const tooling = getComputedStyle(document.querySelector("#tooling .wrap") || document.body).textAlign;
    const black = getComputedStyle(document.querySelector("#blackhole .wrap") || document.body).textAlign;
    return { stages, observe, caption, tooling, black, title: document.title };
  });
  console.log(tag, vpTag, JSON.stringify(probe), "errs", errs.length);
  if (sel) {
    const clip = await page.evaluate((s) => {
      const r = document.querySelector(s).getBoundingClientRect();
      return { x: Math.max(0, r.x - 20), y: Math.max(0, r.y - 10), width: Math.min(innerWidth, r.width + 40), height: Math.min(innerHeight, r.height + 30) };
    }, sel);
    await page.screenshot({ path: `${OUT}\\v361_${tag}_${vpTag}.png`, clip });
  } else {
    await page.screenshot({ path: `${OUT}\\v361_strips_${vpTag}.png`, fullPage: false });
  }
  await page.close();
}
await browser.close();
server.close();
console.log("done");
