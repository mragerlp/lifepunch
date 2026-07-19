/* V2B local gate: C/V/L card interactions, a11y states, mobile overflow,
   console errors, screenshots for the owner aesthetic gate. */
import { chromium } from "playwright";
import fs from "node:fs";

const BASE = "http://127.0.0.1:8788";
const OUT = "C:/Users/jared/Projects/lifepunch/.tmp-cvlbrand-scratch/v2b-local";
fs.mkdirSync(OUT, { recursive: true });

const errors = [];
let failures = 0;
function check(name, cond) {
  console.log(`${cond ? "PASS" : "FAIL"}  ${name}`);
  if (!cond) failures++;
}

const browser = await chromium.launch();

// ---------- Desktop ----------
{
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  page.on("console", m => { if (m.type() === "error") errors.push("home: " + m.text()); });
  page.on("pageerror", e => errors.push("home pageerror: " + e.message));
  await page.goto(BASE + "/", { waitUntil: "networkidle" });
  await page.waitForTimeout(6200); // entrance sequence completes ~5.9s
  await page.screenshot({ path: `${OUT}/01_home_resting_hero.png` });

  const btns = await page.locator(".arch-node[data-card]").count();
  check("three letter buttons render", btns === 3);
  check("no legacy chips", (await page.locator(".arch-node.tl, .arch-node.tr, .arch-node.bl, .arch-node.br").count()) === 0);

  // C opens
  await page.click('.arch-node[data-card="c"]');
  await page.waitForTimeout(320);
  check("card C visible", await page.locator("#cvl-card-c").isVisible());
  check("C aria-expanded=true", (await page.getAttribute('.arch-node[data-card="c"]', "aria-expanded")) === "true");
  await page.screenshot({ path: `${OUT}/02_home_card_C.png` });

  // Esc closes + refocus
  await page.keyboard.press("Escape");
  await page.waitForTimeout(120);
  check("Esc closes C", !(await page.locator("#cvl-card-c").isVisible()));
  check("focus returns to C button", await page.evaluate(() =>
    document.activeElement?.getAttribute("data-card") === "c"));

  // V opens; switching to L closes V
  await page.click('.arch-node[data-card="v"]');
  await page.waitForTimeout(320);
  check("card V visible", await page.locator("#cvl-card-v").isVisible());
  await page.screenshot({ path: `${OUT}/03_home_card_V.png` });
  await page.click('.arch-node[data-card="l"]');
  await page.waitForTimeout(320);
  check("switch closes V", !(await page.locator("#cvl-card-v").isVisible()));
  check("card L visible", await page.locator("#cvl-card-l").isVisible());
  await page.screenshot({ path: `${OUT}/04_home_card_L.png` });

  // Outside click closes
  await page.mouse.click(60, 860);
  await page.waitForTimeout(120);
  check("outside click closes L", !(await page.locator("#cvl-card-l").isVisible()));

  // Keyboard: focus button directly, Enter opens (buttons are native <button>)
  await page.focus('.arch-node[data-card="c"]');
  await page.keyboard.press("Enter");
  await page.waitForTimeout(320);
  check("Enter opens C from keyboard", await page.locator("#cvl-card-c").isVisible());
  await page.keyboard.press("Escape");

  // Pillar row
  check("pillar row has 4 lane links", (await page.locator(".hero-pillar-row a").count()) === 4);

  // Closer sub
  check("home closer live", (await page.textContent(".final-cta .final-panel p")).includes("black hole"));
  await page.close();
}

// ---------- Reduced motion ----------
{
  const ctx = await browser.newContext({ reducedMotion: "reduce", viewport: { width: 1440, height: 900 } });
  const page = await ctx.newPage();
  page.on("pageerror", e => errors.push("home-rm pageerror: " + e.message));
  await page.goto(BASE + "/", { waitUntil: "networkidle" });
  await page.waitForTimeout(400);
  await page.click('.arch-node[data-card="c"]');
  check("reduced-motion: card opens instantly", await page.locator("#cvl-card-c").isVisible());
  await ctx.close();
}

// ---------- Mobile 390 ----------
{
  const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
  page.on("pageerror", e => errors.push("home-390 pageerror: " + e.message));
  await page.goto(BASE + "/", { waitUntil: "networkidle" });
  await page.waitForTimeout(6200);
  const hscroll = await page.evaluate(() =>
    document.documentElement.scrollWidth > document.documentElement.clientWidth + 1);
  check("mobile 390: no horizontal scroll", !hscroll);
  await page.click('.arch-node[data-card="l"]');
  await page.waitForTimeout(320);
  check("mobile: card L visible", await page.locator("#cvl-card-l").isVisible());
  await page.screenshot({ path: `${OUT}/05_home_390_card_L.png` });
  await page.close();
}

// ---------- Subpages ----------
for (const [path, name, probe] of [
  ["/system/", "system", async p => (await p.textContent("#tooling")).includes("custom-built MCP server")
      && (await p.textContent("#blackhole")).includes("never enter it")],
  ["/work/", "work", async p => (await p.textContent(".case-lede")).includes("cybersecurity that locks the whole operation")],
  ["/about/", "about", async p => (await p.textContent(".about-panel-body")).includes("AI-fluency barrier")
      && (await p.locator(".about-craft li").count()) === 9],
  ["/404.html", "404", async p => (await p.textContent("h1")).includes("The loop holds")],
]) {
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  page.on("console", m => { if (m.type() === "error") errors.push(name + ": " + m.text()); });
  page.on("pageerror", e => errors.push(name + " pageerror: " + e.message));
  await page.goto(BASE + path, { waitUntil: "networkidle" });
  await page.waitForTimeout(800);
  check(`${name}: copy probe`, await probe(page));
  await page.screenshot({ path: `${OUT}/10_${name}.png`, fullPage: name !== "404" });
  await page.close();
}

check("zero console/page errors", errors.length === 0);
if (errors.length) console.log(errors.join("\n"));

await browser.close();
console.log("GATE RESULT:", failures === 0 ? "PASS" : failures + " FAILURES");
process.exit(failures ? 1 : 0);
