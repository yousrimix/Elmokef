import api from '../axios';

export const getUsers = (page = 1, limit = 10, role = '', search = '') =>
  api.get('/admin/users', { params: { page, limit, role, search } });
