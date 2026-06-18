import api from '../axios';

export const getSubscriptions = (page = 1, limit = 10, plan = '', status = '') =>
  api.get('/admin/subscriptions', { params: { page, limit, plan, status } });

export const updateSubscription = (id: number, data: { plan: string; status?: string }) =>
  api.patch(`/admin/subscriptions/${id}`, data);
