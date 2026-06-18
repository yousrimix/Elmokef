import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Box, Card, TextField, Button, Typography, Alert } from '@mui/material';
import { loginApi } from '../api/endpoints/auth';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await loginApi(email, password);
      localStorage.setItem('token', res.data.accessToken);
      navigate('/');
    } catch {
      setError('فشل تسجيل الدخول. تحقق من البريد وكلمة المرور.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box sx={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', bgcolor: '#f0fdf4' }}>
      <Card sx={{ p: 4, width: 400, maxWidth: '90%' }}>
        <Typography variant="h5" sx={{ mb: 3, textAlign: 'center', fontFamily: '"Noto Naskh Arabic", serif' }}>
          تسجيل الدخول
        </Typography>
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
        <form onSubmit={handleSubmit}>
          <TextField fullWidth label="البريد الإلكتروني" value={email} onChange={(e) => setEmail(e.target.value)} sx={{ mb: 2 }} />
          <TextField fullWidth label="كلمة المرور" type="password" value={password} onChange={(e) => setPassword(e.target.value)} sx={{ mb: 3 }} />
          <Button fullWidth type="submit" variant="contained" size="large" disabled={loading}>
            {loading ? 'جارٍ تسجيل الدخول...' : 'دخول'}
          </Button>
        </form>
      </Card>
    </Box>
  );
}
