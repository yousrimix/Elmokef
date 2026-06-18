import { useLocation, useNavigate } from 'react-router-dom';
import {
  Drawer, List, ListItemButton, ListItemIcon, ListItemText,
} from '@mui/material';
import DashboardIcon from '@mui/icons-material/Dashboard';
import PeopleIcon from '@mui/icons-material/People';
import BuildIcon from '@mui/icons-material/Build';
import CategoryIcon from '@mui/icons-material/Category';
import SubscriptionsIcon from '@mui/icons-material/CardMembership';
import ReportIcon from '@mui/icons-material/Report';
import StarIcon from '@mui/icons-material/Star';
import NotificationsIcon from '@mui/icons-material/Notifications';

const drawerWidth = 260;

const menu = [
  { label: 'الإحصائيات', icon: <DashboardIcon />, path: '/' },
  { label: 'المستخدمين', icon: <PeopleIcon />, path: '/users' },
  { label: 'الحرفيين', icon: <BuildIcon />, path: '/artisans' },
  { label: 'الفئات', icon: <CategoryIcon />, path: '/categories' },
  { label: 'الاشتراكات', icon: <SubscriptionsIcon />, path: '/subscriptions' },
  { label: 'الشكايات', icon: <ReportIcon />, path: '/complaints' },
  { label: 'التقييمات', icon: <StarIcon />, path: '/reviews' },
  { label: 'إرسال إشعار', icon: <NotificationsIcon />, path: '/notifications' },
];

export default function Sidebar() {
  const location = useLocation();
  const navigate = useNavigate();

  return (
    <Drawer
      variant="permanent"
      sx={{
        width: drawerWidth,
        '& .MuiDrawer-paper': {
          width: drawerWidth,
          bgcolor: '#0D9488',
          color: '#fff',
          border: 'none',
        },
      }}
    >
      <List sx={{ pt: 3 }}>
        {menu.map((item) => (
          <ListItemButton
            key={item.path}
            selected={location.pathname === item.path}
            onClick={() => navigate(item.path)}
            sx={{
              mx: 1,
              my: 0.5,
              borderRadius: 2,
              color: '#fff',
              '&.Mui-selected': {
                bgcolor: 'rgba(255,255,255,0.15)',
                '&:hover': { bgcolor: 'rgba(255,255,255,0.2)' },
              },
              '&:hover': { bgcolor: 'rgba(255,255,255,0.1)' },
            }}
          >
            <ListItemIcon sx={{ color: '#fff', minWidth: 40 }}>
              {item.icon}
            </ListItemIcon>
            <ListItemText primary={item.label} />
          </ListItemButton>
        ))}
      </List>
    </Drawer>
  );
}
