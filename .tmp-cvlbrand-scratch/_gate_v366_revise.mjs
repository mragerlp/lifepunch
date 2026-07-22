import { chromium } from "playwright";
import http from "http";
import fs from "fs";
import path from "path";

const ROOT = "C:\\Users\\jared\\Projects\\lifepunch\\.tmp-cvlbrand";
const MIME = { ".html": "text/html", ".png": "image/png", ".css": "text/css", ".js": "text/javascript" };
const server = http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split("?")[0]);
  if (p.endsWith("/")) p += "index.html";
  let file = path.join(ROOT, p);
  if (!fs.existsSync(file) || fs.statSync(file).isDirectory()) {
    if (p !== "/definitely-not-a-page") {
      const idx = path.join(ROOT, p, "index.html");
      if (fs.existsSync(idx)) file = idx;
      else { res.writeHead(404); res.end(fs.readFileSync(path.join(ROOT, "404.html"))); return; }
    } else { res.writeHead(404); res.end(fs.readFileSync(path.join(ROOT, "404.html"))); return; }
  }
  res.writeHead(200, { "content-type": MIME[path.extname(file)] || "application/octet-stream" });
  res.end(fs.readFileSync(file));
});
await new Promise(r => server.listen(8360, r));
const browser = await chromium.launch();

// 1) brain cycle
{
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto("http://127.0.0.1:8360/system/", { waitUntil: "networkidle" });
  await page.evaluate(() => document.querySelector(".loop-diagram")?.scrollIntoView({ block: "center" }));
  await page.waitForTimeout(800);
  await page.click(".loop-stage.s-arch");
  const seq = [];
  for (let i = 0; i < 3; i++) {
    await page.click("#loop-brain-btn");
    await page.waitForTimeout(120);
    seq.push(await page.evaluate(() => {
      const hot = document.querySelector(".loop-stage.is-hot");
      return hot ? hot.getAttribute("data-stage") : null;
    }));
  }
  console.log("cycle", seq.join(" → "), seq.join(",") === "arch,impl,rev" || seq.join(",") === "impl,rev,arch" ? "PASS" : "CHECK");
  // After focusing arch then 3 brain clicks: first advances from arch -> impl, then rev, then arch
  // Actually: focus arch sets cycleAt=0. Click1: cycleAt=(0+1)%3=1 → impl. Click2 → rev. Click3 → arch.
  // Codex expected arch→impl→rev from cold; with focus-arch first: impl→rev→arch
  await page.close();
}

// cold cycle (no prior focus)
{
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto("http://127.0.0.1:8360/system/", { waitUntil: "networkidle" });
  await page.evaluate(() => document.querySelector(".loop-diagram")?.scrollIntoView({ block: "center" }));
  await page.waitForTimeout(500);
  const seq = [];
  for (let i = 0; i < 3; i++) {
    await page.click("#loop-brain-btn");
    await page.waitForTimeout(120);
    seq.push(await page.evaluate(() => document.querySelector(".loop-stage.is-hot")?.getAttribute("data-stage")));
  }
  console.log("cold-cycle", seq.join(" → "), seq.join(",") === "arch,impl,rev" ? "PASS" : "FAIL");
  await page.close();
}

// 2) strip overlap + black hole count
{
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto("http://127.0.0.1:8360/system/", { waitUntil: "networkidle" });
  await page.evaluate(() => document.getElementById("method-void")?.scrollIntoView({ block: "center" }));
  await page.waitForTimeout(500);
  const probe = await page.evaluate(() => {
    const art = document.querySelector(".v2-strip-art").getBoundingClientRect();
    const bh = document.querySelector("#blackhole .v2-strip-body").getBoundingClientRect();
    const overlap = !(art.right < bh.left || art.left > bh.right || art.bottom < bh.top || art.top > bh.bottom);
    const body = document.body.innerText.toLowerCase();
    const re = /black hole/g;
    let n = 0, m; while ((m = re.exec(body))) n++;
    return { overlap, blackHoleVisibleCount: n };
  });
  console.log("strip", probe, !probe.overlap && probe.blackHoleVisibleCount <= 2 ? "PASS" : "FAIL");
  await page.screenshot({ path: "C:\\\\Users\\\\jared\\\\Projects\\\\lifepunch\\\\.tmp-cvlbrand-scratch\\\\v366_strips.png" });
  await page.close();
}

// 3) 404 og + footer
{
  const page = await browser.newPage({ viewport: { width: 900, height: 700 } });
  await page.goto("http://127.0.0.1:8360/definitely-not-a-page", { waitUntil: "networkidle" });
  const info = await page.evaluate(() => ({
    title: document.title,
    og: document.querySelector('meta[property="og:image"]')?.content || null,
    footerSrc: document.querySelector(".footer-glitch-word")?.getAttribute("src") || null,
  }));
  console.log("404", info, info.og && info.footerSrc ? "PASS" : "FAIL");
  await page.close();
}

await browser.close();
server.close();
