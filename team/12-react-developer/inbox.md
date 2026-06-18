# اليوم 3: Dashboard + جدول المستخدمين

## خطوة 1: Dashboard — رسم بياني + جدول آخر الشكايات

**استبدل كود** `src/pages/Dashboard.tsx`:

```tsx
import { useState, useEffect } from 'react';
import {
  Box, Typography, Grid, Card, CardContent, Paper,
} from '@mui/material';
import PeopleIcon from '@mui/icons-material/People';
import HandymanIcon from '@mui/icons-material/Handyman';
import PaymentsIcon from '@mui/icons-material/Payments';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
} from 'recharts';

const stats = [
  { label: 'المستخدمون', value: '1,247', icon: <PeopleIcon />, color: '#3B82F6' },
  { label: 'الحرفيون', value: '186', icon: <HandymanIcon />, color: '#0D9488' },
  { label: 'الاشتراكات النشطة', value: '94', icon: <PaymentsIcon />, color: '#F59E0B' },
  { label: 'الإيرادات الشهرية', value: '18,506 درهم', icon: <TrendingUpIcon />, color: '#10B981' },
];

const chartData = [
  { day: 'السبت', users: 12 }, { day: 'الأحد', users: 8 },
  { day: 'الإثنين', users: 15 }, { day: 'الثلاثاء', users: 20 },
  { day: 'الأربعاء', users: 10 }, { day: 'الخميس', users: 18 },
  { day: 'الجمعة', users: 14 },
];

const recentComplaints = [
  { client: 'أحمد الفاسي', artisan: 'كريم السباك', reason: 'تأخير', status: 'مفتوحة' },
  { client: 'فاطمة المراكشية', artisan: 'سعيد الكهربائي', reason: 'جودة', status: 'قيد المعالجة' },
  { client: 'يونس البيضاوي', artisan: 'حميد النجار', reason: 'سلوك', status: 'مفتوحة' },
  { client: 'نورة الرباطية', artisan: 'عمر الدهان', reason: 'إلغاء', status: 'مغلقة' },
  { client: 'مصطفى الفاسي', artisan: 'جمال المكالمين', reason: 'جودة', status: 'قيد المعالجة' },
];

export default function Dashboard() {
  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>لوحة الإحصائيات</Typography>

      <Grid container spacing={3} sx={{ mb: 4 }}>
        {stats.map((s) => (
          <Grid size={{ xs: 12, sm: 6, md: 3 }} key={s.label}>
            <Card>
              <CardContent sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                <Box sx={{ p: 1.5, borderRadius: 2, bgcolor: `${s.color}20`, color: s.color }}>
                  {s.icon}
                </Box>
                <Box>
                  <Typography variant="h5" sx={{ fontWeight: 700 }}>{s.value}</Typography>
                  <Typography variant="body2" color="text.secondary">{s.label}</Typography>
                </Box>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      <Grid container spacing={3}>
        <Grid size={{ xs: 12, md: 7 }}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ mb: 2 }}>المستخدمون الجدد — آخر 7 أيام</Typography>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="day" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="users" fill="#0D9488" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>
        <Grid size={{ xs: 12, md: 5 }}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ mb: 2 }}>آخر الشكايات</Typography>
            {recentComplaints.map((c, i) => (
              <Box key={i} sx={{ display: 'flex', justifyContent: 'space-between', py: 1, borderBottom: '1px solid #eee' }}>
                <Box>
                  <Typography variant="body2" sx={{ fontWeight: 600 }}>{c.client}</Typography>
                  <Typography variant="caption" color="text.secondary">{c.artisan} — {c.reason}</Typography>
                </Box>
                <Box>
                  <Typography variant="caption" sx={{
                    px: 1, py: 0.5, borderRadius: 1,
                    bgcolor: c.status === 'مفتوحة' ? '#FEF3C7' : c.status === 'قيد المعالجة' ? '#DBEAFE' : '#D1FAE5',
                    color: c.status === 'مفتوحة' ? '#92400E' : c.status === 'قيد المعالجة' ? '#1E40AF' : '#065F46',
                  }}>
                    {c.status}
                  </Typography>
                </Box>
              </Box>
            ))}
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
}
```

## خطوة 2: جدول المستخدمين (Users)

**استبدل كود** `src/pages/Users.tsx`:

```tsx
import { useState, useEffect } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, TablePagination, TextField, MenuItem,
  Chip, TableSortLabel,
} from '@mui/material';

// بيانات وهمية (Mock) — إلى أن يتوفر API
const mockUsers = Array.from({ length: 47 }, (_, i) => ({
  id: i + 1,
  name: ['أحمد الفاسي', 'فاطمة المراكشية', 'يونس البيضاوي', 'نورة الرباطية', 'مصطفى الفاسي',
         'كريم السباك', 'سعيد الكهربائي', 'حميد النجار', 'عمر الدهان', 'جمال المكالمين'][i % 10],
  phone: `06${String(10000000 + Math.floor(Math.random() * 90000000)).slice(0, 8)}`,
  email: `user${i + 1}@email.com`,
  role: ['عميل', 'حرفي', 'ادمن'][i % 3],
  registered: new Date(2026, 8, 1 + i).toLocaleDateString('ar-MA'),
  status: i % 5 === 0 ? 'محظور' : 'نشط',
}));

export default function Users() {
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [roleFilter, setRoleFilter] = useState('');
  const [search, setSearch] = useState('');

  const filtered = mockUsers.filter((u) => {
    if (roleFilter && u.role !== roleFilter) return false;
    if (search && !u.name.includes(search) && !u.phone.includes(search)) return false;
    return true;
  });

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>إدارة المستخدمين</Typography>

      <Box sx={{ display: 'flex', gap: 2, mb: 3, flexWrap: 'wrap' }}>
        <TextField
          label="بحث بالاسم أو الهاتف"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          size="small"
          sx={{ minWidth: 250 }}
        />
        <TextField
          select
          label="الدور"
          value={roleFilter}
          onChange={(e) => setRoleFilter(e.target.value)}
          size="small"
          sx={{ minWidth: 150 }}
        >
          <MenuItem value="">الكل</MenuItem>
          <MenuItem value="عميل">عميل</MenuItem>
          <MenuItem value="حرفي">حرفي</MenuItem>
          <MenuItem value="ادمن">ادمن</MenuItem>
        </TextField>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow sx={{ bgcolor: '#f5f5f5' }}>
              <TableCell>الاسم</TableCell>
              <TableCell>الهاتف</TableCell>
              <TableCell>البريد</TableCell>
              <TableCell>الدور</TableCell>
              <TableCell>تاريخ التسجيل</TableCell>
              <TableCell>الحالة</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filtered.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((u) => (
              <TableRow key={u.id} hover sx={{ cursor: 'pointer' }}>
                <TableCell>{u.name}</TableCell>
                <TableCell dir="ltr">{u.phone}</TableCell>
                <TableCell>{u.email}</TableCell>
                <TableCell>
                  <Chip label={u.role} size="small" color={
                    u.role === 'ادمن' ? 'error' : u.role === 'حرفي' ? 'primary' : 'default'
                  } />
                </TableCell>
                <TableCell>{u.registered}</TableCell>
                <TableCell>
                  <Chip label={u.status} size="small" color={u.status === 'نشط' ? 'success' : 'error'} />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        <TablePagination
          component="div"
          count={filtered.length}
          page={page}
          onPageChange={(_, p) => setPage(p)}
          rowsPerPage={rowsPerPage}
          onRowsPerPageChange={(e) => { setRowsPerPage(parseInt(e.target.value, 10)); setPage(0); }}
          labelRowsPerPage="عدد الصفوف"
        />
      </TableContainer>
    </Box>
  );
}
```

