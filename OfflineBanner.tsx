import React, { useState, useEffect } from 'react';
import { WifiOff } from 'lucide-react';

export const OfflineBanner: React.FC = () => {
  const [isOffline, setIsOffline] = useState(!navigator.onLine);

  useEffect(() => {
    const handleOnline = () => setIsOffline(false);
    const handleOffline = () => setIsOffline(true);
    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  if (!isOffline) return null;

  return (
    <div className="bg-red-600 text-white text-xs font-bold p-3 text-center flex items-center justify-center gap-2 fixed top-0 w-full z-50 shadow-md">
      <WifiOff size={16} />
      <span>Offline Mode: Displaying cached data</span>
    </div>
  );
};
