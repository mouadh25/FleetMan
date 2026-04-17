import { createServerSupabaseClient } from '@/lib/supabase/server';
import { getTranslations } from 'next-intl/server';
import styles from './dashboard.module.css';

interface StatsCardProps {
  label: string;
  value: number;
  icon: string;
  colorClass: string;
  trend?: 'up' | 'down' | 'neutral';
}

async function StatsCard({ label, value, icon, colorClass }: StatsCardProps) {
  return (
    <div className={`${styles.statCard} ${styles[colorClass]}`}>
      <div className={styles.statIcon}>{icon}</div>
      <div className={styles.statInfo}>
        <span className={styles.statLabel}>{label}</span>
        <span className={styles.statValue}>{value}</span>
      </div>
    </div>
  );
}

async function RecentVehicles() {
  const supabase = await createServerSupabaseClient();
  const { data: vehicles } = await supabase
    .from('vehicles')
    .select('id, plate_number, make, model, status')
    .order('created_at', { ascending: false })
    .limit(5);

  if (!vehicles || vehicles.length === 0) {
    return (
      <div className={styles.emptyState}>
        <span>📭</span>
        <p>Aucun véhicule récent</p>
      </div>
    );
  }

  return (
    <div className={styles.vehicleList}>
      {vehicles.map((vehicle) => (
        <div key={vehicle.id} className={styles.vehicleItem}>
          <div className={styles.vehicleIcon}>🚚</div>
          <div className={styles.vehicleInfo}>
            <span className={styles.vehiclePlate}>{vehicle.plate_number}</span>
            <span className={styles.vehicleMeta}>
              {vehicle.make} {vehicle.model}
            </span>
          </div>
          <span
            className={`${styles.statusBadge} ${
              vehicle.status === 'active'
                ? styles.statusActive
                : vehicle.status === 'in_maintenance'
                ? styles.statusMaintenance
                : styles.statusOutOfService
            }`}
          >
            {vehicle.status === 'active'
              ? 'Actif'
              : vehicle.status === 'in_maintenance'
              ? 'Maintenance'
              : 'Hors service'}
          </span>
        </div>
      ))}
    </div>
  );
}

async function RecentAudits() {
  const supabase = await createServerSupabaseClient();
  const { data: audits } = await supabase
    .from('audits')
    .select('id, vehicle_id, status, created_at, vehicles(plate_number)')
    .order('created_at', { ascending: false })
    .limit(5);

  if (!audits || audits.length === 0) {
    return (
      <div className={styles.emptyState}>
        <span>📋</span>
        <p>Aucun audit récent</p>
      </div>
    );
  }

  return (
    <div className={styles.auditList}>
      {audits.map((audit) => (
        <div key={audit.id} className={styles.auditItem}>
          <div className={styles.auditIcon}>
            {audit.status === 'passed' ? '✅' : audit.status === 'failed' ? '❌' : '🔍'}
          </div>
          <div className={styles.auditInfo}>
            <span className={styles.auditVehicle}>
              {(audit as unknown as { vehicles?: { plate_number: string }[] }).vehicles?.[0]?.plate_number || 'N/A'}
            </span>
            <span className={styles.auditDate}>
              {new Date(audit.created_at).toLocaleDateString('fr-DZ')}
            </span>
          </div>
          <span
            className={`${styles.statusBadge} ${
              audit.status === 'passed'
                ? styles.statusActive
                : audit.status === 'failed'
                ? styles.statusOutOfService
                : styles.statusMaintenance
            }`}
          >
            {audit.status === 'passed'
              ? 'Réussi'
              : audit.status === 'failed'
              ? 'Échoué'
              : 'En cours'}
          </span>
        </div>
      ))}
    </div>
  );
}