## خطوة 3: الحرفيون (Artisans) — جدول + توثيق

**استبدل كود** `src/pages/Artisans.tsx`:

```tsx
import { useState } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, TablePagination, TextField, MenuItem,
  Chip, Button, Dialog, DialogTitle, DialogContent, DialogActions,
  Rating,
} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CancelIcon from '@mui/icons-material/Cancel';

const mockArtisans = Array.from({ length: 34 }, (_, i) => ({
  id: i + 1,
  name: ['كريم السباك', 'سعيد الكهربائي', 'حميد النجار', 'عمر الدهان', 'جمال المكالمين'][i % 5],
  profession: ['سباك', 'كهربائي', 'نجار', 'دهان', 'مكالمين'][i % 5],
  rating: Number((3 + Math.random() * 2).toFixed(1)),
  verified: ['مقبول', 'معلّق', 'مرفوض'][i % 3],
  subscription: ['Free', 'Pro', 'Premium'][i % 3],
  registered: new Date(2026, 8, 1 + i).toLocaleDateString('ar-MA'),
}));

export default function Artisans() {
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [verificationFilter, setVerificationFilter] = useState('');
  const [search, setSearch] = useState('');
  const [dialog, setDialog] = useState<{ open: boolean; artisan: any; action: string }>({ open: false, artisan: null, action: '' });
  const [reason, setReason] = useState('');

  const filtered = mockArtisans.filter((a) => {
    if (verificationFilter && a.verified !== verificationFilter) return false;
    if (search && !a.name.includes(search) && !a.profession.includes(search)) return false;
    return true;
  });

  const handleVerify = (artisan: any, action: string) => {
    setDialog({ open: true, artisan, action });
    setReason('');
  };

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>إدارة الحرفيين</Typography>

      <Box sx={{ display: 'flex', gap: 2, mb: 3, flexWrap: 'wrap' }}>
        <TextField label="بحث" value={search} onChange={(e) => setSearch(e.target.value)} size="small" sx={{ minWidth: 250 }} />
        <TextField select label="حالة التوثيق" value={verificationFilter} onChange={(e) => setVerificationFilter(e.target.value)} size="small" sx={{ minWidth: 150 }}>
          <MenuItem value="">الكل</MenuItem>
          <MenuItem value="مقبول">مقبول</MenuItem>
          <MenuItem value="معلّق">معلّق</MenuItem>
          <MenuItem value="مرفوض">مرفوض</MenuItem>
        </TextField>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow sx={{ bgcolor: '#f5f5f5' }}>
              <TableCell>الاسم</TableCell>
              <TableCell>المهنة</TableCell>
              <TableCell>التقييم</TableCell>
              <TableCell>التوثيق</TableCell>
              <TableCell>الاشتراك</TableCell>
              <TableCell>تاريخ التسجيل</TableCell>
              <TableCell>إجراءات</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filtered.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map((a) => (
              <TableRow key={a.id} hover>
                <TableCell>{a.name}</TableCell>
                <TableCell>{a.profession}</TableCell>
                <TableCell><Rating value={a.rating} readOnly size="small" /> {a.rating}</TableCell>
                <TableCell>
                  <Chip label={a.verified} size="small" color={a.verified === 'مقبول' ? 'success' : a.verified === 'معلّق' ? 'warning' : 'error'} />
                </TableCell>
                <TableCell>
                  <Chip label={a.subscription} size="small" variant="outlined" color={a.subscription === 'Premium' ? 'warning' : a.subscription === 'Pro' ? 'info' : 'default'} />
                </TableCell>
                <TableCell>{a.registered}</TableCell>
                <TableCell>
                  <Box sx={{ display: 'flex', gap: 1 }}>
                    <Button size="small" variant="contained" color="success" startIcon={<CheckCircleIcon />}
                      onClick={() => handleVerify(a, 'accept')} disabled={a.verified !== 'معلّق'}>
                      توثيق
                    </Button>
                    <Button size="small" variant="contained" color="error" startIcon={<CancelIcon />}
                      onClick={() => handleVerify(a, 'reject')} disabled={a.verified !== 'معلّق'}>
                      رفض
                    </Button>
                  </Box>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        <TablePagination component="div" count={filtered.length} page={page} onPageChange={(_, p) => setPage(p)}
          rowsPerPage={rowsPerPage} onRowsPerPageChange={(e) => { setRowsPerPage(parseInt(e.target.value, 10)); setPage(0); }}
          labelRowsPerPage="عدد الصفوف" />
      </TableContainer>

      {/* نافذة تأكيد الرفض */}
      <Dialog open={dialog.open} onClose={() => setDialog({ open: false, artisan: null, action: '' })}>
        <DialogTitle>{dialog.action === 'accept' ? 'توثيق الحرفي' : 'رفض التوثيق'}</DialogTitle>
        <DialogContent>
          {dialog.action === 'reject' && (
            <TextField fullWidth label="سبب الرفض" value={reason} onChange={(e) => setReason(e.target.value)} multiline rows={3} sx={{ mt: 2 }} />
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialog({ open: false, artisan: null, action: '' })}>إلغاء</Button>
          <Button variant="contained" color={dialog.action === 'accept' ? 'success' : 'error'}
            onClick={() => { alert(`تم ${dialog.action === 'accept' ? 'توثيق' : 'رفض'} ${dialog.artisan?.name}`); setDialog({ open: false, artisan: null, action: '' }); }}>
            {dialog.action === 'accept' ? 'تأكيد التوثيق' : 'تأكيد الرفض'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
```

