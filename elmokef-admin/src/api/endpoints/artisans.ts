import api from '../axios';

export const getArtisans = (page = 1, limit = 10, verification = '', search = '') =>
  api.get('/admin/artisans', { params: { page, limit, verification, search } });

export const verifyArtisan = (id: string, status: string, reason?: string) =>
  api.patch(`/admin/artisans/${id}/verify`, { status, reason });
