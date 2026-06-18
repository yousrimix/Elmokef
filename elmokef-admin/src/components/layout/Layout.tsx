import { Outlet } from 'react-router-dom';
import { Box, AppBar, Toolbar, Typography, IconButton } from '@mui/material';
import LogoutIcon from '@mui/icons-material/Logout';
import Sidebar from './Sidebar';

export default function Layout() {
  const handleLogout = () => {
    localStorage.removeItem('token');
    window.location.href = '/login';
  };

  return (
    <Box sx={{ display: 'flex' }}>
      <Sidebar />
      <Box sx={{ flexGrow: 1 }}>
        <AppBar position="sticky" sx={{ bgcolor: '#fff', color: '#333', boxShadow: 'none', borderBottom: '1px solid #e5e7eb' }}>
          <Toolbar>
            <Typography variant="h6" sx={{ flexGrow: 1, fontFamily: '"Noto Naskh Arabic", serif' }}>
              لوحة تحكم الميقف
            </Typography>
            <IconButton onClick={handleLogout}>
              <LogoutIcon />
            </IconButton>
          </Toolbar>
        </AppBar>
        <Box sx={{ p: 3 }}>
          <Outlet />
        </Box>
      </Box>
    </Box>
  );
}
