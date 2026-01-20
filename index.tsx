import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';

const rootElement = document.getElementById('root');
if (!rootElement) throw new Error("Root element not found");

const isDev = Boolean((import.meta as any)?.env?.DEV);

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
