import { useState, useEffect } from 'react';
import {
  Box, Card, Typography, Table, TableHead, TableRow, TableCell, TableBody,
  TableContainer, Chip, TextField, MenuItem, TablePagination, InputAdornment,
  Skeleton, Alert, Button,
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import RefreshIcon from '@mui/icons-material/Refresh';
import { getUsers } from '../api/endpoints/users';

export default function Users() {
  const [users, setUsers] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  const fetchUsers = async () => {
    setLoading(true);
    setError(false);
    try {
      const res = await getUsers(page + 1, rowsPerPage, roleFilter, search);
      setUsers(res.data.users || res.data.data || []);
      setTotal(res.data.total || res.data.count || 0);
    } catch {
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchUsers(); }, [page, rowsPerPage, roleFilter, search]);

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>إدارة المستخدمين</Typography>
      <Box sx={{ display: 'flex', gap: 2, mb: 3, flexWrap: 'wrap' }}>
        <TextField size="small" placeholder="بحث..." value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(0); }}
          slotProps={{ input: { startAdornment: <InputAdornment position="start"><SearchIcon /></InputAdornment> } }}
          sx={{ minWidth: 250 }}
        />
        <TextField select size="small" value={roleFilter}
          onChange={(e) => { setRoleFilter(e.target.value); setPage(0); }} sx={{ minWidth: 150 }}>
          <MenuItem value="">الكل</MenuItem>
          <MenuItem value="عميل">عميل</MenuItem>
          <MenuItem value="حرفي">حرفي</MenuItem>
          <MenuItem value="ادمن">ادمن</MenuItem>
        </TextField>
      </Box>
      {error ? (
        <Alert severity="error" action={<Button size="small" startIcon={<RefreshIcon />} onClick={fetchUsers}>إعادة</Button>}>فشل تحميل البيانات</Alert>
      ) : (
        <Card>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow sx={{ bgcolor: '#f5f5f5' }}>
                  <TableCell>الاسم</TableCell><TableCell>الهاتف</TableCell><TableCell>البريد</TableCell>
                  <TableCell>الدور</TableCell><TableCell>تاريخ التسجيل</TableCell><TableCell>الحالة</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {loading ? (
                  <TableRow><TableCell colSpan={6} sx={{ py: 4 }}><Skeleton /></TableCell></TableRow>
                ) : users.length === 0 ? (
                  <TableRow><TableCell colSpan={6} align="center" sx={{ py: 6, color: 'text.secondary' }}>لا توجد بيانات</TableCell></TableRow>
                ) : (
                  users.map((u: any) => (
                    <TableRow key={u.id} hover>
                      <TableCell>{u.name}</TableCell>
                      <TableCell dir="ltr">{u.phone}</TableCell>
                      <TableCell dir="ltr">{u.email}</TableCell>
                      <TableCell><Chip label={u.role} size="small" color={u.role === 'ادمن' ? 'error' : u.role === 'حرفي' ? 'primary' : 'default'} /></TableCell>
                      <TableCell>{u.registered || u.createdAt}</TableCell>
                      <TableCell><Chip label={u.status} size="small" color={u.status === 'نشط' || u.status === 'Active' ? 'success' : 'error'} /></TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
          <TablePagination component="div" count={total} page={page} onPageChange={(_, p) => setPage(p)}
            rowsPerPage={rowsPerPage} onRowsPerPageChange={(e) => { setRowsPerPage(parseInt(e.target.value, 10)); setPage(0); }}
            labelRowsPerPage="عدد الصفوف" />
        </Card>
      )}
    </Box>
  );
}
