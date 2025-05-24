import { defineConfig } from 'vite';
import eslint from 'vite-plugin-eslint';

export default defineConfig({
  plugins: [
    eslint({
      cache: false,
      include: ['./src/**/*.ts', './src/**/*.tsx'],
      exclude: ['node_modules', 'dist'],
    }),
  ],
  base: './',
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    minify: 'terser',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          phaser: ['phaser'],
        },
      },
    },
  },
  server: {
    host: '0.0.0.0',
    port: 3000,
    strictPort: true,
    open: true,
  },
  preview: {
    host: '0.0.0.0',
    port: 3000,
    strictPort: true,
    open: true,
  },
  define: {
    __VERSION__: JSON.stringify(process.env.npm_package_version),
    __DEV__: JSON.stringify(process.env.NODE_ENV === 'development'),
  },
  css: {
    modules: {
      localsConvention: 'camelCase',
    },
  },
}); 