import api from '../axios';

export const loginApi = (email: string, password: string) =>
  api.post('/auth/login', { email, password });

export const getStats = () => api.get('/admin/stats');

export const sendNotification = (data: { title: string; body: string; target: string }) =>
  api.post('/admin/notifications/send', data);
