import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  direction: 'rtl',
  palette: {
    primary: { main: '#0D9488' },
    secondary: { main: '#F59E0B' },
    error: { main: '#EF4444' },
    success: { main: '#10B981' },
    warning: { main: '#FBBF24' },
  },
  typography: {
    fontFamily: '"Noto Naskh Arabic", "Poppins", sans-serif',
  },
  shape: { borderRadius: 8 },
  components: {
    MuiCard: {
      styleOverrides: {
        root: { borderRadius: 12, boxShadow: '0 1px 3px rgba(0,0,0,0.08)' },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: { borderRadius: 8, textTransform: 'none' },
      },
    },
    MuiTableRow: {
      styleOverrides: {
        root: {
          '&:nth-of-type(even)': { backgroundColor: '#f9fafb' },
          '&:hover': { backgroundColor: '#f0fdf4' },
        },
      },
    },
  },
});

export default theme;
