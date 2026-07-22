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
await new Promise(r => server.listen(8345, r));

const browser = await chromium.launch();
for (const [tag, vp] of [["390", { width: 390, height: 844 }], ["768", { width: 768, height: 900 }], ["1024", { width: 1024, height: 768 }], ["1440", { width: 1440, height: 900 }], ["1720", { width: 1720, height: 980 }]]) {
  const page = await browser.newPage({ viewport: vp });
  await page.goto("http://127.0.0.1:8345/", { waitUntil: "networkidle" });
  await page.evaluate(() => document.querySelector(".arch-map").scrollIntoView({ block: "center" }));
  await page.waitForTimeout(9000);
  const geo = await page.evaluate(() => {
    const map = document.querySelector(".arch-map");
    const mr = map.getBoundingClientRect();
    const hub = document.querySelector(".arch-hub-wrap").getBoundingClientRect();
    const out = { map: { w: Math.round(mr.width), h: Math.round(mr.height) }, hub: { cx: Math.round(hub.x + hub.width / 2 - mr.x), cy: Math.round(hub.y + hub.height / 2 - mr.y), w: Math.round(hub.width) } };
    for (const k of ["c", "v", "l"]) {
      const r = document.querySelector(".arch-node.seat-" + k).getBoundingClientRect();
      out[k] = { cx: Math.round(r.x + r.width / 2 - mr.x), cy: Math.round(r.y + r.height / 2 - mr.y), w: Math.round(r.width), h: Math.round(r.height) };
    }
    return out;
  });
  console.log(tag, JSON.stringify(geo));
  const clip = await page.evaluate(() => {
    const r = document.querySelector(".arch-map").getBoundingClientRect();
    return { x: Math.max(0, r.x - 40), y: Math.max(0, r.y - 10), width: Math.min(innerWidth, r.width + 80), height: Math.min(innerHeight, r.height + 40) };
  });
  await page.screenshot({ path: `${OUT}\\repro_orbit_${tag}.png`, clip });
  await page.close();
}
await browser.close();
server.close();
console.log("done");
