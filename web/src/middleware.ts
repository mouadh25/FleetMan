import createMiddleware from 'next-intl/middleware';
import { routing } from './i18n/routing';

export default createMiddleware(routing);

export const config = {
  // Match all pathnames except for static files, api, _next, and _vercel
  matcher: ['/((?!api|_next|_vercel|.*\\..*).*)']
};

