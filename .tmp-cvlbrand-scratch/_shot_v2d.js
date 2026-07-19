const { chromium } = require('playwright');

(async () => {
  const base = process.argv[2] || 'http://127.0.0.1:8788';
  const outDir = process.argv[3] || '.';
  const browser = await chromium.launch();

  // Desktop
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto(base + '/system/', { waitUntil: 'networkidle' });
  await page.waitForTimeout(1200);
  const loop = page.locator('#loop-diagram');
  await loop.scrollIntoViewIfNeeded();
  await page.waitForTimeout(600);
  await page.screenshot({ path: outDir + '/v2d_desktop_full.png', fullPage: false });
  await loop.screenshot({ path: outDir + '/v2d_desktop_loop.png' });

  // Hover state — Observation apex hot
  await page.hover('.loop-stage.s-obs');
  await page.waitForTimeout(900);
  await loop.screenshot({ path: outDir + '/v2d_desktop_loop_hot.png' });

  // Mobile
  const m = await browser.newPage({ viewport: { width: 390, height: 844 } });
  await m.goto(base + '/system/', { waitUntil: 'networkidle' });
  await m.waitForTimeout(1200);
  const mloop = m.locator('#loop-diagram');
  await mloop.scrollIntoViewIfNeeded();
  await m.waitForTimeout(600);
  await mloop.screenshot({ path: outDir + '/v2d_mobile_loop.png' });

  await browser.close();
  console.log('shots done');
})();
