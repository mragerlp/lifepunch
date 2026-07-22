import { chromium } from "playwright";
import http from "http";
import fs from "fs";
import path from "path";

const ROOT = "C:\\Users\\jared\\Projects\\lifepunch\\.tmp-cvlbrand";
const OUT = "C:\\Users\\jared\\Projects\\lifepunch\\.tmp-cvlbrand-scratch";
const MIME = { ".html": "text/html", ".png": "image/png", ".css": "text/css", ".js": "text/javascript", ".svg": "image/svg+xml" };
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
await new Promise(r => server.listen(8355, r));
const browser = await chromium.launch();
for (const [tag, vp] of [["1440", { width: 1440, height: 900 }], ["390", { width: 390, height: 844 }]]) {
  const page = await browser.newPage({ viewport: vp });
  const errs = [];
  page.on("pageerror", e => errs.push(e.message));
  await page.goto("http://127.0.0.1:8355/system/", { waitUntil: "networkidle" });
  await page.evaluate(() => document.getElementById("method-void")?.scrollIntoView({ block: "center" }));
  await page.waitForTimeout(2500);
  const probe = await page.evaluate(() => {
    const band = document.querySelector(".v2-strip-band-inner");
    const art = document.querySelector(".v2-strip-art");
    const tooling = document.getElementById("tooling");
    const bh = document.getElementById("blackhole");
    const br = band.getBoundingClientRect();
    const ar = art.getBoundingClientRect();
    const tr = tooling.getBoundingClientRect();
    const bhr = bh.getBoundingClientRect();
    return {
      hscroll: document.documentElement.scrollWidth > window.innerWidth + 1,
      artInBand: ar.left >= br.left - 2 && ar.right <= br.right + 2,
      toolingText: getComputedStyle(tooling).textAlign,
      bhText: getComputedStyle(bh).textAlign,
      orderOk: tr.top < bhr.top,
      artBetween: vpW => true,
      artW: Math.round(ar.width),
      overlapToolArt: !(ar.bottom < tr.top || ar.top > tr.bottom || ar.right < tr.left || ar.left > tr.right),
    };
  });
  // on mobile art should be between; on desktop art can overlap diagonally (under copy) - that's intentional with z-index
  console.log(tag, JSON.stringify(probe), "errs", errs.length);
  await page.screenshot({ path: `${OUT}\\v364_strips_${tag}.png` });
  await page.close();
}
await browser.close();
server.close();
