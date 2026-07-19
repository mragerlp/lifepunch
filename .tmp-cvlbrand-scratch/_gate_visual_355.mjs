import { chromium } from "playwright";
import http from "http";
import fs from "fs";
import path from "path";

const ROOT = "C:\\Users\\jared\\Projects\\lifepunch\\.tmp-cvlbrand";
const OUT = "C:\\Users\\jared\\Projects\\lifepunch\\.tmp-cvlbrand-scratch";
const MIME = { ".html": "text/html", ".css": "text/css", ".js": "text/javascript", ".png": "image/png", ".svg": "image/svg+xml", ".ico": "image/x-icon" };

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
await new Promise(r => server.listen(8342, r));

const browser = await chromium.launch();
const errors = [];
const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
page.on("console", m => { if (m.type() === "error") errors.push("system: " + m.text()); });
page.on("response", r => { if (r.status() >= 400) errors.push(`system: HTTP ${r.status()} ${r.url()}`); });

// /system — chip brain icon + wider fragments
await page.goto("http://127.0.0.1:8342/system/", { waitUntil: "networkidle" });
await page.waitForTimeout(1200);
const sys = await page.evaluate(() => {
  const icon = document.querySelector(".loop-brain .lb-icon");
  const vortex = document.querySelector(".loop-vortex");
  return {
    iconPresent: !!icon,
    iconHref: icon ? icon.getAttribute("href") : null,
    glyphGone: !document.querySelector(".lb-glyph"),
    vortexAnim: vortex ? getComputedStyle(vortex).animationName : null,
    docks: document.querySelectorAll(".lb-dock").length,
  };
});
console.log("system:", JSON.stringify(sys));
await page.evaluate(() => document.querySelector(".loop-diagram").scrollIntoView({ block: "center" }));
await page.waitForTimeout(2500);
await page.screenshot({ path: OUT + "\\v355_system_brain.png", clip: { x: 60, y: 90, width: 900, height: 700 } });

// /about — rain canvas over avatar, animating
page.removeAllListeners("console"); page.removeAllListeners("response");
page.on("console", m => { if (m.type() === "error") errors.push("about: " + m.text()); });
page.on("response", r => { if (r.status() >= 400) errors.push(`about: HTTP ${r.status()} ${r.url()}`); });
await page.goto("http://127.0.0.1:8342/about/", { waitUntil: "networkidle" });
await page.evaluate(() => document.querySelector(".about-creator").scrollIntoView({ block: "center" }));
await page.waitForTimeout(1600);
const about = await page.evaluate(() => {
  const cv = document.getElementById("creator-rain");
  const st = getComputedStyle(cv);
  const c2 = cv.getContext("2d");
  const data = c2.getImageData(0, 0, cv.width, cv.height).data;
  let lit = 0;
  for (let i = 0; i < data.length; i += 4) if (data[i + 1] > 60) lit++;
  const fr = document.querySelector(".about-creator-frame").getBoundingClientRect();
  const cr = cv.getBoundingClientRect();
  return {
    blend: st.mixBlendMode, opacity: st.opacity,
    litPx: lit, canvasCovers: Math.abs(fr.width - cr.width) < 2 && Math.abs(fr.height - cr.height) < 2,
    radius: st.borderRadius,
  };
});
const snap1 = await page.evaluate(() => document.getElementById("creator-rain").toDataURL().length);
await page.waitForTimeout(700);
const snap2 = await page.evaluate(() => document.getElementById("creator-rain").toDataURL().length);
console.log("about:", JSON.stringify({ ...about, animating: snap1 !== snap2 }));
await page.screenshot({ path: OUT + "\\v355_creator_rain.png", clip: await page.evaluate(() => {
  const r = document.querySelector(".about-creator").getBoundingClientRect();
  return { x: r.x - 10, y: r.y - 10, width: r.width + 20, height: r.height + 20 };
}) });

// reduced motion — rain hidden
const rm = await browser.newPage({ viewport: { width: 1440, height: 900 }, reducedMotion: "reduce" });
await rm.goto("http://127.0.0.1:8342/about/", { waitUntil: "networkidle" });
const rmHidden = await rm.evaluate(() => getComputedStyle(document.getElementById("creator-rain")).display === "none");
console.log("reduced-motion rain hidden:", rmHidden);
await rm.close();

console.log("errors:", errors.length ? errors : "none");
await browser.close();
server.close();
