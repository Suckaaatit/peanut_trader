import path from 'path';
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, '.', '');
  return {
    base: './',
    server: {
      port: 3000,
      host: '0.0.0.0',
      proxy: {
        '/peanut-api': {
          target: 'https://peanut.ifxdb.com',
          changeOrigin: true,
          secure: true,
          rewrite: (path) => path.replace(/^\/peanut-api/, ''),
        },
        '/promo-soap': {
          target: 'https://api-forexcopy.contentdatapro.com',
          changeOrigin: true,
          secure: true,
          rewrite: (path) => path.replace(/^\/promo-soap/, ''),
        },
      },
    },
    plugins: [react()],
    define: {
      'process.env.API_KEY': JSON.stringify(env.GEMINI_API_KEY),
      'process.env.GEMINI_API_KEY': JSON.stringify(env.GEMINI_API_KEY)
    },
    resolve: {
      alias: {
        '@': path.resolve(__dirname, '.'),
      }
    }
  };
});