async function OpenIssues() {
  const supabase = await createServerSupabaseClient();
  const { data: issues } = await supabase
    .from('issues')
    .select('id, title, severity, vehicle_id, vehicles(plate_number)')
    .eq('status', 'open')
    .order('created_at', { ascending: false })
    .limit(5);

  if (!issues || issues.length === 0) {
    return (
      <div className={styles.emptyState}>
        <span>✨</span>
        <p>Aucune problème ouvert</p>
      </div>
    );
  }

  return (
    <div className={styles.issueList}>
      {issues.map((issue) => (
        <div key={issue.id} className={styles.issueItem}>
          <div className={styles.issueIcon}>
            {issue.severity === 'critical'
              ? '🚨'
              : issue.severity === 'high'
              ? '⚠️'
              : '📋'}
          </div>
          <div className={styles.issueInfo}>
            <span className={styles.issueTitle}>{issue.title}</span>
            <span className={styles.issueVehicle}>
              {(issue as unknown as { vehicles?: { plate_number: string }[] }).vehicles?.[0]?.plate_number || 'N/A'}
            </span>
          </div>
        </div>
      ))}
    </div>
  );
}

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

  const { count: totalAudits } = await supabase
    .from('audits')
    .select('id', { count: 'exact', head: true });

  const { count: passedAudits } = await supabase
    .from('audits')
    .select('id', { count: 'exact', head: true })
    .eq('status', 'passed');

  return (
    <div className={styles.dashboardContent}>
      <header className={styles.pageHeader}>
        <div>
          <h1 className={styles.pageTitle}>
            {t('welcome', { name: profile?.full_name || '' })}
          </h1>
          <p className={styles.pageSubtitle}>{t('fleetOverview')}</p>
        </div>
        <div className={styles.headerActions}>
          <a href="/vehicles/new" className={styles.primaryButton}>
            <span>+</span> Ajouter un véhicule
          </a>
        </div>
      </header>

      <section className={styles.statsGrid}>
        <StatsCard
          label={t('totalVehicles')}
          value={totalVehicles ?? 0}
          icon="🚚"
          colorClass="statCardBlue"
        />
        <StatsCard
          label={t('activeVehicles')}
          value={activeVehicles ?? 0}
          icon="✅"
          colorClass="statCardGreen"
        />
        <StatsCard
          label={t('inMaintenance')}
          value={inMaintenance ?? 0}
          icon="🔧"
          colorClass="statCardOrange"
        />
        <StatsCard
          label={t('openIssues')}
          value={openIssues ?? 0}
          icon="⚠️"
          colorClass="statCardRed"
        />
      </section>

      <section className={styles.secondaryStats}>
        <div className={styles.secondaryStatCard}>
          <div className={styles.secondaryStatIcon}>📋</div>
          <div className={styles.secondaryStatInfo}>
            <span className={styles.secondaryStatLabel}>Total audits</span>
            <span className={styles.secondaryStatValue}>{totalAudits ?? 0}</span>
          </div>
        </div>
        <div className={styles.secondaryStatCard}>
          <div className={styles.secondaryStatIcon}>🎯</div>
          <div className={styles.secondaryStatInfo}>
            <span className={styles.secondaryStatLabel}>Taux de réussite</span>
            <span className={styles.secondaryStatValue}>
              {totalAudits && totalAudits > 0 && passedAudits
                ? Math.round((passedAudits / totalAudits) * 100)
                : 0}
              %
            </span>
          </div>
        </div>
        <div className={styles.secondaryStatCard}>
          <div className={styles.secondaryStatIcon}>📊</div>
          <div className={styles.secondaryStatInfo}>
            <span className={styles.secondaryStatLabel}>Fleet Health</span>
            <span className={styles.secondaryStatValue}>
              {totalVehicles && totalVehicles > 0 && activeVehicles
                ? Math.round((activeVehicles / totalVehicles) * 100)
                : 0}
              %
            </span>
          </div>
        </div>
      </section>

      <section className={styles.dashboardGrid}>
        <div className={styles.dashboardCard}>
          <div className={styles.cardHeader}>
            <h2 className={styles.cardTitle}>🚚 Véhicules récents</h2>
            <a href="/vehicles" className={styles.cardLink}>
              Voir tout
            </a>
          </div>
          <RecentVehicles />
        </div>

        <div className={styles.dashboardCard}>
          <div className={styles.cardHeader}>
            <h2 className={styles.cardTitle}>📋 Audits récents</h2>
            <a href="/audits" className={styles.cardLink}>
              Voir tout
            </a>
          </div>
          <RecentAudits />
        </div>

        <div className={styles.dashboardCard}>
          <div className={styles.cardHeader}>
            <h2 className={styles.cardTitle}>⚠️ Problèmes ouverts</h2>
            <a href="/issues" className={styles.cardLink}>
              Voir tout
            </a>
          </div>
          <OpenIssues />
        </div>
      </section>
    </div>
  );
}