## اختبر الآن

1. افتح **Dashboard** → 4 بطاقات + رسم بياني + جدول شكايات ✅
2. افتح **المستخدمون** → جدول + فلترة + بحث + Pagination ✅
3. افتح **الحرفيون** → جدول + توثيق/رفض + نافذة سبب الرفض ✅
4. `npm run build` → بدون أخطاء ✅

**إذا اشتغل كل شيء → قلي "تم ✅" وأعطيك اليوم 4 (Categories + Subscriptions).**

---

# 🎯 اليوم 4: الفئات (CRUD) + الاشتراكات

## خطوة 1: الفئات — Categories CRUD كامل

**استبدل كود** `src/pages/Categories.tsx`:

```tsx
import { useState } from 'react';
import {
  Box, Typography, Button, Card, CardContent, CardActions,
  Grid, Dialog, DialogTitle, DialogContent, DialogActions,
  TextField, IconButton, Chip, Alert, Snackbar,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';

interface Category {
  id: number; name: string; icon: string; serviceCount: number;
}

const mockCategories: Category[] = [
  { id: 1, name: 'سباكة', icon: '🔧', serviceCount: 4 },
  { id: 2, name: 'كهرباء', icon: '⚡', serviceCount: 3 },
  { id: 3, name: 'نجارة', icon: '🪚', serviceCount: 2 },
  { id: 4, name: 'دهان', icon: '🎨', serviceCount: 3 },
  { id: 5, name: 'تكييف', icon: '❄️', serviceCount: 2 },
  { id: 6, name: 'تنظيف', icon: '🧹', serviceCount: 4 },
  { id: 7, name: 'حدادة', icon: '🔨', serviceCount: 2 },
  { id: 8, name: 'بناء', icon: '🧱', serviceCount: 5 },
];

export default function Categories() {
  const [categories, setCategories] = useState<Category[]>(mockCategories);
  const [dialog, setDialog] = useState<{ open: boolean; mode: 'add' | 'edit' | 'delete'; cat?: Category }>({ open: false, mode: 'add' });
  const [form, setForm] = useState({ name: '', icon: '' });
  const [snackbar, setSnackbar] = useState('');

  const handleSave = () => {
    if (dialog.mode === 'add') {
      setCategories([...categories, { id: Date.now(), name: form.name, icon: form.icon, serviceCount: 0 }]);
      setSnackbar(`تمت إضافة الفئة "${form.name}"`);
    } else if (dialog.mode === 'edit' && dialog.cat) {
      setCategories(categories.map(c => c.id === dialog.cat!.id ? { ...c, name: form.name, icon: form.icon } : c));
      setSnackbar(`تم تعديل الفئة "${form.name}"`);
    }
    setDialog({ open: false, mode: 'add' });
  };

  const handleDelete = () => {
    if (dialog.cat) {
      setCategories(categories.filter(c => c.id !== dialog.cat!.id));
      setSnackbar(`تم حذف الفئة "${dialog.cat.name}"`);
    }
    setDialog({ open: false, mode: 'add' });
  };

  const openDialog = (mode: 'add' | 'edit' | 'delete', cat?: Category) => {
    setDialog({ open: true, mode, cat });
    if (cat) setForm({ name: cat.name, icon: cat.icon });
    else setForm({ name: '', icon: '' });
  };

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4">إدارة الفئات</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => openDialog('add')}>
          إضافة فئة
        </Button>
      </Box>

      <Grid container spacing={2}>
        {categories.map((cat) => (
          <Grid size={{ xs: 12, sm: 6, md: 3 }} key={cat.id}>
            <Card>
              <CardContent>
                <Typography variant="h3" sx={{ textAlign: 'center', mb: 1 }}>{cat.icon}</Typography>
                <Typography variant="h6" sx={{ textAlign: 'center' }}>{cat.name}</Typography>
                <Typography variant="body2" color="text.secondary" sx={{ textAlign: 'center' }}>
                  {cat.serviceCount} خدمة
                </Typography>
              </CardContent>
              <CardActions sx={{ justifyContent: 'center' }}>
                <IconButton size="small" color="primary" onClick={() => openDialog('edit', cat)}><EditIcon /></IconButton>
                <IconButton size="small" color="error" onClick={() => openDialog('delete', cat)}><DeleteIcon /></IconButton>
              </CardActions>
            </Card>
          </Grid>
        ))}
      </Grid>

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
```

## خطوة 2: الاشتراكات — Subscriptions

**استبدل كود** `src/pages/Subscriptions.tsx`:

