import React, { useEffect, useMemo, useRef, useState } from 'react';
import { api } from './api';
import { useAuth } from './AuthContext';
import { AccountInfo, Trade, Promotion } from './types';
import { LogOut, Phone, RefreshCw, TrendingUp, TrendingDown } from 'lucide-react';
import { OfflineBanner } from './OfflineBanner';

export const DashboardPage: React.FC = () => {
  const { user, logout } = useAuth();
  const [account, setAccount] = useState<AccountInfo | null>(null);
  const [phoneLast4, setPhoneLast4] = useState('');
  const [trades, setTrades] = useState<Trade[]>([]);
  const [promotions, setPromotions] = useState<Promotion[]>([]);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [timeEstimate, setTimeEstimate] = useState('');
  const [timeResult, setTimeResult] = useState('');
  const timingLoadedRef = useRef(false);

  // Physics for Pull-to-Refresh
  const [startY, setStartY] = useState(0);
  const [pullDistance, setPullDistance] = useState(0);
  const [timingSavedAt, setTimingSavedAt] = useState<string | null>(null);

  const loadData = async () => {
    if (!user) return;
    try {
      const [acc, phone, trd, prm] = await Promise.all([
        api.getAccountInfo(user.token),
        api.getLastFourNumbersPhone(user.token),
        api.getTrades(user.token),
        api.getPromotions()
      ]);
      setAccount(acc);
      setPhoneLast4(phone);
      setTrades(trd);
      setPromotions(prm);
    } catch (e: any) {
      if (e.message === 'AUTH_EXPIRED') logout();
    } finally {
      setIsRefreshing(false);
      setPullDistance(0);
    }
  };

  useEffect(() => {
    loadData();
  }, [user]);
  useEffect(() => {
    try {
      const stored = localStorage.getItem('peanut_task_timing');
      if (!stored) return;
      const parsed = JSON.parse(stored) as { estimate?: string; result?: string; savedAt?: string };
      setTimeEstimate(parsed?.estimate ?? '');
      setTimeResult(parsed?.result ?? '');
      setTimingSavedAt(parsed?.savedAt ?? null);
    } catch {
      localStorage.removeItem('peanut_task_timing');
    } finally {
      timingLoadedRef.current = true;
    }
  }, []);

  useEffect(() => {
    if (!timingLoadedRef.current) return;
    const payload = {
      estimate: timeEstimate,
      result: timeResult,
      savedAt: new Date().toISOString()
    };
    localStorage.setItem('peanut_task_timing', JSON.stringify(payload));
    setTimingSavedAt(payload.savedAt);
  }, [timeEstimate, timeResult]);
  const totalProfit = useMemo(() => trades.reduce((sum, t) => sum + t.profit, 0), [trades]);

  const handleTouchStart = (e: React.TouchEvent) => {
    if (window.scrollY === 0) setStartY(e.touches[0].clientY);
  };
  const handleTouchMove = (e: React.TouchEvent) => {
    const diff = e.touches[0].clientY - startY;
    if (window.scrollY === 0 && diff > 0) setPullDistance(Math.pow(diff, 0.8));
  };
  const handleTouchEnd = () => {
    if (pullDistance > 60) {
      setIsRefreshing(true);
      loadData();
    } else setPullDistance(0);
  };

  return (
    <div
      className="min-h-screen bg-slate-50 relative pb-20 pt-10"
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      <OfflineBanner />

      <header className="bg-indigo-600 text-white p-6 pb-12 rounded-b-[2.5rem] shadow-xl relative z-10">
        <div className="flex justify-between items-start mb-6">
          <h1 className="font-bold text-lg">Peanut Trader</h1>
          <button onClick={logout}>
            <LogOut size={18} />
          </button>
        </div>
        <div className="text-center">
          <p className="text-xs uppercase">Total Balance</p>
          <div className="text-4xl font-bold my-2">
            {account ? `${account.currency} ${account.balance.toLocaleString()}` : '...'}
          </div>
          <div className="inline-flex items-center gap-2 bg-indigo-800/40 px-3 py-1 rounded-full text-xs">
            <Phone size={10} /> **-{phoneLast4}
          </div>
        </div>
      </header>

      <div
        className="absolute top-16 left-0 w-full flex justify-center pointer-events-none transition-transform"
        style={{ transform: `translateY(${Math.min(pullDistance, 80)}px)` }}
      >
        {(pullDistance > 0 || isRefreshing) && (
          <RefreshCw className={`w-6 h-6 text-indigo-600 ${isRefreshing ? 'animate-spin' : ''}`} />
        )}
      </div>

      <div className="px-5 -mt-8 relative z-20 space-y-6">
        <div className="bg-white rounded-xl shadow-md p-5 flex justify-between">
          <div>
            <p className="text-xs uppercase font-bold text-slate-400">Net Profit</p>
            <p
              className={`text-2xl font-bold ${totalProfit >= 0 ? 'text-emerald-500' : 'text-red-500'}`}
            >
              {totalProfit.toFixed(2)}
            </p>
          </div>
          <div className="text-right">
            <p className="text-xs uppercase font-bold text-slate-400">Trades</p>
            <p className="text-2xl font-bold text-slate-700">{trades.length}</p>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-slate-100 p-5 space-y-3">
          <div>
            <h3 className="font-bold text-slate-800">Task Timing</h3>
            <p className="text-xs text-slate-500">
              Record the estimated completion time before starting and the resulting time after completion.
            </p>
          </div>
          <div className="grid gap-3 sm:grid-cols-2">
            <label className="text-xs font-semibold text-slate-600 flex flex-col gap-2">
              Estimated Completion Time
              <input
                type="text"
                value={timeEstimate}
                onChange={e => setTimeEstimate(e.target.value)}
                placeholder="e.g., 6 hours"
                className="w-full rounded-md border border-slate-200 px-3 py-2 text-sm text-slate-700 focus:border-indigo-500 focus:ring-indigo-500"
              />
            </label>
            <label className="text-xs font-semibold text-slate-600 flex flex-col gap-2">
              Resulting Time
              <input
                type="text"
                value={timeResult}
                onChange={e => setTimeResult(e.target.value)}
                placeholder="e.g., 5.5 hours"
                className="w-full rounded-md border border-slate-200 px-3 py-2 text-sm text-slate-700 focus:border-indigo-500 focus:ring-indigo-500"
              />
            </label>
          </div>
          {timingSavedAt && (
            <p className="text-[11px] text-slate-400">Last saved: {new Date(timingSavedAt).toLocaleString()}</p>
          )}
        </div>

        <div>
          <h3 className="font-bold text-slate-800 mb-3 px-1">Promotions</h3>
          <div className="flex space-x-4 overflow-x-auto pb-2 scrollbar-hide">
            {promotions.map(p => (
              <div
                key={p.id}
                className="min-w-[260px] bg-gradient-to-br from-orange-500 to-rose-500 p-4 rounded-xl text-white shadow-md"
              >
                <h4 className="font-bold text-sm mb-1">{p.title}</h4>
                <div className="text-xs opacity-90" dangerouslySetInnerHTML={{ __html: p.description }} />
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-slate-100 divide-y divide-slate-50">
          {trades.map(t => (
            <div key={t.ticket} className="flex justify-between items-center p-4">
              <div className="flex items-center gap-3">
                <div
                  className={`p-2 rounded ${t.type === 'buy' ? 'bg-emerald-50 text-emerald-600' : 'bg-red-50 text-red-600'}`}
                >
                  {t.type === 'buy' ? <TrendingUp size={18} /> : <TrendingDown size={18} />}
                </div>
                <div>
                  <p className="font-bold text-slate-700 text-sm">{t.symbol}</p>
                  <p className="text-xs text-slate-400">{t.openTime.split(' ')[0]}</p>
                </div>
              </div>
              <div
                className={`font-bold text-sm ${t.profit >= 0 ? 'text-emerald-600' : 'text-red-600'}`}
              >
                {t.profit.toFixed(2)}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
