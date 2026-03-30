import { createServerSupabaseClient } from '@/lib/supabase/server';
import { getTranslations } from 'next-intl/server';
import { notFound } from 'next/navigation';
import styles from '../vehicles.module.css';
import dashStyles from '../../dashboard.module.css';

interface Props {
  params: Promise<{ id: string; locale: string }>;
}

export default async function VehicleDetailPage({ params }: Props) {
  const { id } = await params;
  const supabase = await createServerSupabaseClient();
  const t = await getTranslations('Vehicles');
  const tc = await getTranslations('Common');

  const { data: vehicle, error } = await supabase
    .from('vehicles')
    .select('*')
    .eq('id', id)
    .single();

  if (error || !vehicle) {
    notFound();
  }

  const getStatusClass = (status: string) => {
    switch (status) {
      case 'active': return styles.statusActive;
      case 'in_maintenance': return styles.statusMaintenance;
      case 'out_of_service': return styles.statusOut;
      default: return '';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'active': return t('statusActive');
      case 'in_maintenance': return t('statusInMaintenance');
      case 'out_of_service': return t('statusOutOfService');
      default: return status;
    }
  };

  return (
    <div>
      <div className={styles.detailHeader}>
        <a href="/vehicles" className={styles.backLink}>←</a>
        <h1 className={dashStyles.pageTitle}>{vehicle.plate_number}</h1>
        <span className={`${styles.statusBadge} ${getStatusClass(vehicle.status)}`}>
          {getStatusLabel(vehicle.status)}
        </span>
      </div>

      <div className={styles.detailGrid}>
        <div className={styles.detailCard}>
          <h2 className={styles.detailCardTitle}>{t('vehicleInfo')}</h2>
          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('make')}</span>
            <span className={styles.detailValue}>{vehicle.make}</span>
          </div>
          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('model')}</span>
            <span className={styles.detailValue}>{vehicle.model}</span>
          </div>
          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('year')}</span>
            <span className={styles.detailValue}>{vehicle.year}</span>
          </div>
          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('vin')}</span>
            <span className={styles.detailValue}>{vehicle.vin || '—'}</span>
          </div>
        </div>

        <div className={styles.detailCard}>
          <h2 className={styles.detailCardTitle}>{t('operationalInfo')}</h2>
          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('fuelType')}</span>
            <span className={styles.detailValue}>{vehicle.fuel_type}</span>
          </div>
          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('odometer')}</span>
            <span className={styles.detailValue}>{vehicle.odometer_km?.toLocaleString()} {t('odometerUnit')}</span>
          </div>
          <div className={styles.detailRow}>
            <span className={styles.detailLabel}>{t('status')}</span>
            <span className={styles.detailValue}>{getStatusLabel(vehicle.status)}</span>
          </div>
        </div>
      </div>
    </div>
  );
}
