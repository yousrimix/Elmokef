import { useState, useEffect } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, TablePagination, TextField, MenuItem,
  Chip, Button, Dialog, DialogTitle, DialogContent, DialogActions,
  Snackbar, Skeleton, Alert,
} from '@mui/material';
import { getComplaints, updateComplaintStatus } from '../api/endpoints/complaints';

const statusMeta: Record<string, { label: string; color: 'warning' | 'info' | 'success' | 'error' }> = {
  OPEN: { label: 'مفتوحة', color: 'warning' },
  IN_PROGRESS: { label: 'قيد المعالجة', color: 'info' },
  RESOLVED: { label: 'حُلّت', color: 'success' },
  REJECTED: { label: 'مرفوضة', color: 'error' },
};

export default function Complaints() {
  const [complaints, setComplaints] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [statusFilter, setStatusFilter] = useState('');
  const [dialog, setDialog] = useState<{ open: boolean; complaint?: any }>({ open: false });
  const [snackbar, setSnackbar] = useState('');

  const fetchComplaints = async () => {
    setLoading(true);
    setError(false);
    try {
      const res = await getComplaints(page + 1, rowsPerPage, statusFilter);
      setComplaints(res.data.complaints || res.data.data || []);
      setTotal(res.data.total || res.data.count || 0);
    } catch {
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchComplaints(); }, [page, rowsPerPage, statusFilter]);

  const handleStatusChange = async (newStatus: string) => {
    if (!dialog.complaint) return;
    try {
      await updateComplaintStatus(dialog.complaint.id, newStatus);
      setSnackbar(`تم تحديث حالة الشكوى إلى ${statusMeta[newStatus]?.label || newStatus}`);
      fetchComplaints();
    } catch {
      setSnackbar('فشل التحديث');
    }
    setDialog({ open: false });
  };

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>إدارة الشكايات</Typography>
      <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
        <TextField select label="الحالة" value={statusFilter} onChange={(e) => { setStatusFilter(e.target.value); setPage(0); }} size="small" sx={{ minWidth: 150 }}>
          <MenuItem value="">الكل</MenuItem>
          {Object.entries(statusMeta).map(([k, v]) => <MenuItem key={k} value={k}>{v.label}</MenuItem>)}
        </TextField>
      </Box>
      {error ? (
        <Alert severity="error">فشل تحميل البيانات</Alert>
      ) : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f5f5f5' }}>
                <TableCell>العميل</TableCell><TableCell>الحرفي</TableCell><TableCell>السبب</TableCell>
                <TableCell>الحالة</TableCell><TableCell>التاريخ</TableCell><TableCell>إجراءات</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableRow><TableCell colSpan={6} sx={{ py: 4 }}><Skeleton /></TableCell></TableRow>
              ) : complaints.length === 0 ? (
                <TableRow><TableCell colSpan={6} align="center" sx={{ py: 6, color: 'text.secondary' }}>لا توجد بيانات</TableCell></TableRow>
              ) : (
                complaints.map((c: any) => (
                  <TableRow key={c.id} hover>
                    <TableCell>{c.client}</TableCell>
                    <TableCell>{c.artisan}</TableCell>
                    <TableCell>{c.reason}</TableCell>
                    <TableCell><Chip label={statusMeta[c.status]?.label || c.status} color={statusMeta[c.status]?.color || 'default'} size="small" /></TableCell>
                    <TableCell>{c.date || c.createdAt}</TableCell>
                    <TableCell>
                      <Button size="small" variant="outlined" onClick={() => setDialog({ open: true, complaint: c })}>تغيير الحالة</Button>
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
        <DialogTitle>تحديث حالة الشكوى</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ mb: 2 }}>{dialog.complaint?.client} ← {dialog.complaint?.artisan} — {dialog.complaint?.reason}</Typography>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            {Object.entries(statusMeta).map(([k, v]) => (
              <Button key={k} variant={dialog.complaint?.status === k ? 'contained' : 'outlined'}
                color={v.color} onClick={() => handleStatusChange(k)}>{v.label}</Button>
            ))}
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialog({ open: false })}>إلغاء</Button>
        </DialogActions>
      </Dialog>

      <Snackbar open={!!snackbar} autoHideDuration={3000} onClose={() => setSnackbar('')} message={snackbar} />
    </Box>
  );
}
