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
await new Promise(r => server.listen(8343, r));

const browser = await chromium.launch();
const errors = [];
const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
page.on("console", m => { if (m.type() === "error") errors.push(m.text()); });
page.on("response", r => { if (r.status() >= 400) errors.push(`HTTP ${r.status()} ${r.url()}`); });

await page.goto("http://127.0.0.1:8343/", { waitUntil: "networkidle" });
// let the intro run past seat arrivals (5.2s + 1.3s)
await page.waitForTimeout(7000);

const probe = await page.evaluate(() => {
  const map = document.querySelector(".arch-map");
  const mr = map.getBoundingClientRect();
  const seats = {};
  for (const k of ["c", "v", "l"]) {
    const el = document.querySelector(".arch-node.seat-" + k);
    const r = el.getBoundingClientRect();
    seats[k] = {
      text: el.textContent.trim(),
      cx: +((r.x + r.width / 2 - mr.x) / mr.width).toFixed(3),
      cy: +((r.y + r.height / 2 - mr.y) / mr.height).toFixed(3),
      aria: el.getAttribute("aria-label"),
    };
  }
  const swirl = document.querySelector(".arch-hub-swirl");
  const anims = swirl.getAnimations().map(a => ({ name: a.animationName, state: a.playState, iters: a.effect.getTiming().iterations }));
  const nav = document.querySelector(".nav-brand-sub");
  return { seats, anims, navSub: nav.textContent.trim(), navWordHidden: getComputedStyle(document.querySelector(".nav-brand-word")).display === "none" };
});
console.log(JSON.stringify(probe, null, 1));

// swirl actually rotating: sample transform twice
const m1 = await page.evaluate(() => getComputedStyle(document.querySelector(".arch-hub-swirl")).transform);
await page.waitForTimeout(1500);
const m2 = await page.evaluate(() => getComputedStyle(document.querySelector(".arch-hub-swirl")).transform);
console.log("swirl rotating:", m1 !== m2, "| t1:", m1.slice(0, 40), "| t2:", m2.slice(0, 40));

// card open via VALUE
await page.click(".arch-node.seat-v");
await page.waitForTimeout(400);
const cardOpen = await page.evaluate(() => !document.getElementById("cvl-card-v").hidden && document.querySelector(".arch-node.seat-v").getAttribute("aria-expanded") === "true");
console.log("value card opens:", cardOpen);
await page.keyboard.press("Escape");
await page.waitForTimeout(300);
const cardClosed = await page.evaluate(() => document.getElementById("cvl-card-v").hidden);
console.log("esc closes:", cardClosed);

const heroBox = await page.evaluate(() => {
  const r = document.querySelector(".arch-map").getBoundingClientRect();
  return { x: r.x - 30, y: Math.max(0, r.y - 20), width: r.width + 60, height: Math.min(880, r.height + 40) };
});
await page.screenshot({ path: OUT + "\\v356_hero_desktop.png", clip: heroBox });
await page.screenshot({ path: OUT + "\\v356_full_desktop.png" });

// mobile
const mob = await browser.newPage({ viewport: { width: 390, height: 844 } });
await mob.goto("http://127.0.0.1:8343/", { waitUntil: "networkidle" });
await mob.waitForTimeout(7000);
const mprobe = await mob.evaluate(() => {
  const map = document.querySelector(".arch-map");
  const mr = map.getBoundingClientRect();
  const out = {};
  for (const k of ["c", "v", "l"]) {
    const r = document.querySelector(".arch-node.seat-" + k).getBoundingClientRect();
    out[k] = { cx: +((r.x + r.width / 2 - mr.x) / mr.width).toFixed(3), cy: +((r.y + r.height / 2 - mr.y) / mr.height).toFixed(3) };
  }
  out.hscroll = document.documentElement.scrollWidth > document.documentElement.clientWidth;
  return out;
});
console.log("mobile:", JSON.stringify(mprobe));
const mBox = await mob.evaluate(() => {
  const r = document.querySelector(".arch-map").getBoundingClientRect();
  return { x: Math.max(0, r.x - 8), y: Math.max(0, r.y - 10), width: Math.min(390, r.width + 16), height: r.height + 20 };
});
await mob.screenshot({ path: OUT + "\\v356_hero_mobile.png", clip: mBox });
await mob.close();

console.log("errors:", errors.length ? errors : "none");
await browser.close();
server.close();
