import { useState, useEffect } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, TablePagination, TextField, MenuItem,
  Chip, Button, Dialog, DialogTitle, DialogContent, DialogActions,
  Rating, Snackbar, Skeleton, Alert,
} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CancelIcon from '@mui/icons-material/Cancel';
import { getArtisans, verifyArtisan } from '../api/endpoints/artisans';

export default function Artisans() {
  const [artisans, setArtisans] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [verificationFilter, setVerificationFilter] = useState('');
  const [search, setSearch] = useState('');
  const [dialog, setDialog] = useState<{ open: boolean; artisan: any; action: string }>({ open: false, artisan: null, action: '' });
  const [reason, setReason] = useState('');
  const [snackbar, setSnackbar] = useState('');

  const fetchArtisans = async () => {
    setLoading(true);
    setError(false);
    try {
      const res = await getArtisans(page + 1, rowsPerPage, verificationFilter, search);
      setArtisans(res.data.artisans || res.data.data || []);
      setTotal(res.data.total || res.data.count || 0);
    } catch {
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchArtisans(); }, [page, rowsPerPage, verificationFilter, search]);

  const handleVerify = async (artisan: any, action: string) => {
    setDialog({ open: true, artisan, action });
    setReason('');
  };

  const confirmAction = async () => {
    if (!dialog.artisan) return;
    try {
      const status = dialog.action === 'accept' ? 'مقبول' : 'مرفوض';
      await verifyArtisan(dialog.artisan.id, status, reason);
      setSnackbar(`تم ${dialog.action === 'accept' ? 'توثيق' : 'رفض'} ${dialog.artisan.name}`);
      fetchArtisans();
    } catch {
      setSnackbar('فشل العملية');
    }
    setDialog({ open: false, artisan: null, action: '' });
    setReason('');
  };

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>إدارة الحرفيين</Typography>
      <Box sx={{ display: 'flex', gap: 2, mb: 3, flexWrap: 'wrap' }}>
        <TextField label="بحث" value={search} onChange={(e) => { setSearch(e.target.value); setPage(0); }} size="small" sx={{ minWidth: 250 }} />
        <TextField select label="حالة التوثيق" value={verificationFilter} onChange={(e) => { setVerificationFilter(e.target.value); setPage(0); }} size="small" sx={{ minWidth: 150 }}>
          <MenuItem value="">الكل</MenuItem>
          <MenuItem value="مقبول">مقبول</MenuItem>
          <MenuItem value="معلّق">معلّق</MenuItem>
          <MenuItem value="مرفوض">مرفوض</MenuItem>
        </TextField>
      </Box>
      {error ? (
        <Alert severity="error">فشل تحميل البيانات</Alert>
      ) : (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow sx={{ bgcolor: '#f5f5f5' }}>
                <TableCell>الاسم</TableCell><TableCell>المهنة</TableCell><TableCell>التقييم</TableCell>
                <TableCell>التوثيق</TableCell><TableCell>الاشتراك</TableCell><TableCell>تاريخ التسجيل</TableCell><TableCell>إجراءات</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableRow><TableCell colSpan={7} sx={{ py: 4 }}><Skeleton /></TableCell></TableRow>
              ) : artisans.length === 0 ? (
                <TableRow><TableCell colSpan={7} align="center" sx={{ py: 6, color: 'text.secondary' }}>لا توجد بيانات</TableCell></TableRow>
              ) : (
                artisans.map((a: any) => (
                  <TableRow key={a.id} hover>
                    <TableCell>{a.name}</TableCell>
                    <TableCell>{a.profession}</TableCell>
                    <TableCell><Rating value={a.rating} readOnly size="small" /> {a.rating}</TableCell>
                    <TableCell><Chip label={a.verified || a.verification} size="small"
                      color={(a.verified === 'مقبول' || a.verification === 'مقبول') ? 'success' : (a.verified === 'معلّق' || a.verification === 'معلّق') ? 'warning' : 'error'} /></TableCell>
                    <TableCell><Chip label={a.subscription} size="small" variant="outlined" /></TableCell>
                    <TableCell>{a.registered || a.createdAt}</TableCell>
                    <TableCell>
                      <Box sx={{ display: 'flex', gap: 1 }}>
                        <Button size="small" variant="contained" color="success" startIcon={<CheckCircleIcon />}
                          onClick={() => handleVerify(a, 'accept')} disabled={(a.verified || a.verification) !== 'معلّق'}>توثيق</Button>
                        <Button size="small" variant="contained" color="error" startIcon={<CancelIcon />}
                          onClick={() => handleVerify(a, 'reject')} disabled={(a.verified || a.verification) !== 'معلّق'}>رفض</Button>
                      </Box>
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

      <Dialog open={dialog.open} onClose={() => setDialog({ open: false, artisan: null, action: '' })}>
        <DialogTitle>{dialog.action === 'accept' ? 'توثيق الحرفي' : 'رفض التوثيق'}</DialogTitle>
        <DialogContent>
          {dialog.action === 'reject' && (
            <TextField fullWidth label="سبب الرفض" value={reason} onChange={(e) => setReason(e.target.value)} multiline rows={3} sx={{ mt: 2 }} />
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialog({ open: false, artisan: null, action: '' })}>إلغاء</Button>
          <Button variant="contained" color={dialog.action === 'accept' ? 'success' : 'error'} onClick={confirmAction}>
            {dialog.action === 'accept' ? 'تأكيد التوثيق' : 'تأكيد الرفض'}
          </Button>
        </DialogActions>
      </Dialog>

      <Snackbar open={!!snackbar} autoHideDuration={3000} onClose={() => setSnackbar('')} message={snackbar} />
    </Box>
  );
}
