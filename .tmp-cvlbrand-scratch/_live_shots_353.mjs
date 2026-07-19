import { chromium } from "playwright";
import fs from "fs";

const OUT = "C:\\Users\\jared\\Projects\\lifepunch\\.tmp-cvlbrand-scratch\\live-353";
fs.mkdirSync(OUT, { recursive: true });

const browser = await chromium.launch();
const pages = ["", "system/", "work/", "about/", "legal/", "definitely-not-a-page/"];

for (const [name, vp] of [["desk", { width: 1440, height: 900 }], ["mob", { width: 390, height: 844 }]]) {
  const page = await browser.newPage({ viewport: vp });
  for (const p of pages) {
    const slug = (p || "home").replace(/[^a-z0-9-]/gi, "_");
    await page.goto(`https://cavelux.ai/${p}?cb=${Date.now()}`, { waitUntil: "networkidle", timeout: 45000 });
    await page.waitForTimeout(900);
    await page.screenshot({ path: `${OUT}\\${slug}_${name}.png` });
  }
  await page.close();
}
await browser.close();
console.log("shots done");
