import { chromium } from "playwright";
import http from "http";
import fs from "fs";
import path from "path";

const ROOT = "C:\\Users\\jared\\Projects\\lifepunch\\.tmp-cvlbrand";
const MIME = { ".html": "text/html", ".css": "text/css", ".js": "text/javascript", ".png": "image/png", ".svg": "image/svg+xml", ".ico": "image/x-icon", ".webmanifest": "application/manifest+json" };

const server = http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split("?")[0]);
  if (p.endsWith("/")) p += "index.html";
  let file = path.join(ROOT, p);
  if (!fs.existsSync(file) && fs.existsSync(file + ".html")) file += ".html";
  if (!fs.existsSync(file) || fs.statSync(file).isDirectory()) {
    const idx = path.join(ROOT, p, "index.html");
    if (fs.existsSync(idx)) file = idx;
    else { res.writeHead(404); res.end("nf"); return; }
  }
  res.writeHead(200, { "content-type": MIME[path.extname(file)] || "application/octet-stream" });
  res.end(fs.readFileSync(file));
});

await new Promise(r => server.listen(8341, r));
const browser = await chromium.launch();
const errors = [];

for (const [name, vp] of [["desktop", { width: 1440, height: 900 }], ["mobile", { width: 390, height: 844 }]]) {
  const page = await browser.newPage({ viewport: vp });
  page.on("console", m => { if (m.type() === "error") errors.push(`${name}: ${m.text()}`); });
  page.on("response", r => { if (r.status() >= 400) errors.push(`${name}: HTTP ${r.status()} ${r.url()}`); });
  await page.goto("http://127.0.0.1:8341/about/", { waitUntil: "networkidle" });

  const probe = await page.evaluate(() => {
    const blk = document.querySelector(".about-creator");
    if (!blk) return { found: false };
    const img = blk.querySelector("img.about-creator-avatar");
    const craft = document.querySelector(".about-craft");
    const order = blk.compareDocumentPosition(craft) & Node.DOCUMENT_POSITION_FOLLOWING;
    const st = getComputedStyle(blk);
    const imgSt = getComputedStyle(img);
    const r = blk.getBoundingClientRect();
    const ir = img.getBoundingClientRect();
    const tr = blk.querySelector(".about-creator-text").getBoundingClientRect();
    return {
      found: true,
      beforeCraft: !!order,
      alt: img.getAttribute("alt"),
      imgLoaded: img.naturalWidth > 0,
      radiusBlock: st.borderRadius, radiusImg: imgSt.borderRadius,
      bg: st.backgroundColor,
      stacked: ir.bottom <= tr.top + 1 || ir.right <= tr.left + 1 ? (ir.right <= tr.left + 1 ? "row" : "column") : "overlap",
      nameText: blk.querySelector(".about-creator-name")?.textContent.trim(),
      realText: blk.querySelector(".about-creator-real")?.textContent.replace(/\s+/g, " ").trim(),
      copyHasKey: blk.querySelector(".about-creator-copy")?.textContent.includes("you turn the keys"),
      h1Count: document.querySelectorAll("h1").length,
      hscroll: document.documentElement.scrollWidth > document.documentElement.clientWidth,
      top: r.top,
    };
  });
  console.log(name, JSON.stringify(probe, null, 1));

  await page.evaluate(() => document.querySelector(".about-creator").scrollIntoView({ block: "center" }));
  await page.waitForTimeout(400);
  await page.screenshot({ path: `C:\\Users\\jared\\Projects\\lifepunch\\.tmp-cvlbrand-scratch\\creator_${name}.png` });
  await page.close();
}

console.log("console/network errors:", errors.length ? errors : "none");
await browser.close();
server.close();
