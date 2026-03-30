import { redirect } from 'next/navigation';

// Root page redirects to login — the dashboard route group
// handles authenticated pages via its own layout.
export default function RootPage() {
  redirect('/login');
}
