import { useState, useEffect } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, TablePagination, TextField, MenuItem,
  Chip, Button, Dialog, DialogTitle, DialogContent, DialogActions,
  Select, FormControl, InputLabel, Snackbar, Skeleton, Alert,
} from '@mui/material';
import { getSubscriptions, updateSubscription } from '../api/endpoints/subscriptions';

export default function Subscriptions() {
  const [subscriptions, setSubscriptions] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [planFilter, setPlanFilter] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [dialog, setDialog] = useState<{ open: boolean; sub?: any }>({ open: false });
  const [editPlan, setEditPlan] = useState('');
  const [snackbar, setSnackbar] = useState('');

  const fetchSubscriptions = async () => {
    setLoading(true);
    setError(false);
    try {
      const res = await getSubscriptions(page + 1, rowsPerPage, planFilter, statusFilter);
      setSubscriptions(res.data.subscriptions || res.data.data || []);
      setTotal(res.data.total || res.data.count || 0);
    } catch {
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchSubscriptions(); }, [page, rowsPerPage, planFilter, statusFilter]);

  const handleEdit = async () => {
    if (!dialog.sub) return;
    try {
      await updateSubscription(dialog.sub.id, { plan: editPlan });
      setSnackbar(`تم تغيير باقة ${dialog.sub.artisan} إلى ${editPlan}`);
      fetchSubscriptions();
    } catch {
      setSnackbar('فشل التعديل');
    }
    setDialog({ open: false });
  };

  const statusColor = (s: string) => s === 'Active' ? 'success' : s === 'Cancelled' ? 'error' : 'default';
  const planColor = (p: string) => p === 'Premium' ? 'warning' : p === 'Pro' ? 'info' : 'default';

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>إدارة الاشتراكات</Typography>
      <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
        <TextField select label="الباقة" value={planFilter} onChange={(e) => { setPlanFilter(e.target.value); setPage(0); }} size="small" sx={{ minWidth: 150 }}>
          <MenuItem value="">الكل</MenuItem>
          <MenuItem value="Free">Free</MenuItem>
          <MenuItem value="Pro">Pro</MenuItem>
          <MenuItem value="Premium">Premium</MenuItem>
        </TextField>
        <TextField select label="الحالة" value={statusFilter} onChange={(e) => { setStatusFilter(e.target.value); setPage(0); }} size="small" sx={{ minWidth: 150 }}>
          <MenuItem value="">الكل</MenuItem>
          <MenuItem value="Active">نشط</MenuItem>
          <MenuItem value="Cancelled">ملغي</MenuItem>
          <MenuItem value="Expired">منتهي</MenuItem>
        </TextField>
      </Box>
      {error ? (
        <Alert severity="error">فشل تحميل البيانات</Alert>
      ) : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f5f5f5' }}>
                <TableCell>الحرفي</TableCell><TableCell>الباقة</TableCell><TableCell>الحالة</TableCell>
                <TableCell>تاريخ البدء</TableCell><TableCell>تاريخ الانتهاء</TableCell><TableCell>إجراءات</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableRow><TableCell colSpan={6} sx={{ py: 4 }}><Skeleton /></TableCell></TableRow>
              ) : subscriptions.length === 0 ? (
                <TableRow><TableCell colSpan={6} align="center" sx={{ py: 6, color: 'text.secondary' }}>لا توجد بيانات</TableCell></TableRow>
              ) : (
                subscriptions.map((s: any) => (
                  <TableRow key={s.id} hover>
                    <TableCell>{s.artisan}</TableCell>
                    <TableCell><Chip label={s.plan} variant="outlined" color={planColor(s.plan) as any} /></TableCell>
                    <TableCell><Chip label={s.status === 'Active' ? 'نشط' : s.status === 'Cancelled' ? 'ملغي' : 'منتهي'} color={statusColor(s.status) as any} size="small" /></TableCell>
                    <TableCell>{s.startDate || s.start}</TableCell>
                    <TableCell>{s.endDate || s.end}</TableCell>
                    <TableCell>
                      <Button size="small" variant="outlined" onClick={() => { setDialog({ open: true, sub: s }); setEditPlan(s.plan); }}>تعديل</Button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
          <TablePagination component="div" count={total} page={page} onPageChange={(_, p) => setPage(p)}
            rowsPerPage={rowsPerPage} onRowsPerPageChange={(e) => { setRowsPerPage(parseInt(e.target.value, 10)); setPage(0); }}
            labelRowsPerPage="عدد الصفوف" />
        </TableContainer>
      )}

      <Dialog open={dialog.open} onClose={() => setDialog({ open: false })}>
        <DialogTitle>تعديل الاشتراك</DialogTitle>
        <DialogContent sx={{ minWidth: 350 }}>
          <Typography sx={{ mb: 2 }}>{dialog.sub?.artisan}</Typography>
          <FormControl fullWidth>
            <InputLabel>الباقة</InputLabel>
            <Select value={editPlan} label="الباقة" onChange={(e) => setEditPlan(e.target.value)}>
              <MenuItem value="Free">Free</MenuItem>
              <MenuItem value="Pro">Pro</MenuItem>
              <MenuItem value="Premium">Premium</MenuItem>
            </Select>
          </FormControl>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialog({ open: false })}>إلغاء</Button>
          <Button variant="contained" onClick={handleEdit}>حفظ</Button>
        </DialogActions>
      </Dialog>

      <Snackbar open={!!snackbar} autoHideDuration={3000} onClose={() => setSnackbar('')} message={snackbar} />
    </Box>
  );
}
