import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// GitHub Pages sirve el sitio en https://<user>.github.io/<repo>/
// con base conmutable para desarrollo y despliegue.
export default defineConfig({
  plugins: [react()],
  base: process.env.VITE_BASE || '/kali-nordic/',
  build: {
    outDir: 'dist',
    assetsInlineLimit: 8192,
  },
});