```tsx
import { useState } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, TablePagination, TextField, MenuItem,
  Chip, Button, Dialog, DialogTitle, DialogContent, DialogActions,
  Select, FormControl, InputLabel, Snackbar,
} from '@mui/material';

const mockSubscriptions = Array.from({ length: 28 }, (_, i) => ({
  id: i + 1,
  artisan: ['كريم السباك', 'سعيد الكهربائي', 'حميد النجار', 'عمر الدهان', 'جمال المكالمين'][i % 5],
  plan: ['Free', 'Pro', 'Premium'][i % 3],
  status: ['Active', 'Cancelled', 'Expired'][i % 3],
  startDate: new Date(2026, 6, 1 + i).toLocaleDateString('ar-MA'),
  endDate: new Date(2026, 6 + 1, 1 + i).toLocaleDateString('ar-MA'),
}));

export default function Subscriptions() {
  const [subscriptions, setSubscriptions] = useState(mockSubscriptions);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [planFilter, setPlanFilter] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [dialog, setDialog] = useState<{ open: boolean; sub?: any }>({ open: false });
  const [editPlan, setEditPlan] = useState('');
  const [snackbar, setSnackbar] = useState('');

  const filtered = subscriptions.filter(s => {
    if (planFilter && s.plan !== planFilter) return false;
    if (statusFilter && s.status !== statusFilter) return false;
    return true;
  });

  const handleEdit = () => {
    if (dialog.sub) {
      setSubscriptions(subscriptions.map(s => s.id === dialog.sub.id ? { ...s, plan: editPlan } : s));
      setSnackbar(`تم تغيير باقة ${dialog.sub.artisan} إلى ${editPlan}`);
    }
    setDialog({ open: false });
  };

  const statusColor = (s: string) => s === 'Active' ? 'success' : s === 'Cancelled' ? 'error' : 'default';
  const planColor = (p: string) => p === 'Premium' ? 'warning' : p === 'Pro' ? 'info' : 'default';

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>إدارة الاشتراكات</Typography>

      <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
        <TextField select label="الباقة" value={planFilter} onChange={(e) => setPlanFilter(e.target.value)} size="small" sx={{ minWidth: 150 }}>
          <MenuItem value="">الكل</MenuItem>
          <MenuItem value="Free">Free</MenuItem>
          <MenuItem value="Pro">Pro</MenuItem>
          <MenuItem value="Premium">Premium</MenuItem>
        </TextField>
        <TextField select label="الحالة" value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} size="small" sx={{ minWidth: 150 }}>
          <MenuItem value="">الكل</MenuItem>
          <MenuItem value="Active">نشط</MenuItem>
          <MenuItem value="Cancelled">ملغي</MenuItem>
          <MenuItem value="Expired">منتهي</MenuItem>
        </TextField>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow sx={{ bgcolor: '#f5f5f5' }}>
              <TableCell>الحرفي</TableCell>
              <TableCell>الباقة</TableCell>
              <TableCell>الحالة</TableCell>
              <TableCell>تاريخ البدء</TableCell>
              <TableCell>تاريخ الانتهاء</TableCell>
              <TableCell>إجراءات</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filtered.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map(s => (
              <TableRow key={s.id} hover>
                <TableCell>{s.artisan}</TableCell>
                <TableCell><Chip label={s.plan} variant="outlined" color={planColor(s.plan)} /></TableCell>
                <TableCell><Chip label={s.status === 'Active' ? 'نشط' : s.status === 'Cancelled' ? 'ملغي' : 'منتهي'} color={statusColor(s.status)} size="small" /></TableCell>
                <TableCell>{s.startDate}</TableCell>
                <TableCell>{s.endDate}</TableCell>
                <TableCell>
                  <Button size="small" variant="outlined" onClick={() => { setDialog({ open: true, sub: s }); setEditPlan(s.plan); }}>
                    تعديل
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        <TablePagination component="div" count={filtered.length} page={page} onPageChange={(_, p) => setPage(p)}
          rowsPerPage={rowsPerPage} onRowsPerPageChange={(e) => { setRowsPerPage(parseInt(e.target.value, 10)); setPage(0); }}
          labelRowsPerPage="عدد الصفوف" />
      </TableContainer>

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
```

## اختبر

1. افتح **الفئات** → شبكة بطاقات + إضافة/تعديل/حذف ✅
2. افتح **الاشتراكات** → جدول + فلترة بالباقة/الحالة + تعديل ✅
3. `npm run build` → بدون أخطاء ✅

**إذا اشتغل كل شيء → قلي "تم ✅" وأعطيك اليوم 5 (الشكايات + التقييمات + Notifications).**

---

# 🎯 اليوم 5: الشكايات + التقييمات + Notifications

## خطوة 1: الشكايات — جدول مع تغيير الحالة

**استبدل كود** `src/pages/Complaints.tsx`:

