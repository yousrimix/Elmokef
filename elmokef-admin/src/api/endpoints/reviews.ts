import api from '../axios';

export const getReviews = (page = 1, limit = 10, status = '') =>
  api.get('/admin/reviews', { params: { page, limit, status } });

export const moderateReview = (id: number, status: string, reason?: string) =>
  api.patch(`/admin/reviews/${id}`, { status, reason });
