import { useState, useEffect } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, TablePagination, TextField, MenuItem,
  Chip, Button, Dialog, DialogTitle, DialogContent, DialogActions,
  Rating, Snackbar, Skeleton, Alert,
} from '@mui/material';
import { getReviews, moderateReview } from '../api/endpoints/reviews';

export default function Reviews() {
  const [reviews, setReviews] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [statusFilter, setStatusFilter] = useState('');
  const [dialog, setDialog] = useState<{ open: boolean; review?: any; action?: string }>({ open: false });
  const [rejectReason, setRejectReason] = useState('');
  const [snackbar, setSnackbar] = useState('');

  const fetchReviews = async () => {
    setLoading(true);
    setError(false);
    try {
      const res = await getReviews(page + 1, rowsPerPage, statusFilter);
      setReviews(res.data.reviews || res.data.data || []);
      setTotal(res.data.total || res.data.count || 0);
    } catch {
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchReviews(); }, [page, rowsPerPage, statusFilter]);

  const handleModerate = async () => {
    if (!dialog.review) return;
    try {
      const newStatus = dialog.action === 'approve' ? 'APPROVED' : 'REJECTED';
      await moderateReview(dialog.review.id, newStatus, rejectReason);
      setSnackbar(dialog.action === 'approve' ? 'تم قبول التقييم' : 'تم رفض التقييم');
      fetchReviews();
    } catch {
      setSnackbar('فشلت العملية');
    }
    setDialog({ open: false });
    setRejectReason('');
  };

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>مراجعة التقييمات</Typography>
      <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
        <TextField select label="الحالة" value={statusFilter} onChange={(e) => { setStatusFilter(e.target.value); setPage(0); }} size="small" sx={{ minWidth: 150 }}>
          <MenuItem value="">الكل</MenuItem>
          <MenuItem value="PENDING">معلّق</MenuItem>
          <MenuItem value="APPROVED">مقبول</MenuItem>
          <MenuItem value="REJECTED">مرفوض</MenuItem>
        </TextField>
      </Box>
      {error ? (
        <Alert severity="error">فشل تحميل البيانات</Alert>
      ) : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f5f5f5' }}>
                <TableCell>المقيّم</TableCell><TableCell>الحرفي</TableCell>
                <TableCell>التقييم</TableCell><TableCell>النص</TableCell>
                <TableCell>الحالة</TableCell><TableCell>التاريخ</TableCell><TableCell>إجراءات</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableRow><TableCell colSpan={7} sx={{ py: 4 }}><Skeleton /></TableCell></TableRow>
              ) : reviews.length === 0 ? (
                <TableRow><TableCell colSpan={7} align="center" sx={{ py: 6, color: 'text.secondary' }}>لا توجد بيانات</TableCell></TableRow>
              ) : (
                reviews.map((r: any) => (
                  <TableRow key={r.id} hover>
                    <TableCell>{r.client || r.reviewer}</TableCell>
                    <TableCell>{r.artisan}</TableCell>
                    <TableCell><Rating value={r.rating} readOnly size="small" /></TableCell>
                    <TableCell sx={{ maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{r.text}</TableCell>
                    <TableCell>
                      <Chip label={r.status === 'PENDING' ? 'معلّق' : r.status === 'APPROVED' ? 'مقبول' : 'مرفوض'}
                        color={r.status === 'PENDING' ? 'warning' : r.status === 'APPROVED' ? 'success' : 'error'} size="small" />
                    </TableCell>
                    <TableCell>{r.date || r.createdAt}</TableCell>
                    <TableCell>
                      {r.status === 'PENDING' && (
                        <Box sx={{ display: 'flex', gap: 1 }}>
                          <Button size="small" color="success" variant="contained"
                            onClick={() => setDialog({ open: true, review: r, action: 'approve' })}>قبول</Button>
                          <Button size="small" color="error" variant="contained"
                            onClick={() => setDialog({ open: true, review: r, action: 'reject' })}>رفض</Button>
                        </Box>
                      )}
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
        <DialogTitle>{dialog.action === 'approve' ? 'قبول التقييم' : 'رفض التقييم'}</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ mb: 2 }}>
            {dialog.review?.client || dialog.review?.reviewer} ← {dialog.review?.artisan} — <Rating value={dialog.review?.rating || 0} readOnly size="small" />
          </Typography>
          <Typography variant="body2" sx={{ mb: 2, fontStyle: 'italic', color: '#666' }}>"{dialog.review?.text}"</Typography>
          {dialog.action === 'reject' && (
            <TextField fullWidth label="سبب الرفض" value={rejectReason} onChange={(e) => setRejectReason(e.target.value)} multiline rows={2} />
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialog({ open: false })}>إلغاء</Button>
          <Button variant="contained" color={dialog.action === 'approve' ? 'success' : 'error'} onClick={handleModerate}>
            {dialog.action === 'approve' ? 'تأكيد القبول' : 'تأكيد الرفض'}
          </Button>
        </DialogActions>
      </Dialog>

      <Snackbar open={!!snackbar} autoHideDuration={3000} onClose={() => setSnackbar('')} message={snackbar} />
    </Box>
  );
}