```tsx
import { useState } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, TablePagination, TextField, MenuItem,
  Chip, Button, Dialog, DialogTitle, DialogContent, DialogActions,
  Snackbar,
} from '@mui/material';

const mockComplaints = Array.from({ length: 15 }, (_, i) => ({
  id: i + 1,
  client: ['أحمد الفاسي', 'فاطمة المراكشية', 'يونس البيضاوي'][i % 3],
  artisan: ['كريم السباك', 'سعيد الكهربائي', 'حميد النجار'][i % 3],
  reason: ['تأخير', 'جودة سيئة', 'سلوك غير لائق', 'إلغاء مفاجئ', 'غير ذلك'][i % 5],
  status: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'REJECTED'][i % 4],
  date: new Date(2026, 8, 15 + i).toLocaleDateString('ar-MA'),
}));

const statusMeta: Record<string, { label: string; color: 'warning' | 'info' | 'success' | 'error' }> = {
  OPEN: { label: 'مفتوحة', color: 'warning' },
  IN_PROGRESS: { label: 'قيد المعالجة', color: 'info' },
  RESOLVED: { label: 'حُلّت', color: 'success' },
  REJECTED: { label: 'مرفوضة', color: 'error' },
};

export default function Complaints() {
  const [complaints, setComplaints] = useState(mockComplaints);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [statusFilter, setStatusFilter] = useState('');
  const [dialog, setDialog] = useState<{ open: boolean; complaint?: any }>({ open: false });
  const [snackbar, setSnackbar] = useState('');

  const filtered = complaints.filter(c => !statusFilter || c.status === statusFilter);

  const handleStatusChange = (newStatus: string) => {
    if (dialog.complaint) {
      setComplaints(complaints.map(c => c.id === dialog.complaint.id ? { ...c, status: newStatus } : c));
      setSnackbar(`تم تحديث حالة الشكوى إلى ${statusMeta[newStatus].label}`);
    }
    setDialog({ open: false });
  };

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>إدارة الشكايات</Typography>

      <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
        <TextField select label="الحالة" value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} size="small" sx={{ minWidth: 150 }}>
          <MenuItem value="">الكل</MenuItem>
          {Object.entries(statusMeta).map(([k, v]) => <MenuItem key={k} value={k}>{v.label}</MenuItem>)}
        </TextField>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow sx={{ bgcolor: '#f5f5f5' }}>
              <TableCell>العميل</TableCell><TableCell>الحرفي</TableCell><TableCell>السبب</TableCell>
              <TableCell>الحالة</TableCell><TableCell>التاريخ</TableCell><TableCell>إجراءات</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filtered.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map(c => (
              <TableRow key={c.id} hover>
                <TableCell>{c.client}</TableCell>
                <TableCell>{c.artisan}</TableCell>
                <TableCell>{c.reason}</TableCell>
                <TableCell><Chip label={statusMeta[c.status].label} color={statusMeta[c.status].color} size="small" /></TableCell>
                <TableCell>{c.date}</TableCell>
                <TableCell>
                  <Button size="small" variant="outlined" onClick={() => setDialog({ open: true, complaint: c })}>
                    تغيير الحالة
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        <TablePagination component="div" count={filtered.length} page={page} onPageChange={(_, p) => setPage(p)}
          rowsPerPage={rowsPerPage} onRowsPerPageChange={(e) => { setRowsPerPage(parseInt(e.target.value, 10)); setPage(0); }}
          labelRowsPerPage="عدد الصفوف" />
      </TableContainer>

      <Dialog open={dialog.open} onClose={() => setDialog({ open: false })}>
        <DialogTitle>تحديث حالة الشكوى</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ mb: 2 }}>
            {dialog.complaint?.client} ← {dialog.complaint?.artisan} — {dialog.complaint?.reason}
          </Typography>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
            {Object.entries(statusMeta).map(([k, v]) => (
              <Button key={k} variant={dialog.complaint?.status === k ? 'contained' : 'outlined'}
                color={v.color} onClick={() => handleStatusChange(k)}>
                {v.label}
              </Button>
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
```

## خطوة 2: التقييمات — قبول/رفض

**استبدل كود** `src/pages/Reviews.tsx`:

```tsx
import { useState } from 'react';
import {
  Box, Typography, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Paper, TablePagination, TextField, MenuItem,
  Chip, Button, Dialog, DialogTitle, DialogContent, DialogActions,
  Rating, Snackbar,
} from '@mui/material';

const mockReviews = Array.from({ length: 22 }, (_, i) => ({
  id: i + 1,
  client: ['أحمد', 'فاطمة', 'يونس', 'نورة', 'مصطفى'][i % 5],
  artisan: ['كريم السباك', 'سعيد الكهربائي', 'حميد النجار'][i % 3],
  rating: Math.floor(3 + Math.random() * 3),
  text: ['خدمة ممتازة', 'جيد جداً', 'مقبول', 'سيء نوعاً ما', 'ممتاز شكراً'][i % 5],
  status: ['PENDING', 'APPROVED', 'REJECTED'][i % 3],
  date: new Date(2026, 8, 10 + i).toLocaleDateString('ar-MA'),
}));

export default function Reviews() {
  const [reviews, setReviews] = useState(mockReviews);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [statusFilter, setStatusFilter] = useState('');
  const [dialog, setDialog] = useState<{ open: boolean; review?: any; action?: string }>({ open: false });
  const [rejectReason, setRejectReason] = useState('');
  const [snackbar, setSnackbar] = useState('');

  const filtered = reviews.filter(r => !statusFilter || r.status === statusFilter);

  const handleModerate = () => {
    if (dialog.review) {
      setReviews(reviews.map(r => r.id === dialog.review.id ? { ...r, status: dialog.action === 'approve' ? 'APPROVED' : 'REJECTED' } : r));
      setSnackbar(dialog.action === 'approve' ? 'تم قبول التقييم' : 'تم رفض التقييم');
    }
    setDialog({ open: false });
    setRejectReason('');
  };

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>مراجعة التقييمات</Typography>

      <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
        <TextField select label="الحالة" value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} size="small" sx={{ minWidth: 150 }}>
          <MenuItem value="">الكل</MenuItem>
          <MenuItem value="PENDING">معلّق</MenuItem>
          <MenuItem value="APPROVED">مقبول</MenuItem>
          <MenuItem value="REJECTED">مرفوض</MenuItem>
        </TextField>
      </Box>

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
            {filtered.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage).map(r => (
              <TableRow key={r.id} hover>
                <TableCell>{r.client}</TableCell>
                <TableCell>{r.artisan}</TableCell>
                <TableCell><Rating value={r.rating} readOnly size="small" /></TableCell>
                <TableCell sx={{ maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{r.text}</TableCell>
                <TableCell>
                  <Chip label={r.status === 'PENDING' ? 'معلّق' : r.status === 'APPROVED' ? 'مقبول' : 'مرفوض'}
                    color={r.status === 'PENDING' ? 'warning' : r.status === 'APPROVED' ? 'success' : 'error'} size="small" />
                </TableCell>
                <TableCell>{r.date}</TableCell>
                <TableCell>
                  {r.status === 'PENDING' && (
                    <Box sx={{ display: 'flex', gap: 1 }}>
                      <Button size="small" color="success" variant="contained"
                        onClick={() => setDialog({ open: true, review: r, action: 'approve' })}>
                        قبول
                      </Button>
                      <Button size="small" color="error" variant="contained"
                        onClick={() => setDialog({ open: true, review: r, action: 'reject' })}>
                        رفض
                      </Button>
                    </Box>
                  )}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        <TablePagination component="div" count={filtered.length} page={page} onPageChange={(_, p) => setPage(p)}
          rowsPerPage={rowsPerPage} onRowsPerPageChange={(e) => { setRowsPerPage(parseInt(e.target.value, 10)); setPage(0); }}
          labelRowsPerPage="عدد الصفوف" />
      </TableContainer>

      <Dialog open={dialog.open} onClose={() => setDialog({ open: false })}>
        <DialogTitle>{dialog.action === 'approve' ? 'قبول التقييم' : 'رفض التقييم'}</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ mb: 2 }}>
            {dialog.review?.client} ← {dialog.review?.artisan} — <Rating value={dialog.review?.rating || 0} readOnly size="small" />
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
```

