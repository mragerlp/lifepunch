import { chromium } from "playwright";
import http from "http";
import fs from "fs";
import path from "path";

const ROOT = "C:\\Users\\jared\\Projects\\lifepunch\\.tmp-cvlbrand";
const MIME = { ".html": "text/html", ".css": "text/css", ".js": "text/javascript", ".png": "image/png" };
const server = http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split("?")[0]);
  if (p.endsWith("/")) p += "index.html";
  let file = path.join(ROOT, p);
  if (!fs.existsSync(file) || fs.statSync(file).isDirectory()) { res.writeHead(404); res.end("nf"); return; }
  res.writeHead(200, { "content-type": MIME[path.extname(file)] || "application/octet-stream" });
  res.end(fs.readFileSync(file));
});
await new Promise(r => server.listen(8346, r));

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
page.on("console", m => console.log("[console]", m.text()));
page.on("pageerror", e => console.log("[pageerror]", e.message));
await page.goto("http://127.0.0.1:8346/", { waitUntil: "networkidle" });
await page.waitForTimeout(9000);
const probe = await page.evaluate(() => {
  const out = { inlineStyles: {}, hookFound: !!window.__orbitProbe };
  document.querySelectorAll(".arch-node").forEach(el => {
    out.inlineStyles[el.className] = el.getAttribute("style") || "(none)";
  });
  if (window.__orbitProbe) out.probe = window.__orbitProbe();
  return out;
});
console.log(JSON.stringify(probe, null, 1));
await browser.close();
server.close();
