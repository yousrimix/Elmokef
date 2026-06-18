import { ThemeProvider } from '@mui/material/styles';
import { CacheProvider } from '@emotion/react';
import CssBaseline from '@mui/material/CssBaseline';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import createCache from '@emotion/cache';
import { rtlCache } from './theme/rtl';
import theme from './theme/theme';
import Layout from './components/layout/Layout';
import AdminRoute from './components/guards/AdminRoute';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import Artisans from './pages/Artisans';
import Categories from './pages/Categories';
import Subscriptions from './pages/Subscriptions';
import Complaints from './pages/Complaints';
import Reviews from './pages/Reviews';
import Notifications from './pages/Notifications';

const cache = createCache(rtlCache);

export default function App() {
  return (
    <CacheProvider value={cache}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <BrowserRouter>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route element={<AdminRoute />}>
              <Route element={<Layout />}>
                <Route path="/" element={<Dashboard />} />
                <Route path="/users" element={<Users />} />
                <Route path="/artisans" element={<Artisans />} />
                <Route path="/categories" element={<Categories />} />
                <Route path="/subscriptions" element={<Subscriptions />} />
                <Route path="/complaints" element={<Complaints />} />
                <Route path="/reviews" element={<Reviews />} />
                <Route path="/notifications" element={<Notifications />} />
              </Route>
            </Route>
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </BrowserRouter>
      </ThemeProvider>
    </CacheProvider>
  );
}