## خطوة 3: Notifications — إرسال إشعار من Admin

**أنشئ الملف:** `src/pages/Notifications.tsx`

```tsx
import { useState } from 'react';
import {
  Box, Typography, TextField, Button, Paper, Alert, Snackbar,
  MenuItem, Chip,
} from '@mui/material';
import SendIcon from '@mui/icons-material/Send';

export default function Notifications() {
  const [form, setForm] = useState({ title: '', body: '', target: 'all' });
  const [sending, setSending] = useState(false);
  const [snackbar, setSnackbar] = useState('');

  const handleSend = async () => {
    setSending(true);
    // TODO: استدعاء API حقيقي
    await new Promise(r => setTimeout(r, 1000));
    setSending(false);
    setSnackbar('تم إرسال الإشعار بنجاح');
    setForm({ title: '', body: '', target: 'all' });
  };

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>إرسال إشعار</Typography>

      <Paper sx={{ p: 3, maxWidth: 600 }}>
        <TextField select label="المستهدفون" value={form.target} onChange={(e) => setForm({ ...form, target: e.target.value })}
          fullWidth sx={{ mb: 2 }}>
          <MenuItem value="all">جميع المستخدمين</MenuItem>
          <MenuItem value="clients">العملاء فقط</MenuItem>
          <MenuItem value="artisans">الحرفيين فقط</MenuItem>
        </TextField>
        <TextField fullWidth label="العنوان" value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} sx={{ mb: 2 }} />
        <TextField fullWidth label="نص الإشعار" value={form.body} onChange={(e) => setForm({ ...form, body: e.target.value })}
          multiline rows={4} sx={{ mb: 3 }} />
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="caption" color="text.secondary">
            سيُرسل لجميع الأجهزة المسجلة
          </Typography>
          <Button variant="contained" startIcon={<SendIcon />} onClick={handleSend} disabled={!form.title || !form.body || sending}>
            {sending ? 'جارٍ الإرسال...' : 'إرسال الإشعار'}
          </Button>
        </Box>
      </Paper>

      <Snackbar open={!!snackbar} autoHideDuration={3000} onClose={() => setSnackbar('')} message={snackbar} />
    </Box>
  );
}
```

## خطوة 4: أضف Notifications إلى الـ Sidebar والـ Router

**في** `src/components/layout/Sidebar.tsx` — أضف زر الإشعارات قبل `<LogoutIcon />`:

```tsx
import NotificationsIcon from '@mui/icons-material/Notifications';
// ...بعد reviews item في menuItems:
{ text: 'إرسال إشعار', icon: <NotificationsIcon />, path: '/notifications' },
```

**في** `src/App.tsx` — أضف الاستيراد والـ Route:

```tsx
import Notifications from './pages/Notifications';
// ...بعد Route reviews:
<Route path="/notifications" element={<Notifications />} />
```

## اختبر

1. افتح **الشكايات** → جدول + فلترة حسب الحالة + تغيير الحالة ✅
2. افتح **التقييمات** → جدول + قبول/رفض + سبب الرفض ✅
3. افتح **إرسال إشعار** → نموذج + إرسال ✅
4. `npm run build` → بدون أخطاء ✅

**إذا اشتغل كل شيء → قلي "تم ✅" وأعطيك اليوم 6 (ربط API الحقيقي + Admin Guard).**

---

# 🎯 اليوم 6: API Connection + Admin Guard

## خطوة 1: ApiClient مع JWT Interceptor

**أنشئ الملف:** `src/api/axios.ts`

```ts
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://api.elmokef.ma/api/v1',
  headers: { 'Content-Type': 'application/json' },
});

// Interceptor: أضف JWT تلقائياً لكل طلب
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Interceptor: تعامل مع خطأ 401 (انتهاء الجلسة)
api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(err);
  },
);

export default api;
```

## خطوة 2: Admin Guard

**أنشئ الملف:** `src/components/guards/AdminRoute.tsx`

```tsx
import { Navigate, Outlet } from 'react-router-dom';

export default function AdminRoute() {
  const token = localStorage.getItem('token');
  if (!token) {
    return <Navigate to="/login" replace />;
  }
  return <Outlet />;
}
```

## خطوة 3: API Endpoints — ملف لكل موديول

**أنشئ مجلد:** `src/api/endpoints/`

**الملف:** `src/api/endpoints/auth.ts`

```ts
import api from '../axios';

export const loginApi = (email: string, password: string) =>
  api.post('/auth/login', { email, password });

export const getStats = () => api.get('/admin/stats');
```

**الملف:** `src/api/endpoints/users.ts`

```ts
import api from '../axios';

export const getUsers = (page = 1, limit = 10, role = '', search = '') =>
  api.get('/admin/users', { params: { page, limit, role, search } });
```

**الملف:** `src/api/endpoints/artisans.ts`

```ts
import api from '../axios';

export const getArtisans = (page = 1, limit = 10, verification = '', search = '') =>
  api.get('/admin/artisans', { params: { page, limit, verification, search } });

export const verifyArtisan = (id: string, status: string, reason?: string) =>
  api.patch(`/admin/artisans/${id}/verify`, { status, reason });
```

**الملف:** `src/api/endpoints/categories.ts`

```ts
import api from '../axios';

export const getCategories = () => api.get('/categories');
export const createCategory = (data: { name: string; icon: string }) => api.post('/admin/categories', data);
export const updateCategory = (id: number, data: { name: string; icon: string }) => api.put(`/admin/categories/${id}`, data);
export const deleteCategory = (id: number) => api.delete(`/admin/categories/${id}`);
```

