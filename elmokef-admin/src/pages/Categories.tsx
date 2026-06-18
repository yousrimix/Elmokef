import { useState, useEffect } from 'react';
import {
  Box, Typography, Button, Card, CardContent, CardActions,
  Grid, Dialog, DialogTitle, DialogContent, DialogActions,
  TextField, IconButton, Snackbar, Skeleton, Alert,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import { getCategories, createCategory, updateCategory, deleteCategory } from '../api/endpoints/categories';

interface Category {
  id: number; name: string; icon: string; serviceCount: number;
}

export default function Categories() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [dialog, setDialog] = useState<{ open: boolean; mode: 'add' | 'edit' | 'delete'; cat?: Category }>({ open: false, mode: 'add' });
  const [form, setForm] = useState({ name: '', icon: '' });
  const [snackbar, setSnackbar] = useState('');

  const fetchCategories = async () => {
    setLoading(true);
    setError(false);
    try {
      const res = await getCategories();
      setCategories(res.data.categories || res.data.data || res.data || []);
    } catch {
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchCategories(); }, []);

  const handleSave = async () => {
    try {
      if (dialog.mode === 'add') {
        await createCategory(form);
        setSnackbar(`تمت إضافة الفئة "${form.name}"`);
      } else if (dialog.mode === 'edit' && dialog.cat) {
        await updateCategory(dialog.cat.id, form);
        setSnackbar(`تم تعديل الفئة "${form.name}"`);
      }
      fetchCategories();
    } catch {
      setSnackbar('فشلت العملية');
    }
    setDialog({ open: false, mode: 'add' });
  };

  const handleDelete = async () => {
    if (!dialog.cat) return;
    try {
      await deleteCategory(dialog.cat.id);
      setSnackbar(`تم حذف الفئة "${dialog.cat.name}"`);
      fetchCategories();
    } catch {
      setSnackbar('فشل الحذف');
    }
    setDialog({ open: false, mode: 'add' });
  };

  const openDialog = (mode: 'add' | 'edit' | 'delete', cat?: Category) => {
    setDialog({ open: true, mode, cat });
    setForm(cat ? { name: cat.name, icon: cat.icon } : { name: '', icon: '' });
  };

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4">إدارة الفئات</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => openDialog('add')}>إضافة فئة</Button>
      </Box>
      {loading ? (
        <Grid container spacing={2}>
          {[1, 2, 3, 4].map(i => <Grid size={{ xs: 12, sm: 6, md: 3 }} key={i}><Skeleton variant="rounded" height={150} /></Grid>)}
        </Grid>
      ) : error ? (
        <Alert severity="error">فشل تحميل الفئات</Alert>
      ) : (
        <Grid container spacing={2}>
          {categories.map((cat) => (
            <Grid size={{ xs: 12, sm: 6, md: 3 }} key={cat.id}>
              <Card>
                <CardContent>
                  <Typography variant="h3" sx={{ textAlign: 'center', mb: 1 }}>{cat.icon}</Typography>
                  <Typography variant="h6" sx={{ textAlign: 'center' }}>{cat.name}</Typography>
                  <Typography variant="body2" color="text.secondary" sx={{ textAlign: 'center' }}>{cat.serviceCount} خدمة</Typography>
                </CardContent>
                <CardActions sx={{ justifyContent: 'center' }}>
                  <IconButton size="small" color="primary" onClick={() => openDialog('edit', cat)}><EditIcon /></IconButton>
                  <IconButton size="small" color="error" onClick={() => openDialog('delete', cat)}><DeleteIcon /></IconButton>
                </CardActions>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}

      <Dialog open={dialog.open && dialog.mode !== 'delete'}>
        <DialogTitle>{dialog.mode === 'add' ? 'إضافة فئة جديدة' : 'تعديل الفئة'}</DialogTitle>
        <DialogContent>
          <TextField fullWidth label="اسم الفئة" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} sx={{ mt: 2, mb: 2 }} />
          <TextField fullWidth label="الأيقونة (رمز)" value={form.icon} onChange={(e) => setForm({ ...form, icon: e.target.value })} placeholder="🔧" />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialog({ open: false, mode: 'add' })}>إلغاء</Button>
          <Button variant="contained" onClick={handleSave}>حفظ</Button>
        </DialogActions>
      </Dialog>

      <Dialog open={dialog.open && dialog.mode === 'delete'}>
        <DialogTitle>حذف الفئة</DialogTitle>
        <DialogContent>
          <Typography>هل أنت متأكد من حذف "{dialog.cat?.name}"؟</Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialog({ open: false, mode: 'add' })}>إلغاء</Button>
          <Button variant="contained" color="error" onClick={handleDelete}>حذف</Button>
        </DialogActions>
      </Dialog>

      <Snackbar open={!!snackbar} autoHideDuration={3000} onClose={() => setSnackbar('')} message={snackbar} />
    </Box>
  );
}
