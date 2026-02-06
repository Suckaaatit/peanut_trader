import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';

const rootElement = document.getElementById('root');
if (!rootElement) throw new Error("Root element not found");

let isDev = false;
try {
  isDev = Boolean(typeof import.meta !== 'undefined' && import.meta.env && import.meta.env.DEV);
} catch (e) {
  isDev = false;
}

if ('serviceWorker' in navigator && isDev) {
  navigator.serviceWorker.getRegistrations().then((registrations) => {
    registrations.forEach((registration) => {
      registration.unregister();
    });
  });
}

const root = createRoot(rootElement);
root.render(isDev ? <App /> : (
  <React.StrictMode>
    <App />
  </React.StrictMode>
));
