import { createServerSupabaseClient } from '@/lib/supabase/server';
import { getTranslations } from 'next-intl/server';
import styles from './dashboard.module.css';

export default async function DashboardPage() {
  const supabase = await createServerSupabaseClient();
  const t = await getTranslations('Dashboard');

  const { data: profile } = await supabase
    .from('profiles')
    .select('full_name')
    .single();

  const { count: totalVehicles } = await supabase
    .from('vehicles')
    .select('id', { count: 'exact', head: true });

  const { count: activeVehicles } = await supabase
    .from('vehicles')
    .select('id', { count: 'exact', head: true })
    .eq('status', 'active');

  const { count: inMaintenance } = await supabase
    .from('vehicles')
    .select('id', { count: 'exact', head: true })
    .eq('status', 'in_maintenance');

  const { count: openIssues } = await supabase
    .from('issues')
    .select('id', { count: 'exact', head: true })
    .eq('status', 'open');

  return (
    <div>
      <h1 className={styles.pageTitle}>
        {t('welcome', { name: profile?.full_name || '' })}
      </h1>

      <div className={styles.statsGrid}>
        <div className={styles.statCard}>
          <div className={`${styles.statIcon} ${styles.statIconBlue}`}>🚚</div>
          <div className={styles.statInfo}>
            <h3>{t('totalVehicles')}</h3>
            <p>{totalVehicles ?? 0}</p>
          </div>
        </div>

        <div className={styles.statCard}>
          <div className={`${styles.statIcon} ${styles.statIconGreen}`}>✅</div>
          <div className={styles.statInfo}>
            <h3>{t('activeVehicles')}</h3>
            <p>{activeVehicles ?? 0}</p>
          </div>
        </div>

        <div className={styles.statCard}>
          <div className={`${styles.statIcon} ${styles.statIconOrange}`}>🔧</div>
          <div className={styles.statInfo}>
            <h3>{t('inMaintenance')}</h3>
            <p>{inMaintenance ?? 0}</p>
          </div>
        </div>

        <div className={styles.statCard}>
          <div className={`${styles.statIcon} ${styles.statIconRed}`}>⚠️</div>
          <div className={styles.statInfo}>
            <h3>{t('openIssues')}</h3>
            <p>{openIssues ?? 0}</p>
          </div>
        </div>
      </div>
    </div>
  );
}
