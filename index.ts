export interface User {
  login: string;
  token: string;
}

export interface AccountInfo {
  address: string;
  balance: number;
  currency: string;
  city: string;
  country: string;
  zipCode: string;
  // Requirement 2: User phone data
  phone: string; 
}

export interface Trade {
  ticket: number;
  symbol: string;
  profit: number;
  type: 'buy' | 'sell';
  openTime: string;
}

export interface Promotion {
  id: string;
  title: string;
  description: string;
  link: string;
}
