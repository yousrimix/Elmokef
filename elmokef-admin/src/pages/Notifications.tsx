import { useState } from 'react';
import {
  Box, Typography, TextField, Button, Paper, Snackbar, MenuItem,
} from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import { sendNotification } from '../api/endpoints/auth';

export default function Notifications() {
  const [form, setForm] = useState({ title: '', body: '', target: 'all' });
  const [sending, setSending] = useState(false);
  const [snackbar, setSnackbar] = useState('');

  const handleSend = async () => {
    setSending(true);
    try {
      await sendNotification(form);
      setSnackbar('تم إرسال الإشعار بنجاح');
      setForm({ title: '', body: '', target: 'all' });
    } catch {
      setSnackbar('فشل إرسال الإشعار');
    } finally {
      setSending(false);
    }
  };

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>إرسال إشعار</Typography>
      <Paper sx={{ p: 3, maxWidth: 600 }}>
        <TextField select label="المستهدفون" value={form.target} onChange={(e) => setForm({ ...form, target: e.target.value })} fullWidth sx={{ mb: 2 }}>
          <MenuItem value="all">جميع المستخدمين</MenuItem>
          <MenuItem value="clients">العملاء فقط</MenuItem>
          <MenuItem value="artisans">الحرفيين فقط</MenuItem>
        </TextField>
        <TextField fullWidth label="العنوان" value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} sx={{ mb: 2 }} />
        <TextField fullWidth label="نص الإشعار" value={form.body} onChange={(e) => setForm({ ...form, body: e.target.value })} multiline rows={4} sx={{ mb: 3 }} />
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="caption" color="text.secondary">سيُرسل لجميع الأجهزة المسجلة</Typography>
          <Button variant="contained" startIcon={<SendIcon />} onClick={handleSend} disabled={!form.title || !form.body || sending}>
            {sending ? 'جارٍ الإرسال...' : 'إرسال الإشعار'}
          </Button>
        </Box>
      </Paper>
      <Snackbar open={!!snackbar} autoHideDuration={3000} onClose={() => setSnackbar('')} message={snackbar} />
    </Box>
  );
}