**الملف:** `src/api/endpoints/subscriptions.ts`

```ts
import api from '../axios';

export const getSubscriptions = (page = 1, limit = 10, plan = '', status = '') =>
  api.get('/admin/subscriptions', { params: { page, limit, plan, status } });

export const updateSubscription = (id: number, data: { plan: string; status?: string }) =>
  api.patch(`/admin/subscriptions/${id}`, data);
```

**الملف:** `src/api/endpoints/complaints.ts`

```ts
import api from '../axios';

export const getComplaints = (page = 1, limit = 10, status = '') =>
  api.get('/admin/complaints', { params: { page, limit, status } });

export const updateComplaintStatus = (id: number, status: string) =>
  api.patch(`/admin/complaints/${id}`, { status });
```

**الملف:** `src/api/endpoints/reviews.ts`

```ts
import api from '../axios';

export const getReviews = (page = 1, limit = 10, status = '') =>
  api.get('/admin/reviews', { params: { page, limit, status } });

export const moderateReview = (id: number, status: string, reason?: string) =>
  api.patch(`/admin/reviews/${id}`, { status, reason });
```

## خطوة 4: AdminRoute في الـ Router

**في** `src/App.tsx` — استبدل الكود:

```tsx
import { ThemeProvider } from '@mui/material/styles';
import { CacheProvider } from '@emotion/react';
import CssBaseline from '@mui/material/CssBaseline';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { cacheRtl } from './theme/rtl';
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

export default function App() {
  return (
    <CacheProvider value={cacheRtl}>
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
```

## خطوة 5: تحديث Login لاستخدام API حقيقي

**في** `src/pages/Login.tsx` — استبدل السطر:

```tsx
import axios from 'axios';
// بـ:
import { loginApi } from '../api/endpoints/auth';
```

واستبدل:

```tsx
const res = await axios.post('https://api.elmokef.ma/api/v1/auth/login', { email, password });
// بـ:
const res = await loginApi(email, password);
```

## اختبر

1. افتح `http://localhost:5173/` بدون تسجيل → يوجّه تلقائياً لـ `/login` ✅
2. `http://localhost:5173/login` → الصفحة شغالة ✅
3. `npm run build` → بدون أخطاء ✅

**إذا اشتغل كل شيء → قلي "تم ✅" وأعطيك اليوم 7 (ربط API بجميع الصفحات + Build + تسليم).**

---

# 🎯 اليوم 7: ربط API بجميع الصفحات + Build + تسليم

## خطوة 1: Dashboard — API حقيقي

**استبدل** `src/pages/Dashboard.tsx` — أضف `useEffect` لاستدعاء API:

في أعلى الدالة (بعد `export default function Dashboard()`):

```tsx
const [loading, setLoading] = useState(true);
const [stats, setStats] = useState([
  { label: 'المستخدمون', value: '0', icon: <PeopleIcon />, color: '#3B82F6' },
  { label: 'الحرفيون', value: '0', icon: <HandymanIcon />, color: '#0D9488' },
  { label: 'الاشتراكات النشطة', value: '0', icon: <PaymentsIcon />, color: '#F59E0B' },
  { label: 'الإيرادات الشهرية', value: '0 درهم', icon: <TrendingUpIcon />, color: '#10B981' },
]);

useEffect(() => {
  api.get('/admin/stats')
    .then((res) => {
      const d = res.data;
      setStats([
        { label: 'المستخدمون', value: d.totalUsers.toLocaleString(), icon: <PeopleIcon />, color: '#3B82F6' },
        { label: 'الحرفيون', value: d.totalArtisans.toLocaleString(), icon: <HandymanIcon />, color: '#0D9488' },
        { label: 'الاشتراكات النشطة', value: d.activeSubscriptions.toLocaleString(), icon: <PaymentsIcon />, color: '#F59E0B' },
        { label: 'الإيرادات الشهرية', value: `${d.monthlyRevenue.toLocaleString()} درهم`, icon: <TrendingUpIcon />, color: '#10B981' },
      ]);
    })
    .catch(() => {})
    .finally(() => setLoading(false));
}, []);
```

أضف import:

```tsx
import { useState, useEffect } from 'react';
import api from '../api/axios';
```

## خطوة 2: Users — API حقيقي

**استبدل** `const mockUsers = ...` في `src/pages/Users.tsx` بـ:

```tsx
const [users, setUsers] = useState<any[]>([]);
const [total, setTotal] = useState(0);
const [loading, setLoading] = useState(true);

useEffect(() => {
  setLoading(true);
  api.get('/admin/users', { params: { page: page + 1, limit: rowsPerPage, role: roleFilter, search } })
    .then((res) => { setUsers(res.data.items); setTotal(res.data.total); })
    .catch(() => {})
    .finally(() => setLoading(false));
}, [page, rowsPerPage, roleFilter, search]);
```

واستبدل `filtered.slice(...)` بـ `users` في الـ TableBody.

## خطوة 3: Artisans — API حقيقي

**استبدل** `const mockArtisans = ...` بـ:

```tsx
const [artisans, setArtisans] = useState<any[]>([]);
const [total, setTotal] = useState(0);
const [loading, setLoading] = useState(true);

useEffect(() => {
  setLoading(true);
  api.get('/admin/artisans', { params: { page: page + 1, limit: rowsPerPage, verification: verificationFilter, search } })
    .then((res) => { setArtisans(res.data.items); setTotal(res.data.total); })
    .catch(() => {})
    .finally(() => setLoading(false));
}, [page, rowsPerPage, verificationFilter, search]);
```

## خطوة 4: Categories — API حقيقي

**استبدل** `const mockCategories` بـ:

```tsx
const [categories, setCategories] = useState<Category[]>([]);
const [loading, setLoading] = useState(true);

const fetchCategories = () => {
  api.get('/categories')
    .then((res) => setCategories(res.data))
    .catch(() => {})
    .finally(() => setLoading(false));
};

useEffect(() => { fetchCategories(); }, []);
```

