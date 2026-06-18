import { useState, useEffect } from 'react';
import {
  Box, Grid, Card, CardContent, Typography, Skeleton, Button, Alert,
} from '@mui/material';
import PeopleIcon from '@mui/icons-material/People';
import BuildIcon from '@mui/icons-material/Build';
import SubscriptionsIcon from '@mui/icons-material/CardMembership';
import PaymentsIcon from '@mui/icons-material/Payments';
import RefreshIcon from '@mui/icons-material/Refresh';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { getStats } from '../api/endpoints/auth';

const fallbackStats = [
  { label: 'المستخدمون', value: '1,247', icon: <PeopleIcon />, color: '#3B82F6' },
  { label: 'الحرفيون', value: '186', icon: <BuildIcon />, color: '#0D9488' },
  { label: 'الاشتراكات النشطة', value: '94', icon: <SubscriptionsIcon />, color: '#F59E0B' },
  { label: 'الإيرادات الشهرية', value: '18,506 درهم', icon: <PaymentsIcon />, color: '#10B981' },
];

const fallbackChart = [
  { day: 'السبت', users: 12 }, { day: 'الأحد', users: 8 },
  { day: 'الإثنين', users: 15 }, { day: 'الثلاثاء', users: 20 },
  { day: 'الأربعاء', users: 10 }, { day: 'الخميس', users: 18 },
  { day: 'الجمعة', users: 14 },
];

const fallbackComplaints = [
  { client: 'أحمد الفاسي', artisan: 'كريم السباك', reason: 'تأخير', status: 'مفتوحة' },
  { client: 'فاطمة المراكشية', artisan: 'سعيد الكهربائي', reason: 'جودة', status: 'قيد المعالجة' },
  { client: 'يونس البيضاوي', artisan: 'حميد النجار', reason: 'سلوك', status: 'مفتوحة' },
  { client: 'نورة الرباطية', artisan: 'عمر الدهان', reason: 'إلغاء', status: 'مغلقة' },
  { client: 'مصطفى الفاسي', artisan: 'جمال المكالمين', reason: 'جودة', status: 'قيد المعالجة' },
];

export default function Dashboard() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [stats, setStats] = useState(fallbackStats);
  const [chartData, setChartData] = useState(fallbackChart);
  const [complaints, setComplaints] = useState(fallbackComplaints);

  const fetchData = async () => {
    setLoading(true);
    setError(false);
    try {
      const res = await getStats();
      if (res.data.stats) setStats(res.data.stats);
      if (res.data.chartData) setChartData(res.data.chartData);
      if (res.data.complaints) setComplaints(res.data.complaints);
    } catch {
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchData(); }, []);

  if (error) {
    return (
      <Box sx={{ textAlign: 'center', py: 8 }}>
        <Alert severity="error" sx={{ mb: 2, justifyContent: 'center' }}>حدث خطأ أثناء تحميل البيانات</Alert>
        <Button variant="outlined" startIcon={<RefreshIcon />} onClick={fetchData}>إعادة المحاولة</Button>
      </Box>
    );
  }

  return (
    <Box>
      <Typography variant="h4" sx={{ mb: 3 }}>لوحة الإحصائيات</Typography>
      {loading ? (
        <Grid container spacing={3}>
          {[1, 2, 3, 4].map((i) => (
            <Grid size={{ xs: 12, sm: 6, md: 3 }} key={i}>
              <Card><CardContent><Skeleton height={80} /></CardContent></Card>
            </Grid>
          ))}
          <Grid size={{ xs: 12, md: 8 }}><Card><CardContent><Skeleton height={250} /></CardContent></Card></Grid>
          <Grid size={{ xs: 12, md: 4 }}><Card><CardContent><Skeleton height={250} /></CardContent></Card></Grid>
        </Grid>
      ) : (
        <Grid container spacing={3}>
          {stats.map((s) => (
            <Grid size={{ xs: 12, sm: 6, md: 3 }} key={s.label}>
              <Card>
                <CardContent sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                  <Box sx={{ p: 1.5, borderRadius: 2, bgcolor: `${s.color}20`, color: s.color }}>{s.icon}</Box>
                  <Box>
                    <Typography variant="h5" sx={{ fontWeight: 700 }}>{s.value}</Typography>
                    <Typography variant="body2" color="text.secondary">{s.label}</Typography>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
          ))}
          <Grid size={{ xs: 12, md: 7 }}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 2 }}>المستخدمون الجدد — آخر 7 أيام</Typography>
                {chartData.length === 0 ? (
                  <Box sx={{ textAlign: 'center', py: 6 }} color="text.secondary">لا توجد بيانات</Box>
                ) : (
                  <ResponsiveContainer width="100%" height={250}>
                    <BarChart data={chartData}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="day" />
                      <YAxis />
                      <Tooltip />
                      <Bar dataKey="users" fill="#0D9488" radius={[4, 4, 0, 0]} />
                    </BarChart>
                  </ResponsiveContainer>
                )}
              </CardContent>
            </Card>
          </Grid>
          <Grid size={{ xs: 12, md: 5 }}>
            <Card>
              <CardContent>
                <Typography variant="h6" sx={{ mb: 2 }}>آخر الشكايات المعلقة</Typography>
                {complaints.length === 0 ? (
                  <Box sx={{ textAlign: 'center', py: 6 }} color="text.secondary">لا توجد شكايات</Box>
                ) : (
                  complaints.map((c, i) => (
                    <Box key={i} sx={{ display: 'flex', justifyContent: 'space-between', py: 1, borderBottom: '1px solid #eee' }}>
                      <Box>
                        <Typography variant="body2" sx={{ fontWeight: 600 }}>{c.client}</Typography>
                        <Typography variant="caption" color="text.secondary">{c.artisan} — {c.reason}</Typography>
                      </Box>
                    </Box>
                  ))
                )}
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      )}
    </Box>
  );
}
