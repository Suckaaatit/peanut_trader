import React, { useState } from 'react';
import { api } from '../services/api';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import { User, Lock, AlertCircle, Loader2 } from 'lucide-react';
import { OfflineBanner } from '../components/OfflineBanner';

export const LoginPage: React.FC = () => {
  const [loginId, setLoginId] = useState('2088888');
  const [password, setPassword] = useState('ral11lod');
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setIsSubmitting(true);

    try {
      const user = await api.login(loginId, password);
      login(user);
      navigate('/');
    } catch (err: any) {
      setError(err.message || 'Login failed.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
      <OfflineBanner />
      <div className="bg-white p-8 rounded-xl shadow-xl w-full max-w-md border border-gray-100">
        <div className="text-center mb-8">
          <div className="w-16 h-16 bg-indigo-100 rounded-full flex items-center justify-center mx-auto mb-4 text-3xl">🥜</div>
          <h2 className="text-3xl font-extrabold text-gray-900">Welcome Back</h2>
          <p className="mt-2 text-sm text-gray-600">Peanut Trader Client</p>
        </div>

        {error && (
          <div className="mb-4 bg-red-50 p-3 rounded-md flex items-center gap-2 text-sm text-red-700">
            <AlertCircle size={16} /> {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="relative">
            <User className="absolute left-3 top-3 text-gray-400" size={20} />
            <input
              type="text"
              value={loginId}
              onChange={e => setLoginId(e.target.value)}
              className="pl-10 w-full py-2 border rounded-md focus:ring-indigo-500 focus:border-indigo-500"
            />
          </div>
          <div className="relative">
            <Lock className="absolute left-3 top-3 text-gray-400" size={20} />
            <input
              type="password"
              value={password}
              onChange={e => setPassword(e.target.value)}
              className="pl-10 w-full py-2 border rounded-md focus:ring-indigo-500 focus:border-indigo-500"
            />
          </div>
          <button
            type="submit"
            disabled={isSubmitting}
            className="w-full bg-indigo-600 text-white py-2 rounded-md hover:bg-indigo-700"
          >
            {isSubmitting ? <Loader2 className="animate-spin h-5 w-5 mx-auto" /> : 'Sign In'}
          </button>
        </form>
      </div>
    </div>
  );
};