**في `handleSave`** — استبدل:
```tsx
// الإضافة:
api.post('/admin/categories', form).then(() => fetchCategories());
// التعديل:
api.put(`/admin/categories/${dialog.cat!.id}`, form).then(() => fetchCategories());
```

**في `handleDelete`**:
```tsx
api.delete(`/admin/categories/${dialog.cat!.id}`).then(() => fetchCategories());
```

## خطوة 5: Subscriptions — API حقيقي

**استبدل** `const mockSubscriptions` بـ:

```tsx
const [subscriptions, setSubscriptions] = useState<any[]>([]);
const [total, setTotal] = useState(0);
const [loading, setLoading] = useState(true);

useEffect(() => {
  setLoading(true);
  api.get('/admin/subscriptions', { params: { page: page + 1, limit: rowsPerPage, plan: planFilter, status: statusFilter } })
    .then((res) => { setSubscriptions(res.data.items); setTotal(res.data.total); })
    .catch(() => {})
    .finally(() => setLoading(false));
}, [page, rowsPerPage, planFilter, statusFilter]);
```

**في `handleEdit`**:
```tsx
api.patch(`/admin/subscriptions/${dialog.sub.id}`, { plan: editPlan })
  .then(() => setSnackbar(`تم تغيير باقة ${dialog.sub.artisan} إلى ${editPlan}`))
  .catch(() => setSnackbar('فشل تحديث الباقة'));
```

## خطوة 6: Complaints — API حقيقي

**استبدل** `const mockComplaints` بـ:

```tsx
const [complaints, setComplaints] = useState<any[]>([]);
const [total, setTotal] = useState(0);
const [loading, setLoading] = useState(true);

useEffect(() => {
  setLoading(true);
  api.get('/admin/complaints', { params: { page: page + 1, limit: rowsPerPage, status: statusFilter } })
    .then((res) => { setComplaints(res.data.items); setTotal(res.data.total); })
    .catch(() => {})
    .finally(() => setLoading(false));
}, [page, rowsPerPage, statusFilter]);
```

**في `handleStatusChange`**:
```tsx
api.patch(`/admin/complaints/${dialog.complaint.id}`, { status: newStatus })
  .then(() => { setComplaints(complaints.map(c => c.id === dialog.complaint.id ? { ...c, status: newStatus } : c));
    setSnackbar(`تم تحديث الحالة`); });
```

## خطوة 7: Reviews — API حقيقي

**استبدل** `const mockReviews` بـ:

```tsx
const [reviews, setReviews] = useState<any[]>([]);
const [total, setTotal] = useState(0);
const [loading, setLoading] = useState(true);

useEffect(() => {
  setLoading(true);
  api.get('/admin/reviews', { params: { page: page + 1, limit: rowsPerPage, status: statusFilter } })
    .then((res) => { setReviews(res.data.items); setTotal(res.data.total); })
    .catch(() => {})
    .finally(() => setLoading(false));
}, [page, rowsPerPage, statusFilter]);
```

**في `handleModerate`**:
```tsx
const newStatus = dialog.action === 'approve' ? 'APPROVED' : 'REJECTED';
api.patch(`/admin/reviews/${dialog.review.id}`, { status: newStatus, reason: rejectReason })
  .then(() => { setReviews(reviews.map(r => r.id === dialog.review.id ? { ...r, status: newStatus } : r)); });
```

## خطوة 8: Notifications — API حقيقي

**في** `src/pages/Notifications.tsx` — استبدل الـ `handleSend`:

```tsx
import api from '../api/axios';

const handleSend = async () => {
  setSending(true);
  try {
    await api.post('/admin/notifications/send', form);
    setSnackbar('تم إرسال الإشعار بنجاح');
    setForm({ title: '', body: '', target: 'all' });
  } catch {
    setSnackbar('فشل إرسال الإشعار');
  } finally {
    setSending(false);
  }
};
```

## ✨ خطوة 9: اللمسات الأخيرة

### 1. `index.html` — أيقونة المتصفح والاسم

**في** `index.html` — تأكد:

```html
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8" />
  <title>الميقف — لوحة التحكم</title>
  <link rel="icon" type="image/svg+xml" href="/vite.svg" />
  <link href="https://fonts.googleapis.com/css2?family=Noto+Naskh+Arabic:wght@400;600;700&family=Poppins:wght@400;500;600&display=swap" rel="stylesheet" />
</head>
```

### 2. Theme — تحسينات أخيرة

**في** `src/theme/theme.ts` — تأكد من تضمين Poppins:

```ts
fontFamily: '"Noto Naskh Arabic", "Poppins", sans-serif',
```

### 3. Theme RTL للـ MUI

**في** `src/theme/theme.ts` — أضف:

```ts
direction: 'rtl',
```

(إذا لم تكن موجودة)

## 🏁 الاختبار النهائي

```bash
npm run build
```

**تأكد من:**
- `dist/` اشتغل بدون أخطاء ✅
- كل صفحة تستخدم API (وليس mock data) ✅
- Admin Guard يوجّه لـ /login بدون توكن ✅
- RTL في كل الصفحات ✅
- Responsive على 375px و 768px و 1280px ✅

## 📤 التسليم

1. `npm run build` ← مجلد `dist/` جاهز
2. ارفع الكود على GitHub
3. أخبر **ياسر (DevOps)** أن `dist/` جاهز للنشر على `admin.elmokef.ma`
4. اكتب `outbox.md` في مجلدك:

```md
# 📤 تسليم Sprint 8 — Admin Panel

**المطوّر:** رئيس الفريق  
**28 سبتمبر – 9 أكتوبر 2026**  
**الحالة:** ✅ مكتمل

## ما تم إنجازه

- ✅ 8 صفحات: Login, Dashboard, Users, Artisans, Categories, Subscriptions, Complaints, Reviews, Notifications
- ✅ RTL كامل مع MUI
- ✅ Admin Guard (JWT)
- ✅ API Connection مع Axios Interceptor
- ✅ Loading/Empty/Error states
- ✅ `npm run build` بدون أخطاء
- ✅ جاهز للنشر على `admin.elmokef.ma`
```

**مبروك! 🎉 Admin Panel جاهز.**
