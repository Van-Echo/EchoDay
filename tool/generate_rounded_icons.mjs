// Build icon assets from the designer's originals without altering the glyphs.
// Install the SVG renderer in build/icon-tools:
// npm install --prefix build/icon-tools --no-save @resvg/resvg-js
import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const require = createRequire(import.meta.url);
const { Resvg } = require(path.join(root, 'build/icon-tools/node_modules/@resvg/resvg-js'));
const branding = path.join(root, 'assets/branding');
const render = (svg, size) => new Resvg(svg, {
  fitTo: { mode: 'width', value: size },
}).render().asPng();

const icons = {};
for (const name of ['maru', 'cheng']) {
  const original = fs.readFileSync(path.join(branding, `echoday_${name}_white_source.png`));
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  <defs><clipPath id="round"><rect width="1024" height="1024" rx="160" ry="160"/></clipPath></defs>
  <image width="1024" height="1024" clip-path="url(#round)" href="data:image/png;base64,${original.toString('base64')}"/>
</svg>\n`;
  fs.writeFileSync(path.join(branding, `echoday_${name}_white_rounded.svg`), svg);
  fs.writeFileSync(path.join(branding, `echoday_${name}_white_rounded.png`), render(svg, 1024));
  icons[name] = svg;
}

// PNG-backed ICO entries retain antialiased transparent corners at every size.
const sizes = [16, 20, 24, 32, 40, 48, 64, 128, 256];
const frames = sizes.map(size => render(icons.maru, size));
const header = Buffer.alloc(6 + 16 * frames.length);
header.writeUInt16LE(1, 2);
header.writeUInt16LE(frames.length, 4);
let offset = header.length;
for (let i = 0; i < sizes.length; i++) {
  const entry = 6 + i * 16;
  header[entry] = sizes[i] === 256 ? 0 : sizes[i];
  header[entry + 1] = header[entry];
  header.writeUInt16LE(1, entry + 4);
  header.writeUInt16LE(32, entry + 6);
  header.writeUInt32LE(frames[i].length, entry + 8);
  header.writeUInt32LE(offset, entry + 12);
  offset += frames[i].length;
}
fs.writeFileSync(path.join(root, 'windows/runner/resources/app_icon.ico'), Buffer.concat([header, ...frames]));

// Modern Android launchers apply their own adaptive mask. These rounded assets
// are also supplied to legacy launchers and task switchers.
for (const [density, size] of Object.entries({ mdpi: 48, hdpi: 72, xhdpi: 96, xxhdpi: 144, xxxhdpi: 192 })) {
  const directory = path.join(root, `android/app/src/main/res/mipmap-${density}`);
  fs.mkdirSync(directory, { recursive: true });
  fs.writeFileSync(path.join(directory, 'ic_launcher.png'), render(icons.cheng, size));
}
console.log('Generated rounded Maru Windows ICO and Cheng Android launcher assets.');
