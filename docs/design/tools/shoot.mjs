// Renders canvas boards to PNG with Reduce Motion on, so every animation shows its final state.
// Usage (from docs/design/tools):  NODE_USE_ENV_PROXY=1 node shoot.mjs ../mocks ../screenshots all 'round6=3,*=1'
//   3rd arg: "all", or a comma list of board files / page ids (e.g. "round6" or "TGToday.dc.html").
//   4th arg: device scale, either one number or per page ("round6=3,*=1"). Wide overview boards stay at 2x at most.
import { createRequire } from 'module';
import fs from 'fs';
import path from 'path';
let playwright;
for (const base of [import.meta.url, '/opt/node22/lib/node_modules/', path.join(path.dirname(process.execPath), '../lib/node_modules/')]) {
  try { playwright = createRequire(base)('playwright'); break; } catch { /* try the next location */ }
}
if (!playwright) throw new Error('Playwright not found: npm i -g playwright (Chromium must be installed too)');

const [, , projectDirArg, outDirArg, onlyArg, scaleArg] = process.argv;
const projectDir = path.resolve(projectDirArg), outDir = path.resolve(outDirArg);
const canvas = JSON.parse(fs.readFileSync(path.join(projectDir, 'canvas.json'), 'utf8'));
const only = onlyArg && onlyArg !== 'all' ? new Set(onlyArg.split(',')) : null;
const scaleFor = (page) => {
  if (scaleArg && scaleArg.includes('=')) {
    const map = Object.fromEntries(scaleArg.split(',').map((kv) => kv.split('=')));
    return Number(map[page] ?? map['*'] ?? 1);
  }
  return Number(scaleArg || 1);
};
const slug = (s) => s.toLowerCase().normalize('NFKD').replace(/[̀-ͯ]/g, '')
  .replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');

const browser = await playwright.chromium.launch({ proxy: { server: process.env.HTTPS_PROXY } });
const results = [];
const fontCache = new Map();
for (const file of canvas.order) {
  const b = canvas.boards[file];
  const pageId = b.page || 'round1';
  if (only && !only.has(file) && !only.has(pageId)) continue;
  const scale = b.w > 390 ? Math.min(scaleFor(pageId), 2) : scaleFor(pageId);  // wide overview boards stay at 2x at most
  const ctx = await browser.newContext({ viewport: { width: b.w, height: b.h }, deviceScaleFactor: scale, reducedMotion: 'reduce' });
  // Fonts are fetched by Node (proxy + CA bundle, TLS verified) and handed to the page.
  await ctx.route(/^https:\/\/fonts\.(googleapis|gstatic)\.com\//, async (route) => {
    const req = route.request();
    const url = req.url();
    let entry = fontCache.get(url);
    if (!entry) {
      const res = await fetch(url, { headers: { 'user-agent': req.headers()['user-agent'] || 'Mozilla/5.0' } });
      entry = { status: res.status, body: Buffer.from(await res.arrayBuffer()), type: res.headers.get('content-type') || 'application/octet-stream' };
      fontCache.set(url, entry);
    }
    await route.fulfill({ status: entry.status, body: entry.body, headers: { 'content-type': entry.type, 'access-control-allow-origin': '*' } });
  });
  const page = await ctx.newPage();
  await page.goto('file://' + path.join(projectDir, file), { waitUntil: 'networkidle', timeout: 60000 });
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(300);
  const title = b.title || file.replace('.dc.html', '');
  let name = slug(title);
  const m = title.match(/^(\d+)\s*·\s*(.*)$/);           // "1 · Today" -> "01-today"
  if (m) name = String(m[1]).padStart(2, '0') + '-' + slug(m[2]);
  if (!m && (b.w > 390)) name = '00-' + name;              // overview boards sort first
  const dir = path.join(outDir, pageId);
  fs.mkdirSync(dir, { recursive: true });
  const out = path.join(dir, name + '.png');
  await page.screenshot({ path: out, clip: { x: 0, y: 0, width: b.w, height: b.h } });
  const fontsOk = await page.evaluate(() => [...document.fonts].filter((f) => f.status === 'loaded').map((f) => f.family).filter((v, i, a) => a.indexOf(v) === i));
  results.push({ file, page: pageId, title, png: path.relative(outDir, out), w: b.w, h: b.h, scale, fonts: fontsOk });
  await ctx.close();
}
await browser.close();
// Merge into any existing manifest so rendering a few boards keeps the rest listed, in canvas order.
const manifestPath = path.join(outDir, '_manifest.json');
const previous = fs.existsSync(manifestPath) ? JSON.parse(fs.readFileSync(manifestPath, 'utf8')) : [];
const byFile = new Map(previous.map((r) => [r.file, r]));
for (const r of results) byFile.set(r.file, r);
const merged = canvas.order.filter((f) => byFile.has(f)).map((f) => byFile.get(f));
fs.writeFileSync(manifestPath, JSON.stringify(merged, null, 2) + '\n');
for (const r of results) console.log(`${r.png}  ${r.w * r.scale}x${r.h * r.scale}  fonts: ${r.fonts.join(', ') || 'none'}`);
