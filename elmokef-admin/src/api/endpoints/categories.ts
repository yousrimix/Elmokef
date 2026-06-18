import api from '../axios';

export const getCategories = () => api.get('/categories');
export const createCategory = (data: { name: string; icon: string }) => api.post('/admin/categories', data);
export const updateCategory = (id: number, data: { name: string; icon: string }) => api.put(`/admin/categories/${id}`, data);
export const deleteCategory = (id: number) => api.delete(`/admin/categories/${id}`);
