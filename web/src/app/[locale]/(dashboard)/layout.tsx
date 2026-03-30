import { createServerSupabaseClient } from '@/lib/supabase/server';
import { redirect } from 'next/navigation';
import { Sidebar } from './components/sidebar';
import styles from './dashboard.module.css';

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createServerSupabaseClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    redirect('/login');
  }

  const { data: profile } = await supabase
    .from('profiles')
    .select('full_name, roles')
    .eq('id', user.id)
    .single();

  return (
    <div className={styles.dashboardLayout}>
      <Sidebar userName={profile?.full_name || user.email || ''} roles={profile?.roles || []} />
      <main className={styles.mainContent}>
        {children}
      </main>
    </div>
  );
}
