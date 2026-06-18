import rtlPlugin from 'stylis-plugin-rtl';
import { prefixer } from 'stylis';

export const rtlCache = {
  key: 'muirtl',
  stylisPlugins: [prefixer, rtlPlugin],
};
