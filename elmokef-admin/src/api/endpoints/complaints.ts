import api from '../axios';

export const getComplaints = (page = 1, limit = 10, status = '') =>
  api.get('/admin/complaints', { params: { page, limit, status } });

export const updateComplaintStatus = (id: number, status: string) =>
  api.patch(`/admin/complaints/${id}`, { status });
