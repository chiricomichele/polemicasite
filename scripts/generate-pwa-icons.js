import sharp from 'sharp';
import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const sizes = [192, 512];
const inputPath = join(__dirname, '../public/logo.jpeg');

async function generateIcons() {
  console.log('Generazione icone PWA...');
  
  const inputBuffer = readFileSync(inputPath);
  
  for (const size of sizes) {
    // Icona normale
    await sharp(inputBuffer)
      .resize(size, size, {
        fit: 'contain',
        background: { r: 255, g: 255, b: 255, alpha: 1 }
      })
      .png()
      .toFile(join(__dirname, `../public/pwa-${size}x${size}.png`));
    
    console.log(`✓ Creata pwa-${size}x${size}.png`);
    
    // Icona maskable (con padding per adaptive icons)
    const padding = Math.floor(size * 0.1);
    await sharp(inputBuffer)
      .resize(size - (padding * 2), size - (padding * 2), {
        fit: 'contain',
        background: { r: 255, g: 255, b: 255, alpha: 0 }
      })
      .extend({
        top: padding,
        bottom: padding,
        left: padding,
        right: padding,
        background: { r: 255, g: 255, b: 255, alpha: 1 }
      })
      .png()
      .toFile(join(__dirname, `../public/pwa-maskable-${size}x${size}.png`));
    
    console.log(`✓ Creata pwa-maskable-${size}x${size}.png`);
  }
  
  console.log('\n✅ Tutte le icone PWA sono state generate con successo!');
}

generateIcons().catch(console.error);

// Made with Bob
